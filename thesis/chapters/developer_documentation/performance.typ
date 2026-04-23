#import "/lib/plot.typ": *
#import "@preview/lilaq:0.6.0" as lq

== Teljesítmény

#figure(
  {
    show: lq.layout
    grid(
      columns: (1fr),
      gutter: 12pt,
      netlogo_species_counter_perf_plot((
        (
          path: "/data/benchmark-species-counter-dfs-one-species-NetLogo.csv",
          label: [DFS, közös faj]
        ),
        (
          path: "/data/benchmark-species-counter-dfs-many-species-NetLogo.csv",
          label: [DFS, külön fajok]
        ),
        (
          path: "/data/benchmark-species-counter-ds-one-species-NetLogo.csv",
          label: [DS, közös faj]
        ),
        (
          path: "/data/benchmark-species-counter-ds-many-species-NetLogo.csv",
          label: [DS, külön fajok]
        )
      )),
      libfatint_species_counter_perf_plot((
        (
          path: "/data/benchmark-species-counter-dfs-one-species-libfatint.csv",
          label: [DFS, közös faj]
        ),
        (
          path: "/data/benchmark-species-counter-dfs-many-species-libfatint.csv",
          label: [DFS, külön fajok]
        ),
        (
          path: "/data/benchmark-species-counter-ds-one-species-libfatint.csv",
          label: [DS, közös faj]
        ),
        (
          path: "/data/benchmark-species-counter-ds-many-species-libfatint.csv",
          label: [DS, külön fajok]
        )
      )),
    )
  },
  caption: [
    Fajszámlálási idő az egyedek számának függvényében (logaritmikus ábrázolás). _"Single"_: Minden egyed közös fajhoz tartozik. _"Many"_: Minden egyed külön fajhoz tartozik.
  ]
)

Megfigyelhető, hogy a fajszámláló algoritmusoknál fontosabb szempont a különböző fajok száma, mint az egyedek száma. A _"Single"_ esetekben minden egyed egy fajba tartozott, míg a _"Many"_ esetekben minden faj külön fajba. Alacsony fajszám mellett a mélységi bejárás teljesít jobban, míg sok faj esetén a diszjunkt-halmaz algoritmus.

A szimuláció futásideje lineáris, ha az egyedek halhatatlanok és nem szaporodnak. A mérés során a fajszámlálás le volt tiltva.

#figure(
  {
    show: lq.layout
    grid(
      columns: (1fr),
      gutter: 12pt,
      netlogo_simulator_perf_plot((
        (
          path: "/data/benchmark-simulator-nochurn-NetLogo.csv",
          label: [Hallhatatlan, steril egyedek]
        ),
        (
          path: "/data/benchmark-simulator-churn-NetLogo.csv",
          label: [Normál működés]
        )
      )),
      libfatint_simulator_perf_plot((
        (
          path: "/data/benchmark-simulator-nochurn-libfatint.csv",
          label: [Hallhatatlan, steril egyedek]
        ),
        (
          path: "/data/benchmark-simulator-churn-libfatint.csv",
          label: [Normál működés]
        )
      ))
    )
  },
  caption: [
    Szimuláció futásideje a környezet egyedeltartó képességének függvényében.
  ]
)

A szimuláció futásideje exponenciálisan nő, ahogy a környezet egyre több egyedet képes eltartani, ezzel jelentősen növelve a populációból való törtlések és hozzáadások számát.
