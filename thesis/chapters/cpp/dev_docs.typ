#import "/lib/elteikthesis.typ": todo
#import "/lib/plot.typ": *

== Fejlesztői dokumentáció (C++) <cpp-spec>

Egy parancssori eszköz és könyvtár a FATINT modell alapú szimulációk futtatására. Bővebben a felhasználói dokumentációban: @cpp-user-manual.

=== Architektúra

A C++ implementáció erősen épít a _"Stratégia"_ fejlesztési mintára, mert a szimuláció minden eleme, a genetikus algorimusoktól a fajszámolásig egy-egy különálló, cserélhető algoritmus, melyeket az `Simulator` osztály hangol össze.

#todo("Describe pluggable nature, strategy pattern and the available modules")

#figure(
[
```pintora
classDiagram
  class Simulator {
    - ISimilarity similarity
    - ISelection selection
    - IReproduction reproduction
    - IValidator validator
    - IAlleleAdder allele_adder
    - ISpeciesCounter species_counter
    + RunStates run()
  }

  class ISimilarity {
    + float diatance(a, b)
  }
  class ISelection {
    + usize select(entities, limits, similarity)
  }
  ISimilarity -- ISelection

  class IReproduction {
    + Entity reproduce(a, b, limits)
  }
  class IValidator {

  }
  class IAlleleAdder {

  }
  class ISpeciesCounter {

  }

  Simulator o-- ISimilarity
  Simulator o-- ISelection
  Simulator o-- IReproduction
  Simulator o-- IValidator
  Simulator o-- IAlleleAdder
  Simulator o-- ISpeciesCounter

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
],
supplement: "Diagram",
caption: [A `Simulator` osztály és alkotóelemeinek osztálydiagramja]
) <libfatint-simulator-class-diagram>

A szimuláció fontosabb komponensei interfészként vannak definiálva:

/ ISimilarity: távolságmetrika, mellyel meghatározható, hogy mely egyedek kompatibilisek egymással. Pl. a genotípusaik euklédeszi távolsága.
/ ISelection: Keres egy kompatibilis párt egy adott egyedhez.
/ IReproduction: Kombinálja két szülő egyed tulajdonságait egy gyermek egyedben. Pl. `GeneticReproduction`.
/ IValidator: Ellenőrzi, hogy egy egyed megfelel-e a szimulációs paraméterekben megszabott határoknak, például hogy a génjei a megszabott $[V_"min", V_"max"]$ allélhalmazba esnek-e.
/ IAlleleAdder: Meghatározza egy egyed genotípusa alapján a következő aktiválandó gént. Pl. `RandomAlleleAdder` vagy `StretchMethodAlleleAdder`.
/ ISpeciesCounter: Megszámolja a párzási preferenciák mentén elkülöníthető fajok számát. Pl. `DepthFirstSearchSpeciesCounter` vagy `DisjointSetsSpeciesCounter`. Az implementáció nem lehet hatással a végeredményre.
/ IMutation: A `GeneticReproduction` mutációs operátora. Az gyermekegyed génjeit módosítja.
/ ICrossover: A `GeneticReproduction` keresztezés operátora. A két szülő egyed génjeit kombinája egy gyermekegyedben.

#todo("The class diagram is incomplete, finish it")

Az egyes elemek egy adatcsővezetéket (_"data pipeline"_) alkotnak.

Az `ExperimentSweep` példány `Experiment` osztályok példányosításával létrehozza a kezdeti paraméter objektumokat (`RunParameters`), melyeket egy-egy `Simulator` példány dolgoz fel. Ezek a példányok a állapotuk alakulálását egy-egy `RunStates` objektumban rögzíti, melyeket az `Experiment` osztály az `ExperimentStates` objektumba gyűjt, melyeket az `ExperimentSweep` osztály pedig egy végső `ExperimentSweepStates` objektumba. Ez az objektum és egy kísérletsor teljes végeredménye, melyből egy `StatisticsEvaluator` nevű osztály képes `ExperimentSweepResults` típusú, statisztákat tartalmazó objektummá alakítani. Ezutóbbi objtumokat pedig egy `CSVWriter` vagy `SVGWriter` kiírja fájlba vagy a standard kimenetre.

#figure(
[
```pintora
sequenceDiagram
  participant Main
  participant ExperimentSweep
  participant [<collections> Experiment]
  participant [<collections> Simulator]
  participant StatisticsEvaluator
  participant IOutputWriter

  Main ->> ExperimentSweep : ExperimentSweepParameters
  ExperimentSweep ->> Experiment : ExperimentParameters
  Experiment ->> Simulator : RunParameters
  Simulator ->> Experiment : RunStates
  Experiment ->> ExperimentSweep : ExperimentStates
  ExperimentSweep ->> Main : ExperimentSweepStates
  Main ->> StatisticsEvaluator : ExperimentSweepStates
  StatisticsEvaluator ->> Main : ExperimentSweepResults
  Main ->> IOutputWriter : ExperimentSweepResults
```
],
supplement: "Diagram",
caption: [A `fatint` program és a `libfatint` könyvtár adatfolyama]
)
#todo[Some classes were since removed, so this is no longer accurate]

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
