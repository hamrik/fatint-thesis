#import "/lib/elteikthesis.typ": todo
#import "/lib/plot.typ": *

== Fejlesztői dokumentáció (C++) <cpp-spec>

A fejlesztői dokumentáció részletezi a FATINT modell C++ implementációjának
működési követelményeit, az implementációban meghozott döntéseket és tesztelés
menetét.

=== Specifikáció

A C++ implementáció feladata a FATINT (@model-desc) modell pontos szimulációja,
és a @fatint cikkben közölt adatok replikációja. Ehhez nyújt egy könyvtárat és
parancssori eszközt, mellyel könnyen és gyorsan futtathatók kísérletek és
kísérletsorok.

==== Funkciónális követelmények

Az implementáció:
- Lehetőséget nyújt a @model-params fejezetben szereplő összes paraméter
  beállítására.
- Ellenőrzi a felhasználó által megadott paramétereket és jelenti a hibákat.
- A modell pontosan követi a @model-desc fejezetben leírt viselkedést.
- Lehetőséget nyújt kísérletek és kísérletsorok futtatására.
- Lehetőséget nyújt a kísérlet vagy kísérletsor ereményeinek
  táblázat vagy grafikon formájában történő mentésére.
- Az @cpp-usecase diagramon ábrázolt felhasználói eseteket támogatja.

==== Nem funkcionális követelmények

- A program kapcsolói és azok súgója logikus és áttekinthető.
- Az implementáció nem függ a C++ standard könyvtárán és annak tranzitív
  függőségein kívül további külső elemtől.
- A szimuláció nem fut hibára, feltéve, hogy a felhasználó által megadott
  kiinduló paraméterek a @model-defaults táblában szereplő tartományokba esnek.
- Az implementáció igyekszik takarékoskodni a memóriával és a számítási
  kapacitással.
- Egy 200 szimulációból, szimulációnként legfeljebb 6000 lépésből álló
  kísérletsort 30 másodpercen belül lefuttat egy munkaállomás kategóriás
  számítógépen.
- Minden kísérlet terminál.

==== Felhasználói esetek

A C++ implementáció nem egy interaktív eszköz. A kezdő paramétereket a
felhasználó a parancssorban adja meg. A program induláskor ellenőrzi a megadoott
paraméterek helyességét, és probléma esetén tájékoztatja a felhasználót a
hibáról. Ha a paraméterek megfelelnek a @model-defaults táblázatban
foglaltaknak, a program a kísérletsor lefutásáig nem nyújt további visszajelzést
a felhasználónak. Ha a felhasználó nem adott meg mentési útvonalat, a program a
standard kimenetre írja az ereményeket, lehetővé téve azok szkriptekben vagy
UNIX csőveezetékeken keresztül történő további feldolgozását. Ha a felhasználó
megadott egy mentési útvonalat, a program az eredményeket a megadott útvonalú
fájlba írja, majd csendben kilép.

#figure(
  image("/assets/diagrams/cpp_usecase.svg", width: 80%),
  caption: [
    A C++ implementáció felhasználói eset diagramja
  ],
) <cpp-usecase>

==== Felhasználói történetek

A felhasználó kísérleteket szeretne futtatni, hogy elemezhesse a FATINT modell
viselkedését. Az implementáció akkor működik megfelelően, ha a @cpp-gwt
táblázatban szereplő kapcsoló kombinációkra a táblázatban előírt módon reagál.

#figure(
  table(
    columns: 3,
    table.header[*GIVEN / Feltéve, hogy a felhasználó...*][*WHEN / Amikor...*][*THEN / Akkor...*],

    [-],
    [A felhasználó elindítja a programot a `--help` kapcsolóval],
    [A program kiírja a súgót.],

    [-],
    [A felhasználó elindítja a programot, de nem ad meg egyetlen paramétert sem],
    [A program lefuttat 10 szimulációt alapértelmezett paraméterekkel, a statisztikákat a standard kimenetre írja, majd kilép.],

    [Hibás parancssori paramétereket adott meg],
    [A felhasználó elindítja a programot],
    [A program tájékoztatja a felhasználót a hibáról, majd kilép.],

    [Helyes parancssori paramétereket adott meg],
    [A felhasználó elindítja a programot mentési útvonal nélkül],
    [A program a szimulációk statisztikáit CSV formátumban a standard kimenetre írja, majd kilép],

    [Helyes parancssori paramétereket adott meg],
    [A felhasználó elindítja a programot `--output` kapcsolóban megadva a mentési útvonalat],
    [A program a szimulációk statisztikáit CSV formátumban a megadott fájlba írja, majd kilép],

    [Helyes parancssori paramétereket adott meg, és a `--format` kapcsolót `SVG`-re állította],
    [A felhasználó elindítja a programot mentési útvonal nélkül],
    [A program a szimulációk statisztikáit grafinonon ábrolja SVG formátumban, a grafikon forráskódját a standard kimenetre írja, majd kilép],

    [Helyes parancssori paramétereket adott meg, és a `--format` kapcsolót `SVG`-re állította],
    [A felhasználó elindítja a programot `--output` kapcsolóban megadva a mentési útvonalat],
    [A program a szimulációk statisztikáit grafinonon ábrolja SVG formátumban, a grafikon forráskódját a megadott fájlba írja, majd kilép],
  ),
  caption: "A C++ implementáció elvárt viselkedése a paraméterek függvényében",
) <cpp-gwt>

=== Architektúra

A C++ implementáció erősen épít a _"Stratégia"_ fejlesztési mintára. A
szimuláció minden eleme, a genetikus algorimusoktól a fajszámolásig egy-egy
különálló, cserélhető algoritmus. Az egyes elemek egy adatcsővezetéket
(_"data pipeline"_) alkotnak, melyek között az adatfolyamot a `Simulator`
osztály szervezi, lásd @libfatint-dataflow diagram.

#figure(
  image("/assets/diagrams/cpp_dataflow.svg"),
  caption: [A `fatint` program és a `libfatint` könyvtár adatfolyama]
) <libfatint-dataflow>

#todo[Some classes were since removed, so this is no longer accurate]

A szimuláció fontosabb komponensei interfészként vannak definiálva:

/ ISimilarity: távolságmetrika, mellyel meghatározható, hogy mely egyedek kompatibilisek egymással. Pl. a genotípusaik euklédeszi távolsága.
/ ISelection: Keres egy kompatibilis párt egy adott egyedhez.
/ IReproduction: Kombinálja két szülő egyed tulajdonságait egy gyermek egyedben. Pl. `GeneticReproduction`.
/ IValidator: Ellenőrzi, hogy egy egyed megfelel-e a szimulációs paraméterekben megszabott határoknak, például hogy a génjei a megszabott $[V_"min", V_"max"]$ allélhalmazba esnek-e.
/ IAlleleAdder: Meghatározza egy egyed genotípusa alapján a következő aktiválandó gént. Pl. `RandomGeneAdder` vagy `VStretchGeneAdder`.
/ ISpeciesCounter: Megszámolja a párzási preferenciák mentén elkülöníthető fajok számát. Pl. `DepthFirstSearchSpeciesCounter` vagy `DisjointSetsSpeciesCounter`. Az implementáció nem lehet hatással a végeredményre.
/ IMutation: A `GeneticReproduction` mutációs operátora. Az gyermekegyed génjeit módosítja.
/ ICrossover: A `GeneticReproduction` keresztezés operátora. A két szülő egyed génjeit kombinája egy gyermekegyedben.

Minden interfész egy tiszta függvény, nem tartalmazhatnak állapotot. Ez
garantálja, hogy a több szimuláció több szálon egyszerre használhassa ugyanazon
példányokat koordináció nélkül, mégis reprodukálható módon, versenyhelyzetek
nélkül.

Az interfészeket, azok kapcsolatát és implementációikat a
@libfatint-simulator-class-diagram, @libfatint-simulator-params-diagram,
@libfatint-simulator-usages-diagram és @libfatint-experiment-class-diagram
diagramok részletezik. Az összetettség csökkentése érdekében az ábrán látható
osztályok egyszerűsítve vannak ábrázolva a forráshoz képest.
Diagramon szereplő összes osztály összes mezője érték ha primitív és
`unique_ptr`-en keresztül birtokolt példány, ha implementáció. Minden osztály
rendelkezik egy minden mezőt átvevő konstruktorral. A diagramon `&` jelöli azon
referenciákat, melyeket a metódus módosíthat. Minden egyéb argumentum vagy
konstans referencia, vagy érték.

#figure(
  image("/assets/diagrams/cpp_simulator_classes.svg"),
  caption: [A `Simulator` osztály és függőségeinek osztálydiagramja]
) <libfatint-simulator-class-diagram>
#figure(
  image("/assets/diagrams/cpp_simulator_params.svg"),
  caption: [A `Simulator` osztály és paramétereinek osztálydiagramja]
) <libfatint-simulator-params-diagram>
#figure(
  image("/assets/diagrams/cpp_simulator_usages.svg"),
  caption: [A `Simulator` osztály és az álatala használt típusok osztálydiagramja]
) <libfatint-simulator-usages-diagram>
#figure(
  image("/assets/diagrams/cpp_experiment_classes.svg", width: 60%),
  caption: [A kísérletsorok és alkotóelemeinek osztálydiagramja]
) <libfatint-experiment-class-diagram>

=== Forráskód fordítása <build-from-source>

A forráskód fordításához a következő elemekre van szükség:

- *CMake* 3.11 vagy újabb.
- Egy C++20 szabványt támogató *C++ fordító* (pl. GCC 9 vagy újabb)
- *Intel Thread Building Blocks*.
  A C++ standard könyvtárának parallel algoritmusait implementálja.
  Egyes standard könyvtárak (például `libstdc++`) megkövetelik, mások
  (például `libc++`) nem.

Példáum Ubuntu 24.04 rendszeren a függőségeket a következő paranccsal
telepítjük:

```bash
$ sudo apt install build-essential cmake libtbb12 libtbb-dev
```

Minden további függőség a forráskód része.

A fordításhoz a projekt `fatint-cpp` könyvtárában állva kiadjuk az alábbi
parancsokat:

```bash
$ cmake -S . -B ./build -DCMAKE_BUILD_TYPE=Release
$ cmake --build build --parallel
```

A kész program a `./build` mappába kerül.

=== Tesztek futtatása

A C++ implementáció tesztelésekor meg kell győződni arról, hogy a modell
ugyanúgy viselkedik, ahogy a @fatint cikkben le van írva, továbbá, hogy az
eredmények reprodukálhatóak. Ezt egység- és integrációs tesztekkel érjük el.
A teszteket a projekt GitHub oldalán beállított CI pipeline is lefuttatja minden
kommit feltöltése után.

==== Automatizált tesztek

A fenti fordítási parancsok előállítanak számos egység- és integrációs tesztet
is. Ezek a tesztek a CMake `ctest` eszközével indíthatók, a
`build/libs/libfatint/tests` mappában állva:

```bash
$ cd build/libs/fatint/tests
tests$ ctest --output-on-failure
```

A CTest eszköz egy összefoglalást fog kiírni a sikeresen futtatott tesztekről,
és részleteket biztosít a sikertelenül lefutó tesztekről.

A C++ implementáció tesztjei a `doctest` könytárat használják, és a
következőkről bizonyosodnak meg:

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

A @fatint cikkben szereplő kísérletek adaptált megfelelői a következők:

#todo("Include NetLogo results and compare, verify identical behavior")

==== A cikk grafikonjai, mint kézi integrációs tesztek

A @fatint cikkben demonstrált kísérletsorok segítségével meggyőződhetünk róla,
hogy a C++ implmenetáció az elvárt módon viselkedik. A @fatint cikkben szereplő
összes kísérlet elvégezhető az alábbi parancsokkal:

```bash
fatint --output default_params.csv
fatint -e 11 --p_encounter 0.05 --sweep_p_encounter 0.005 --output  p_encounter_0.05-0.10.csv
fatint -e 6 --p_mutation 0 --sweep_p_mutation 0.1 --output p_mutation_0.00-0.50.csv
fatint -e 9 --p_crossing 0 --sweep_p_crossing 0.1 --output p_crossing_0.00-0.80.csv
fatint -e 11 --p_change 0.0005 --sweep_p_change 0.00005 --output p_change_0.0005-0.001.csv
fatint -e 21 --p_change 0.0005 --m_limit 0 --sweep_m_limit 1 --output p_change_0.0005_m_limit_0-20.csv
fatint -e 20 --p_change 0.0005 --v_stretch 1 --sweep_v_stretch 1 --output p_change_0.0005_v_stretch_1-20.csv
```

Alapértelmezett paraméterek mellett a fajok átlagos száma nem eshet 0-ra, lásd
@cpp-species-comp-default.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    libfatint_species_plot("/data/default-libfatint.csv", none),
    image("/assets/paper_excerpts/default_params.png", height: 20%),
  ),
  caption: [
    Fajok számának átlagos alakulása alapértelmezett beállítások mellett.

    Felül: C++ implementáció. Alul: @fatint.
  ],
) <cpp-species-comp-default>

$P_"encounter"$ alacsony értékeknél biztos kipusztulást, és magasabb értékeknél
is legfeljebb egy faj fennmaradását garantálja, lásd
@cpp-species-comp-p-encounter.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    libfatint_species_plot("/data/p_encounter-libfatint.csv", "p_encounter"),
    image("/assets/paper_excerpts/P_encounter__0.05__0.095.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $P_"encounter"$ különböző értékei mellett.

    Felül: C++ implementáció. Alul: @fatint.
  ],
) <cpp-species-comp-p-encounter>

$P_"mutation"$ magasabb értékeknél létrehozhat egy-egy rövid életű fajt, de
mivel ezen fajok gyakran egy egydből állnak, így az egyed halálával a faj is
kihal. Továbbra is egyetlen faj dominál. Lásd @cpp-species-comp-p-mutation.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    libfatint_species_plot("/data/p_mutation-libfatint.csv", "p_mutation"),
    image("/assets/paper_excerpts/P_mutation__0__0.5.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $P_"mutation"$ különböző értékei mellett.

    Felül: C++ implementáció. Alul: @fatint.
  ],
) <cpp-species-comp-p-mutation>

$P_"crossing"$ magas értékeknél hasonlóan viselkedik, mint a $P_"mutation"$
eset, lásd @cpp-species-comp-p-crossing.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    libfatint_species_plot("/data/p_crossing-libfatint.csv", "p_crossing"),
    image("/assets/paper_excerpts/P_crossing__0__0.5.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $P_"crossing"$ különböző értékei mellett.

    Felül: C++ implementáció. Alul: @fatint.
  ],
) <cpp-species-comp-p-crossing>

Ahogy a @model-desc fejezet is kifejtette, $P_"change"$ a FATINT modell egyik
legfontosabb paramétere. Ahogy a @cpp-species-comp-p-change ábrán is
látható, bármilyen nem nulla érték mellett "tüskéket" okoz a faj számokban, mert
egyszerre hat az összes egyed párosodási preferenciáira. Minél magasabb
$P_"change"$, annál gyakoribbak a tüskék.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    libfatint_species_plot("/data/p_change-libfatint.csv", "p_change", cap: 20),
    image("/assets/paper_excerpts/P_change__0.0005__0.001.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $P_"change"$ különböző értékei mellett.

    Felül: C++ implementáció. Alul: @fatint.
  ],
) <cpp-species-comp-p-change>

$P_"change" = 0.0005$-el garantálva az új gének hozzáadását, $M_"limit"$
különböző értékei arra hatással vannak a "tüskék" méretére. Minél magasabb,
annál több faj keletkezik a gének hozzáadásakor, ugyanakkor ezen fajok annál
kisebbek és rövidebb életűek. Lásd @cpp-species-comp-m-limit.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    libfatint_species_plot("/data/m_limit-libfatint.csv", "m_limit", cap: 30),
    image("/assets/paper_excerpts/M_limit__0__20.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $M_"limit"$ különböző értékei mellett.
    $P_"change" = 0.0005$.

    Felül: C++ implementáció. Alul: @fatint.
  ],
) <cpp-species-comp-m-limit>

Ha véletlenszerű gének helyett a @stretch-formula egyenletet használjuk, akkor
ahogy a @cpp-species-comp-v-stretch ábrán is látható, a létrejövő fajok
száma gének hozzáadások hirtelen megugrik, majd lassabban csökken, mint amikor
véletlenszerűen adunk az egyedekhez új géneket.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    libfatint_species_plot("/data/v_stretch-libfatint.csv", "v_stretch", cap: 6),
    image("/assets/paper_excerpts/V_stretch__1__20.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $V_"stretch"$ különböző értékei mellett.
    $P_"change" = 0.0005$.

    Felül: C++ implementáció. Alul: @fatint.
  ],
) <cpp-species-comp-v-stretch>

==== Teljesítmény

#figure(
  perf_plot(
    [Populáció],
    (
      (
        path: "/data/benchmark-species-counter-dfs-one-species-libfatint.csv",
        label: [Mélységi bejárás, egy faj],
        skip: 0,
        x: 0,
        y: 1,
      ),
      (
        path: "/data/benchmark-species-counter-dfs-many-species-libfatint.csv",
        label: [Mélységi bejárás, sok faj],
        skip: 0,
        x: 0,
        y: 1,
      ),
      (
        path: "/data/benchmark-species-counter-ds-one-species-libfatint.csv",
        label: [Diszjunkt-Halmaz, egy faj],
        skip: 0,
        x: 0,
        y: 1,
      ),
      (
        path: "/data/benchmark-species-counter-ds-many-species-libfatint.csv",
        label: [Diszjunkt-Halmaz, sok faj],
        skip: 0,
        x: 0,
        y: 1,
      ),
    ),
  ),
  caption: [
    Az élek létrehozásának és a fajszámláló algorimusok futásidejének összege a
    populáció létszámának függvényében (logaritmikus skála).
  ],
) <cpp-species-counter-perf>

#figure(
  perf_plot(
    [$E_"increase"$],
    (
      (
        path: "/data/benchmark-simulator-churn-libfatint.csv",
        label: [C++ implementáció],
        skip: 0,
        x: 0,
        y: 1,
      ),
    ),
  ),
  caption: [Egy 1000 lépéses szimuláció időigénye a környezet eltartóképességének függvényében],
) <cpp-simulation-perf>
