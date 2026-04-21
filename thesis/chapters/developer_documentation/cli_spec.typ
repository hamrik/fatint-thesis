#import "/lib/elteikthesis.typ": todo
#import "/lib/plot.typ": *

== C++ implementáció <cli-spec>

Egy parancssori eszköz és könyvtár a FATINT modell alapú szimulációk futtatására. Bővebben a felhasználói dokumentációban: @cli-user-manual.

=== Architektúra

A C++ implementáció erősen épít a _"Stratégia"_ fejlesztési mintára, mert a szimuláció minden eleme, a genetikus algorimusoktól a fajszámolásig egy-egy különálló, cserélhető algoritmus, melyeket az `Simulator` osztály hangol össze.

#todo("Describe pluggable nature, strategy pattern and the available modules")

#import "@preview/pintorita:0.1.4"
#show raw.where(lang: "pintorita"): it => pintorita.render(it.text)
```pintorita
classDiagram
  class Simulator {
    - ISimilarity similarity
    - ISelection selection
    - IReproduction reproduction
    - IValidator validator
    - IAlleleAdder allele_adder
    - ISpeciesCounter species_counter
  }

  class ISimilarity {

  }
  class ISelection {

  }
  class IReproduction {

  }
  class IValidator {

  }
  class IAlleleAdder {

  }
  class ISpeciesCounter {

  }

  Simulator *-- ISimilarity
  Simulator *-- ISelection
  Simulator *-- IReproduction
  Simulator *-- IValidator
  Simulator *-- IAlleleAdder
  Simulator *-- ISpeciesCounter

  class GeneticReproduction {
    - IMutation mutation
    - ICrossover crossover
  }
  IReproduction <|.. GeneticReproduction

  class IMutation {

  }
  GeneticReproduction *-- IMutation

  class ICrossover {

  }
  GeneticReproduction *-- ICrossover

  class MutationImpl {

  }
  IMutation <|.. MutationImpl

  class CrossoverImpl {

  }
  ICrossover <|.. CrossoverImpl

  class SimilarityImpl {

  }
  ISimilarity <|.. SimilarityImpl

  class SelectionImpl {

  }
  ISelection <|.. SelectionImpl

  class ValidatorImpl {

  }
  IValidator <|.. ValidatorImpl

  class RandomAlleleAdder {

  }
  IAlleleAdder <|-- RandomAlleleAdder

  class StretchAlleleAdder {

  }
  IAlleleAdder <|-- StretchAlleleAdder

  class DisjointSetsSpeciesCounter {

  }
  ISpeciesCounter <|.. DisjointSetsSpeciesCounter
```

#todo("The class diagram is incomplete, finish it")

=== Forráskód fordítása <build-from-source>

A forráskód fordításához a következő elemekre van szükség:

- *CMake* 3.11 vagy újabb
- Egy C++20 szabványt támogató *C++ fordító* (pl. GCC 9 vagy újabb)
- Intel Thread Building Blocks (Elhagyható, de ajánlott, különben a szimuláció egyetlen szálon fog futni, jelentősen lassítva azt)

#todo("Migrate from TBB to hand-built job queue")

Minden további függőséget már tartalmaz a repó.

A fordításhoz nyisson egy parancssort a repó gyökérmappájában, majd adja ki a következő parancsokat:

```bash
$ cmake -S . -B ./build -DCMAKE_BUILD_TYPE=Release
$ cmake --build build --parallel
```

A kész program a `./build/fatint` mappába kerül.

=== Tesztek futtatása

A C++ implementáció tesztelésekor meg kell győződni arról, hogy a modell ugyanúgy viselkedik,
ahogy a @fatint cikkben le van írva, továbbá, hogy az eredmények reprodukálhatóak. Ezt egység-
és integrációs tesztekkel érjük el, melyeket a repóban beállított CI pipeline is lefuttat minden
commit feltöltése után.

==== Automatizált tesztek

A fenti fordítási parancsok előállítanak számos egység- és integrációs tesztet is.
Ezek a tesztek a `ctest` eszközzel indíthatók, a `build` mappában állva:

```bash
$ cd build
build$ ctest
```

A CTest eszköz egy összefoglalást fog kiírni a sikeresen futtatott tesztekről,
és részleteket biztosít a sikertelenül lefutó tesztekről.

A C++ implementáció tesztjei a `doctest` könytárat használják, és a következőkről bizonyosodnak meg:

- `genetics/`
  - A genetikai operátorok, mint a kereszteződés és mutáció, helyesen viselkednek.
- `math/`:
  - A véletlenszám generátor segédfüggvények a megfelelő valószínűséggel, reprodukálható módon működnek.
  - A kiszámolt statisztikák helyesek.
  - #todo("Test numerical stability when calculating stats for a large array")
- `measurement/`:
  - A Diszjunkt-Halmaz alapú fajszámláló helyesen működik.
  - A tárolós (Reservoir) mintavételezési algoritmus egyenletes eloszlással működik.
- `model/`:
  - A modell egyenletei a @fatint cikkhez hűen vannak implementálva.
  - A doméntípusok operátorai helyesen működnek.
- `simulation/`:
  - A kísérlet sorozatok valóban csak egyetlen paramétert módosítanak, és azt is helyesen.

A `simulation/` mappa integrációs teszteket is tartalmaz:

  - A szimuláció során az egyedek idővel "éhen halnak", és ha a szaporodás feltételei nem adottak, a teljes populáció 30 lépésen belül eltűnik.
  - A szimuláció új géneket vezet be ha a szaporodás feltételei biztosítottak és a $P_"change"$ paraméter értéke pozitív.
  - A szimuláció eredményei reprodukálhatóak több futtatás után is, amennyiben a véletlen szám generátor kezdőállapota állandó.

==== Kézi tesztelés

Az kapott eredmények kiértékelése kézzel történik. Összehasonlításra kerülnek a NetLogo implementáció eredményeivel.
Azonos paraméterek azonos viselkedést kell kiváltsanak (de nem azonos számokat).

Mindkét implementációban úgy vannak megválasztva az alapértelmezett értékek, hogy minél kevesebb beállítást kelljen módosítani.

A @fatint cikkben szereplő kísérletek adaptált megfelelői a következők

```bash
fatint -e 11 --p_encounter 0.05 --sweep_p_encounter 0.005 --output  p_encounter_0.05-0.10.csv
fatint -e 11 --p_encounter 0.05 --sweep_p_encounter 0.005 -f svg --output p_encounter_0.05-0.10.svg

fatint -e 6 --p_mutation 0 --sweep_p_mutation 0.1 --output p_mutation_0.00-0.50.csv
fatint -e 6 --p_mutation 0 --sweep_p_mutation 0.1 -f svg --output p_mutation_0.00-0.50.svg

fatint -e 9 --p_crossing 0 --sweep_p_crossing 0.1 --output p_crossing_0.00-0.80.csv
fatint -e 9 --p_crossing 0 --sweep_p_crossing 0.1 -f svg --output p_crossing_0.00-0.80.svg

fatint -e 11 --p_change 0.0005 --sweep_p_change 0.00005 --output p_change_0.0005-0.001.csv
fatint -e 11 --p_change 0.0005 --sweep_p_change 0.00005 -f svg --output p_change_0.0005-0.001.svg

fatint -e 21 --p_change 0.0005 --m_limit 0 --sweep_m_limit 1 --output p_change_0.0005_m_limit_0-20.csv
fatint -e 21 --p_change 0.0005 --m_limit 0 --sweep_m_limit 1 -f svg --output p_change_0.0005_m_limit_0-20.svg

fatint -e 20 --p_change 0.0005 --v_stretch 1 --sweep_v_stretch 1 --output p_change_0.0005_v_stretch_1-20.csv
fatint -e 20 --p_change 0.0005 --v_stretch 1 --sweep_v_stretch 1 -f svg --output p_change_0.0005_v_stretch_1-20.svg
```

#todo("Add command-line option to output multiple formats at once")

#todo([
  Explore better alternatives to "eyeballing it", such as:
  - Comparing graph characteristics
  - Computing Cross-Correlation, Dynamic Time Wapring or Fréchet distance
  - Comparing inter-spike intervals
])

#todo("Contextualize the results below")
#todo("Include NetLogo results and compare, verify identical behavior")
#todo("There is a clear regression in the C++ implementation. Find and fit it ASAP")

== Teljesítmény

#todo("Move to proper place")

#figure(
  species_counter_perf_plot("/data/species_counter_perf_3.csv"),
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

= Eredmények

#figure(
  [
    #netlogo_species_plot("/data/NetLogo-default_params.csv", [Starting population])
    #avg_species_plot("/data/default_params.csv", "starting_population")
    #image("/assets/paper_excerpts/default_params.png")
  ],
  caption: [
    Fajok számának alakulása alapértelmezett beállítások mellett.

    Felül: a C++ implementáció eredménye.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  [
    #netlogo_species_plot("/data/NetLogo-p_encounter.csv", [$P_"encounter"$])
    #avg_species_plot("/data/p_encounter_0.05-0.10.csv", "p_encounter", cap: 5)
    #image("/assets/paper_excerpts/P_encounter__0.05__0.095.png")
  ],
  caption: [
    Fajok számának alakulása a párosodási valószínűség ($P_"encounter"$) függvényében.

    Felül: a C++ implementáció eredménye.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  [
    #netlogo_species_plot("/data/NetLogo-p_mutation.csv", [$P_"mutation"$])
    #avg_species_plot("/data/p_mutation_0.00-0.50.csv", "p_mutation")
    #image("/assets/paper_excerpts/P_mutation__0__0.5.png")
  ],
  caption: [
    Fajok számának alakulása a génmutáció valószínűségének ($P_"mutation"$) függvényében

    Felül: a C++ implementáció eredménye.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  [
    #netlogo_species_plot("/data/NetLogo-p_crossing.csv", [$P_"crossing"$])
    #avg_species_plot("/data/p_crossing_0.00-0.80.csv", "p_crossing")
    #image("/assets/paper_excerpts/P_crossing__0__0.5.png")
  ],
  caption: [
    Fajok számának alakulása a gyermekek génjeinek diverzifikálódásának ($P_"crossing"$) függvényében.

    Felül: a C++ implementáció eredménye.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  [
    #netlogo_species_plot("/data/NetLogo-p_change.csv", [$P_"change"$], cap: 20)
    #avg_species_plot("/data/p_change_0.0005-0.001.csv", "p_change", cap: 20)
    #image("/assets/paper_excerpts/P_change__0.0005__0.001.png")
  ],
  caption: [
    Fajok számának alakulása az új gének aktivációjának valószínűségének ($P_"change"$) függvényében.

    Felül: a C++ implementáció eredménye.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  [
    #netlogo_species_plot("/data/NetLogo-m_limit.csv", [$M_"limit"$], cap: 30)
    #avg_species_plot("/data/p_change_0.0005_m_limit_0-20.csv", "m_limit", cap: 30)
    #image("/assets/paper_excerpts/M_limit__0__20.png")
  ],
  caption: [
    Fajok számának alakulása a párosodási preferencia küszöbértékének ($M_"limit"$) függvényében. $P_"change" = 0.0005$

    Felül: a C++ implementáció eredménye.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
#figure(
  [
    #netlogo_species_plot("/data/NetLogo-v_stretch.csv", [$V_"stretch"$], cap: 6)
    #avg_species_plot("/data/p_change_0.0005_v_stretch_1-20.csv", "v_stretch", cap: 6)
    #image("/assets/paper_excerpts/V_stretch__1__20.png")
  ],
  caption: [
    Fajok számának alakulása a _"stretch"_ formula együtthatójának ($V_"stretch"$) függvényében. $P_"change" = 0.0005$

    Felül: a C++ implementáció eredménye.
    Alul: a @fatint cikkből kiragadott grafikon.
  ]
)
