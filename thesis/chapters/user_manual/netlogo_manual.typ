#import "../../lib/elteikthesis.typ": definition, todo

== NetLogo implementation

The primary goal of this thesis is to reproduce the findings in @fatint using the NetLogo framework.

#todo("Describe what NetLogo is")

=== System requirements

- NetLogo 6 or newer
- Java 1.4 or newer
- At least 256MB of RAM
- At least 25MB of disk space

#todo("Verify system req")

=== Installation and launching

+ Make sure to download the model `model.nlogo` file and any `.nls` files from the project repository.
+ Download and launch the NetLogo installer from #link("https://www.netlogo.org")
+ Open NetLogo. An empty main window should appear.
+ In the menu bar click *File*, then select *Open*. See @nl-menu.
+ Browse to and select `model.nlogo`.
+ The main window should populate with controls for the simulation. See @nl-controls.

#grid(
  columns: (1fr, 1fr),
  [#figure(
    image("../../assets/screenshots/netlogo_menu_open.png"),
    caption: [ The NetLogo main window with the File menu open ]
  ) <nl-menu>],
  [#figure(
    image("../../assets/screenshots/netlogo_model_ui.png"),
    caption: [ The NetLogo main window showing model parameters ]
  ) <nl-controls>]
)

=== Running a simulation

The green boxes are parameters you can set by typing the white text fields.

The parameters of the model are described in @model-desc.

/ Starting population: How many entities are created in the first cycle
/ Starting allele count: How many alleles each entity has in their genotype in the first cycle
/ Use stretch method: When introducing a new allele, each entity gains a random one by default. This switch replaces the randomness with @stretch-formula.

The following parameters do not affect model behavior but may affect performance:

/ Measure every n steps: Counting species is expensive. This setting limits counting to every few steps.
/ Use DS: Use Disjoint-Sets algorithm instead of Depth-First Search to count distinct species. Slightly improves performance.

#todo("Compare DS and DFS performance. Maybe remove the slower one entirely.")

The purple boxes are buttons.

/ Setup: Resets and model and prepares it for a new simulation.
/ 1 step: Performs one cycle of the simulation.
/ 500 steps: Performs at most 500 cycles of the simulation.
/ Go: Continuously runs the simulation until the population drops to zero.
/ Plus: Manually introduces a new allele to every entity.

The yellow boxes tracks the state of the population in the model.

/ Population: The amount of entities currently in the simulation
/ Species count: The number of species the population can be grouped into based on reproduction compatibility.
/ Allele count: The number of alleles every entity has in their genotype.

#todo[_Allele_ is an incorrect term for this, use _Gene_]

=== Running an experiment

#definition(title: "Experiment")[
  Running the simulation with the same parameters but a different random seed multiple times, then compiling the results.
]

+ Click *Tools* in the menu bar then select *BehaviorSpace*. See @nl-bs-menu.
+ A window listing the various preconfigured experiments will open. See @nl-bs-list.
+ Select your desired experiment. You may click *Edit* to modify it, see @nl-bs-edit. Once satisfied and click *Run*.
+ A Run dialog will open. See @nl-bs-run. Browse where to save the outputs. #todo("Describe each output format")
+ Select whether you want the plots to update during the simulation. This may slow it down.
+ Click *OK* to start the experiment. A window showing the current state of the model will open. See @nl-bs-run.

#grid(
  columns: (1fr, 1fr, 1fr),
  [#figure(
    image("../../assets/screenshots/netlogo_menu_behaviorspace.png"),
    caption: [NetLogo BehaviorSpace experiment list window]
  ) <nl-bs-menu>],
  [#figure(
    image("../../assets/screenshots/netlogo_behaviorspace_ui.png"),
    caption: [NetLogo BehaviorSpace experiment list window]
  ) <nl-bs-list>],
  [#figure(
    image("../../assets/screenshots/netlogo_behaviorspace_edit.png"),
    caption: [NetLogo BehaviorSpace experiment editor window]
  ) <nl-bs-edit>],
  [#figure(
    image("../../assets/screenshots/netlogo_behaviorspace_run.png"),
    caption: [NetLogo BehaviorSpace run options]
  ) <nl-bs-run>],
  [#figure(
    image("../../assets/screenshots/netlogo_behaviorspace_running.png"),
    caption: [NetLogo BehaviorSpace run]
  ) <nl-bs-running>],
)

=== Running an experiment sweep

#definition(title: "Experiment sweep")[
  Running multiple experiments, where the only difference is in a single parameter. The value of the parameter is increased between every experiment.
]
