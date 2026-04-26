#import "/lib/plot.typ": *
#import "@preview/lilaq:0.6.0" as lq

== Teljesítmény <performance>

Megfigyelhető, hogy a fajszámláló algoritmusoknál fontosabb szempont a különböző fajok száma, mint az egyedek száma. A _"Single"_ esetekben minden egyed egy fajba tartozott, míg a _"Many"_ esetekben minden faj külön fajba. Alacsony fajszám mellett a mélységi bejárás teljesít jobban, míg sok faj esetén a diszjunkt-halmaz algoritmus.

A szimuláció futásideje lineáris, ha az egyedek halhatatlanok és nem szaporodnak. A mérés során a fajszámlálás le volt tiltva.

#figure(
  {
    show: lq.layout
    grid(
      columns: (1fr),
      gutter: 12pt,
      perf_plot(
        [Populáció],
        (
          (
            path: "/data/benchmark-simulator-nochurn-NetLogo.csv",
            label: [NetLogo 6.4.0],
            skip: 7,
            x: 0,
            y: 2
          ),
          (
            path: "/data/benchmark-simulator-nochurn-libfatint.csv",
            label: [libfatint],
            skip: 0,
            x: 0,
            y: 1
          )
        )
      ),
      perf_plot(
        [$E_"increase"$],
        (
          (
            path: "/data/benchmark-simulator-churn-NetLogo.csv",
            label: [NetLogo 6.4.0],
            skip: 7,
            x: 0,
            y: 2
          ),
          (
            path: "/data/benchmark-simulator-churn-libfatint.csv",
            label: [libfatint],
            skip: 0,
            x: 0,
            y: 1
          )
        )
      ),
      perf_plot(
        [Populáció],
        (
          (
            path: "/data/benchmark-species-counter-dfs-one-species-NetLogo.csv",
            label: [NetLogo, DFS, egy faj],
            skip: 7,
            x: 0,
            y: 2
          ),
          (
            path: "/data/benchmark-species-counter-dfs-many-species-NetLogo.csv",
            label: [NetLogo, DFS, sok faj],
            skip: 7,
            x: 0,
            y: 2
          ),
          (
            path: "/data/benchmark-species-counter-ds-one-species-NetLogo.csv",
            label: [NetLogo, DS, egy faj],
            skip: 7,
            x: 0,
            y: 2
          ),
          (
            path: "/data/benchmark-species-counter-ds-many-species-NetLogo.csv",
            label: [NetLogo, DS, sok faj],
            skip: 7,
            x: 0,
            y: 2
          ),
          (
            path: "/data/benchmark-species-counter-dfs-one-species-libfatint.csv",
            label: [libfatint, DFS, egy faj],
            skip: 0,
            x: 0,
            y: 1
          ),
          (
            path: "/data/benchmark-species-counter-dfs-many-species-libfatint.csv",
            label: [libfatint, DFS, sok faj],
            skip: 0,
            x: 0,
            y: 1
          ),
          (
            path: "/data/benchmark-species-counter-ds-one-species-libfatint.csv",
            label: [libfatint, DS, egy faj],
            skip: 0,
            x: 0,
            y: 1
          ),
          (
            path: "/data/benchmark-species-counter-ds-many-species-libfatint.csv",
            label: [libfatint, DS, sok faj],
            skip: 0,
            x: 0,
            y: 1
          )
        )
      )
    )
  },
  caption: [
    Szimuláció futásideje a környezet egyedeltartó képességének függvényében.
  ]
)

A szimuláció futásideje exponenciálisan nő, ahogy a környezet egyre több egyedet képes eltartani, ezzel jelentősen növelve a populációból való törtlések és hozzáadások számát.
