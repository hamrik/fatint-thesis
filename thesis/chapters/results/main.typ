#import "/lib/plot.typ": *
#import "@preview/lilaq:0.6.0" as lq

= Eredmények

#figure(
  {
    show: lq.layout
    grid(
      columns: (1fr),
      gutter: 12pt,
      netlogo_species_plot("/data/NetLogo-default_params.csv", none),
      avg_species_plot("/data/default_params.csv", none),
      image("/assets/paper_excerpts/default_params.png")
    )
  },
  caption: [
    Fajok számának alakulása alapértelmezett beállítások mellett.

    Felül: a reimplementációk eredményei.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  {
    show: lq.layout
    grid(
      columns: (1fr),
      gutter: 12pt,
      netlogo_species_plot("/data/NetLogo-p_encounter.csv", [$P_"encounter"$]),
      avg_species_plot("/data/p_encounter_0.05-0.10.csv", "p_encounter", cap: 5, legend: false),
      image("/assets/paper_excerpts/P_encounter__0.05__0.095.png")
    )
  },
  caption: [
    Fajok számának alakulása a párosodási valószínűség ($P_"encounter"$) függvényében.

    Felül: a reimplementációk eredményei.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  {
    show: lq.layout
    grid(
      columns: (1fr),
      gutter: 12pt,
      netlogo_species_plot("/data/NetLogo-p_mutation.csv", [$P_"mutation"$]),
      avg_species_plot("/data/p_mutation_0.00-0.50.csv", "p_mutation", legend: false),
      image("/assets/paper_excerpts/P_mutation__0__0.5.png")
    )
  },
  caption: [
    Fajok számának alakulása a génmutáció valószínűségének ($P_"mutation"$) függvényében

    Felül: a reimplementációk eredményei.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  {
    show: lq.layout
    grid(
      columns: (1fr),
      gutter: 12pt,
      netlogo_species_plot("/data/NetLogo-p_crossing.csv", [$P_"crossing"$]),
      avg_species_plot("/data/p_crossing_0.00-0.80.csv", "p_crossing", legend: false),
      image("/assets/paper_excerpts/P_crossing__0__0.5.png")
    )
  },
  caption: [
    Fajok számának alakulása a gyermekek génjeinek diverzifikálódásának ($P_"crossing"$) függvényében.

    Felül: a reimplementációk eredményei.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  {
    show: lq.layout
    grid(
      columns: (1fr),
      gutter: 12pt,
      netlogo_species_plot("/data/NetLogo-p_change.csv", [$P_"change"$], cap: 20),
      avg_species_plot("/data/p_change_0.0005-0.001.csv", "p_change", cap: 20, legend: false),
      image("/assets/paper_excerpts/P_change__0.0005__0.001.png")
    )
  },
  caption: [
    Fajok számának alakulása az új gének aktivációjának valószínűségének ($P_"change"$) függvényében.

    Felül: a reimplementációk eredményei.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  {
    show: lq.layout
    grid(
      rows: (190pt, 180pt, 212pt),
      columns: (1fr),
      gutter: 12pt,
      netlogo_species_plot("/data/NetLogo-m_limit.csv", [$M_"limit"$], cap: 30),
      avg_species_plot("/data/p_change_0.0005_m_limit_0-20.csv", "m_limit", cap: 30, legend: false),
      image("/assets/paper_excerpts/M_limit__0__20.png")
    )
  },
  caption: [
    Fajok számának alakulása a párosodási preferencia küszöbértékének ($M_"limit"$) függvényében. $P_"change" = 0.0005$

    Felül: a reimplementációk eredményei.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  {
    show: lq.layout
    grid(
      rows: (190pt, 180pt, 212pt),
      columns: (1fr),
      gutter: 12pt,
      netlogo_species_plot("/data/NetLogo-v_stretch.csv", [$V_"stretch"$], cap: 6),
      avg_species_plot("/data/p_change_0.0005_v_stretch_1-20.csv", "v_stretch", cap: 6, legend: false),
      image("/assets/paper_excerpts/V_stretch__1__20.png")
    )
  },
  caption: [
    Fajok számának alakulása a _"stretch"_ formula együtthatójának ($V_"stretch"$) függvényében. $P_"change" = 0.0005$

    Felül: a reimplementációk eredményei.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
