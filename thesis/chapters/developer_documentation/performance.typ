#import "/lib/plot.typ": *

== Teljesítmény

#figure(
  align(left)[
    #netlogo_species_counter_perf_plot("/data/NetLogo_species_counter_perf.csv"),
    #species_counter_perf_plot("/data/species_counter_perf_3.csv")
  ],
  caption: [
    Fajszámlálási idő az egyedek számának függvényében (logaritmikus ábrázolás). _"Single"_: Minden egyed közös fajhoz tartozik. _"Many"_: Minden egyed külön fajhoz tartozik.
  ]
)

Megfigyelhető, hogy a fajszámláló algoritmusoknál fontosabb szempont a különböző fajok száma, mint az egyedek száma. A _"Single"_ esetekben minden egyed egy fajba tartozott, míg a _"Many"_ esetekben minden faj külön fajba. Alacsony fajszám mellett a mélységi bejárás teljesít jobban, míg sok faj esetén a diszjunkt-halmaz algoritmus.

#figure(
  simulator_perf_plot("/data/simulator_no_churn_perf.csv"),
  caption: [
    Szimuláció futásideje az egyedek számának függvényében. Hallhatatlan, steril egyedek.
  ]
)

A szimuláció futásideje lineáris, ha az egyedek halhatatlanok és nem szaporodnak. A mérés során a fajszámlálás le volt tiltva.

#figure(
  simulator_perf_plot("/data/simulator_churn_perf.csv"),
  caption: [
  Szimuláció futásideje a környezet egyedeltartó képességének függvényében.
  ]
)

A szimuláció futásideje exponenciálisan nő, ahogy a környezet egyre több egyedet képes eltartani, ezzel jelentősen növelve a populációból való törtlések és hozzáadások számát.
