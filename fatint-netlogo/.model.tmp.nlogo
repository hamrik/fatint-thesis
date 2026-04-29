extensions [ profiler ]

__includes [
  "disjoint-sets.nls"
  "depth-first-search.nls"
]

globals [
  available-energy
  population
  species-count
  allele-count

  ;; Euclidean distance threshold between genotypes of two compatible agents.U pdated by `setup`.
  ;; Squared value is stored to spare a `sqrt` operation when checking.
  M-limit-sqr
]
turtles-own [
  ;; Model
  phenotype
  e-discounting
  accumulated-energy

  ;; Depth First Search counting helper
  visited

  ;; Disjoint-Sets counting helper
  parent
  rank
]

to reset
  set V-min 0
  set V-max 100
  set P-encounter 0.1
  set P-crossing 0.2
  set P-mutation 0.1
  set V-mutation 2
  set M-limit 15
  set M-slope 0
  set M-const 1
  set E-consumption 5
  set E-intake 10
  set E-discount 0.9
  set E-increase 1000
  set P-change 0
  set V-stretch 1
  set N-init 5
  set M-init 100
  set use-stretch-method false
  set use-ds false
  set measure-every-n-ticks 1
end
to-report check-parameters
	let errors []
	if (M-init < 1) [
		set errors (lput "constraint violation: 1 <= M-init does not hold" errors)
	]
	if (N-init < 1) [
		set errors (lput "constraint violation: 1 <= N-init does not hold" errors)
	]
    if (V-min > V-max) [
		set errors (lput "constraint violation: V-min <= V-max does not hold" errors)
	]
	if (P-encounter < 0) or (P-encounter > 1) [
		set errors (lput "constraint violation: 0 <= P-encounter <= 1 does not hold" errors)
	]
	if (P-crossing < 0) or (P-crossing > 1) [
		set errors (lput "constraint violation: 0 <= P-crossing <= 1 does not hold" errors)
	]
	if (P-mutation < 0) or (P-mutation > 1) [
		set errors (lput "constraint violation: 0 <= P-mutation <= 1 does not hold" errors)
	]
	if (P-change < 0) or (P-change > 1) [
		set errors (lput "constraint violation: 0 <= P-change <= 1 does not hold" errors)
	]
	if (V-mutation < 0) [
		set errors (lput "constraint violation: 0 <= V-mutation does not hold" errors)
	]
	if (M-const < 0) [
		set errors (lput "constraint violation: 0 <= M-const does not hold" errors)
	]
	if (M-limit < 0) [
		set errors (lput "constraint violation: 0 <= M-limit does not hold" errors)
	]
	if (E-increase < 0) [
		set errors (lput "constraint violation: 0 <= E-increase does not hold" errors)
	]
	if (E-consumption < 0) [
		set errors (lput "constraint violation: 0 <= E-consumption does not hold" errors)
	]
	if (E-intake < 0) [
		set errors (lput "constraint violation: 0 <= E-intake does not hold" errors)
	]
	if (E-discount < 0) or (E-discount > 1) [
		set errors (lput "constraint violation: 0 <= E-discount <= 1 does not hold" errors)
	]
	report errors
end
to-report assert-parameters
  let errors check-parameters
  if not empty? errors [
    foreach errors show
    foreach errors user-message
    report false
  ]
  report true
end

to-report random-gene
  report V-min + random (V-max - V-min)
end

to repopulate
  clear-all
  reset-ticks
  set M-limit-sqr M-limit * M-limit
  resize-world V-min V-max V-min V-max

  set available-energy 0
  set population       M-init
  set allele-count     N-init

  create-turtles M-init [
    set e-discounting      1
    set accumulated-energy 0
    set phenotype          n-values allele-count [random-gene]

    set shape "square"
    setxy (item 0 phenotype) (item 1 phenotype)
    set color (list ((item 2 phenotype) + 100) ((item 2 phenotype) + 100) ((item 3 phenotype) + 100))
  ]
end

to setup
  if not assert-parameters [
    stop
  ]

  repopulate
  ask turtles [ linkup ]
  count-species
end

;; ----- Aging -----------------------------------------------------------------

to replenish
  set available-energy available-energy + E-increase
end

to eat-or-die
  ask (turtles) [
    let energy-consumed 0
    if-else (available-energy > E-intake) [
      set energy-consumed  E-intake * e-discounting
      set available-energy available-energy - E-intake
    ] [
      set energy-consumed  available-energy * e-discounting
      set available-energy 0
    ]

    set e-discounting      e-discounting * E-discount
    set accumulated-energy accumulated-energy + energy-consumed - E-consumption

    if (accumulated-energy <= 0) [
      die
    ]
  ]
end

;; ----- Reproduction ----------------------------------------------------------

to-report delta-sqr [a b]
  report (a - b) * (a - b)
end

to-report combine [ga gb]
  let gene ga
  if (random-float 1.0) < P-crossing [
    set gene gb
  ]
  if (random-float 1.0) < P-mutation [
    set gene gene + (random V-mutation) * 2 - V-mutation
  ]
  report gene
end

to reproduce
  let new-allele-count 0

  ask turtles with [(random-float 1.0) < P-encounter] [
    if any? my-links [
      ask one-of my-links [
        let a               [phenotype] of end1
        let b               [phenotype] of end2
        let dist            sqrt (euclidean-distance-sqr a b)
        let offspring-count M-const + (M-limit - dist) * M-slope

        ask end1 [
          hatch offspring-count [
            set phenotype          (map combine a b)
            set e-discounting      1
            set accumulated-energy 0

            ;; Make sure offspring is viable
            foreach phenotype [ g ->
              if (g < V-min or g > V-max) [ die ]
            ]

            ;; Speciation event: introduce new gene to everyone
            if random-float 1.0 < P-change [
              set new-allele-count new-allele-count + 1
            ]

            setxy (item 0 phenotype) (item 1 phenotype)
            set color (list ((item 2 phenotype) + 100) ((item 2 phenotype) + 100) ((item 3 phenotype) + 100))

            linkup
          ]
        ]
      ]
    ]
  ]

  if (new-allele-count > 0) [
    ask links [ die ]
    repeat new-allele-count [
      add-allele
    ]
    ask turtles [ linkup ]
  ]
end

;; ----- FATINT ----------------------------------------------------------------

to count-species
  ifelse use-ds [
    ds-count-species
  ] [
    dft-count-species
  ]
end

to add-random-allele
  ask turtles [
    set phenotype (lput random-gene phenotype)
  ]
end

to add-stretched-allele
  ask turtles [
    let gene           last phenotype
    let stretched-gene V-min + ( (gene * V-stretch) mod (V-max - V-min + 1) )

    set phenotype (lput stretched-gene phenotype)
  ]
end

to add-allele
  ifelse use-stretch-method [
    add-stretched-allele
  ] [
    add-random-allele
  ]
  set allele-count allele-count + 1
end

to-report euclidean-distance-sqr [a b]
  report sum (map delta-sqr a b)
end

to-report compatible-with [p]
  let d euclidean-distance-sqr phenotype p
  report d <= M-limit-sqr
end

to linkup
  let p phenotype
  create-links-with other turtles with [compatible-with p]
end

to go
  replenish
  eat-or-die
  reproduce
  if not any? turtles [
    stop
  ]
  count-species
  tick
end

;; ----- Profiling -------------------------------------------------------------

to profile-sc-step
  ask turtles [ linkup ]
  count-species
end

to profile-s-step
  repeat 1000 [ go ]
end

to profile-species-counter
  profiler:reset
  profiler:start
  profile-sc-step
  profiler:stop
  tick
end

to profile-simulator
  profiler:reset
  profiler:start
  profile-s-step
  profiler:stop
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
889
10
1495
617
-1
-1
5.921
1
10
1
1
1
0
0
0
1
0
100
0
100
1
1
1
ticks
10.0

BUTTON
10
524
90
584
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
90
524
170
584
1 step
if assert-parameters [ go ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
10
10
410
131
Population
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

BUTTON
250
524
330
584
Go
if not assert-parameters [ stop ]\ngo
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
170
524
250
584
500 steps
if assert-parameters [ repeat 500 [ go ] ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
371
65
404
+
add-random-allele\ncount-species
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
10
131
410
251
Species count
NIL
NIL
0.0
10.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot species-count"

PLOT
10
251
410
371
Allele count
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -11053225 true "" "plot allele-count"

SWITCH
65
371
410
404
use-stretch-method
use-stretch-method
1
1
-1000

INPUTBOX
10
464
90
524
M-init
100.0
1
0
Number

INPUTBOX
10
404
210
464
N-init
5.0
1
0
Number

INPUTBOX
771
371
855
431
V-min
100.0
1
0
Number

INPUTBOX
671
371
755
431
V-max
0.0
1
0
Number

INPUTBOX
330
464
410
524
V-mutation
2.0
1
0
Number

INPUTBOX
538
371
622
431
V-stretch
1.0
1
0
Number

INPUTBOX
90
464
170
524
P-encounter
0.1
1
0
Number

INPUTBOX
170
464
250
524
P-crossing
0.2
1
0
Number

INPUTBOX
250
464
330
524
P-mutation
0.1
1
0
Number

INPUTBOX
210
404
410
464
P-change
2.0
1
0
Number

INPUTBOX
622
10
706
70
M-limit
15.0
1
0
Number

INPUTBOX
750
10
834
70
M-slope
0.0
1
0
Number

INPUTBOX
516
10
600
70
M-const
1.0
1
0
Number

TEXTBOX
416
16
518
50
OffspringCount =
12
0.0
1

TEXTBOX
604
14
623
32
+ (
12
0.0
1

TEXTBOX
711
14
746
48
- d ) *
12
0.0
1

INPUTBOX
524
524
608
584
E-intake
10.0
1
0
Number

INPUTBOX
628
524
712
584
E-discount
0.9
1
0
Number

INPUTBOX
758
524
854
584
E-consumption
5.0
1
0
Number

TEXTBOX
418
530
524
564
E_accumulated +=
12
0.0
1

TEXTBOX
613
528
628
546
* (
12
0.0
1

TEXTBOX
714
516
738
534
age
12
0.0
1

TEXTBOX
742
527
757
545
) -
12
0.0
1

INPUTBOX
330
524
410
584
E-increase
1000.0
1
0
Number

TEXTBOX
417
376
548
394
V_new = V_min + ( v *
12
0.0
1

TEXTBOX
627
376
668
394
) mod (
12
0.0
1

TEXTBOX
761
375
776
393
-
12
0.0
1

TEXTBOX
858
377
881
395
+ 1)
12
0.0
1

MONITOR
410
193
463
238
Species
species-count
17
1
11

MONITOR
410
74
463
119
Entities
count turtles
17
1
11

MONITOR
410
314
463
359
Alleles
allele-count
17
1
11

INPUTBOX
463
178
601
238
measure-every-n-ticks
1.0
1
0
Number

SWITCH
601
205
704
238
use-ds
use-ds
1
1
-1000

BUTTON
10
584
410
617
Reset parameters
reset
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
463
74
546
119
Viable pairs
count links
17
1
11

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

square
false
0
Rectangle -7500403 true true 30 30 270 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="default-settings" repetitions="10" runMetricsEveryStep="true">
    <preExperiment>reset</preExperiment>
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="6000"/>
    <metric>species-count</metric>
    <enumeratedValueSet variable="starting-pop">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sweep-p-encounter" repetitions="10" runMetricsEveryStep="true">
    <preExperiment>reset</preExperiment>
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="6000"/>
    <metric>species-count</metric>
    <steppedValueSet variable="P-encounter" first="0.05" step="0.005" last="0.095"/>
  </experiment>
  <experiment name="sweep-p-crossing" repetitions="10" runMetricsEveryStep="true">
    <preExperiment>reset</preExperiment>
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="6000"/>
    <metric>species-count</metric>
    <steppedValueSet variable="P-crossing" first="0" step="0.1" last="0.5"/>
  </experiment>
  <experiment name="sweep-p-mutation" repetitions="10" runMetricsEveryStep="true">
    <preExperiment>reset</preExperiment>
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="6000"/>
    <metric>species-count</metric>
    <steppedValueSet variable="P-mutation" first="0" step="0.1" last="0.5"/>
  </experiment>
  <experiment name="sweep-p-change" repetitions="10" runMetricsEveryStep="true">
    <preExperiment>reset</preExperiment>
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="6000"/>
    <metric>species-count</metric>
    <steppedValueSet variable="P-change" first="5.0E-4" step="5.0E-5" last="0.001"/>
  </experiment>
  <experiment name="sweep-m-limit" repetitions="10" runMetricsEveryStep="true">
    <preExperiment>reset
set P-change 0.0005</preExperiment>
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="6000"/>
    <metric>species-count</metric>
    <steppedValueSet variable="M-limit" first="5" step="1" last="20"/>
  </experiment>
  <experiment name="sweep-v-stretch" repetitions="10" runMetricsEveryStep="true">
    <preExperiment>reset
set use-stretch-method true
set P-change 0.0005</preExperiment>
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="6000"/>
    <metric>species-count</metric>
    <steppedValueSet variable="V-stretch" first="1" step="1" last="20"/>
  </experiment>
  <experiment name="benchmark-species-counter-dfs-one-species" repetitions="3" runMetricsEveryStep="true">
    <preExperiment>reset
profiler:reset
set use-ds false
set M-limit 1</preExperiment>
    <setup>repopulate
ask turtles [
  set phenotype n-values allele-count [ 0 ]
]</setup>
    <go>profile-species-counter
stop</go>
    <metric>profiler:inclusive-time "profile-sc-step"</metric>
    <enumeratedValueSet variable="starting-pop">
      <value value="16"/>
      <value value="32"/>
      <value value="64"/>
      <value value="128"/>
      <value value="256"/>
      <value value="512"/>
      <value value="1024"/>
      <value value="2048"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="benchmark-species-counter-dfs-many-species" repetitions="3" runMetricsEveryStep="true">
    <preExperiment>reset
profiler:reset
set use-ds false
set M-limit 1</preExperiment>
    <setup>repopulate
ask turtles [
  set phenotype n-values allele-count [ who ]
]</setup>
    <go>profile-species-counter
stop</go>
    <metric>profiler:inclusive-time "profile-sc-step"</metric>
    <enumeratedValueSet variable="starting-pop">
      <value value="16"/>
      <value value="32"/>
      <value value="64"/>
      <value value="128"/>
      <value value="256"/>
      <value value="512"/>
      <value value="1024"/>
      <value value="2048"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="benchmark-species-counter-ds-one-species" repetitions="3" runMetricsEveryStep="true">
    <preExperiment>reset
profiler:reset
set use-ds true
set M-limit 1</preExperiment>
    <setup>repopulate
ask turtles [
  set phenotype n-values allele-count [ 0 ]
]</setup>
    <go>profile-species-counter
stop</go>
    <metric>profiler:inclusive-time "profile-sc-step"</metric>
    <enumeratedValueSet variable="starting-pop">
      <value value="16"/>
      <value value="32"/>
      <value value="64"/>
      <value value="128"/>
      <value value="256"/>
      <value value="512"/>
      <value value="1024"/>
      <value value="2048"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="benchmark-species-counter-ds-many-species" repetitions="3" runMetricsEveryStep="true">
    <preExperiment>reset
profiler:reset
set use-ds true
set M-limit 1</preExperiment>
    <setup>repopulate
ask turtles [
  set phenotype n-values allele-count [ who ]
]</setup>
    <go>profile-species-counter
stop</go>
    <metric>profiler:inclusive-time "profile-sc-step"</metric>
    <enumeratedValueSet variable="starting-pop">
      <value value="16"/>
      <value value="32"/>
      <value value="64"/>
      <value value="128"/>
      <value value="256"/>
      <value value="512"/>
      <value value="1024"/>
      <value value="2048"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="benchmark-simulator-no-churn" repetitions="3" runMetricsEveryStep="true">
    <preExperiment>reset
profiler:reset
set P-encounter 0
set E-consumption 0</preExperiment>
    <setup>setup</setup>
    <go>profile-simulator
stop</go>
    <metric>profiler:inclusive-time "profile-s-step"</metric>
    <enumeratedValueSet variable="starting-pop">
      <value value="16"/>
      <value value="32"/>
      <value value="64"/>
      <value value="128"/>
      <value value="256"/>
      <value value="512"/>
      <value value="1024"/>
      <value value="2048"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="benchmark-simulator-churn" repetitions="3" runMetricsEveryStep="true">
    <preExperiment>reset
profiler:reset</preExperiment>
    <setup>setup</setup>
    <go>profile-simulator
stop</go>
    <metric>profiler:inclusive-time "profile-s-step"</metric>
    <enumeratedValueSet variable="starting-pop">
      <value value="16"/>
      <value value="32"/>
      <value value="64"/>
      <value value="128"/>
      <value value="256"/>
      <value value="512"/>
      <value value="1024"/>
      <value value="2048"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
