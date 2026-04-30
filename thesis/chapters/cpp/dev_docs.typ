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

    [-], [A felhasználó elindítja a programot a `--help` kapcsolóval], [A program kiírja a súgót.],

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

=== Implementáció részletei

==== Architektúra

A C++ implementáció erősen épít a _"Stratégia"_ fejlesztési mintára. A
szimuláció minden eleme, a genetikus algorimusoktól a fajszámolásig egy-egy
különálló, cserélhető algoritmus.

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
  caption: [A `Simulator` osztály és függőségeinek osztálydiagramja],
) <libfatint-simulator-class-diagram>
#figure(
  image("/assets/diagrams/cpp_simulator_params.svg"),
  caption: [A `Simulator` osztály és paramétereinek osztálydiagramja],
) <libfatint-simulator-params-diagram>
#figure(
  image("/assets/diagrams/cpp_simulator_usages.svg"),
  caption: [A `Simulator` osztály és az álatala használt típusok osztálydiagramja],
) <libfatint-simulator-usages-diagram>
#figure(
  image("/assets/diagrams/cpp_experiment_classes.svg", width: 60%),
  caption: [A kísérletsorok és alkotóelemeinek osztálydiagramja],
) <libfatint-experiment-class-diagram>

==== A program szakaszai

Az egyes elemek egy adatcsővezetéket (_"data pipeline"_) alkotnak, melyek között
az adatfolyamot a `Simulator` osztály szervezi, lásd @libfatint-dataflow diagram.

#figure(
  image("/assets/diagrams/cpp_dataflow.svg"),
  caption: [Az adatok transzformációja `fatint` programban és a `libfatint` könyvtárban],
) <libfatint-dataflow>

+ A program a `cxxopts` könyvtár segítségével értelmezi a parancssori
  kapcsolókat és előállít egy `ExperimentSweepParameters` objektumot. Ez az
  objektum minden, a kísérletsorral kapcsolatos paramétert tartalmaz.
+ Az `ExperimentSweepParameters::expand()` metódusa előállítja az egyes
  szimulációk `RunParameters` paramétereit, figyelembe véve a véletlenszám
  generátor kezdőállapotának inkrementálását egy kísérleten belül és a
  kísérletsor által végigsöpört paraméter inkrementálását kísérletek között.
+ A program az egyes paraméter típusokban definiált `validate()` metódussal
  ellenőrzi a kísérletsor összes paraméterét. Ha valamelyik nem megfelelő,
  (a `valiedate()` dob egy `ConstraintException` kivételt) kijelzi a hibás
  paramétert, a hiba szövegét, majd terminál.
+ Ha nincsen hiba, akkor a program minden egyes `RunParameter` objektumhoz
  felépít egy `Simulator` példányt a megadott kapcsolóknak megfelelő
  függőségekkel és a paraméterekkel, initializál egy `Random` véletlenszám
  generátort a megfelelő kezdőállapottal, majd lefuttatja a szimulációt
  (`Simulator::run`). A kapott `RunStates` állapotokat kigyűjti egy
  `ExperimentStates` gyűjteménybe. A szimulációs lépéseket a @cpp-sim-steps
  részletezi.
+ A program a `math::measure` segédfüggvénnyel minden kísérlethez lépésenkénti
  statiszikákat (`ExperimentStatistics`) állít elő az egyes kísérletek
  szimulációinak azonos lépéskori állapotából, majd a kísérletek statisztikáit
  kigyűjti egy `ExperimentSweepStatistics` gyűjteménybe.
+ A program a felhasználó által meghatározott útvonalhoz létrehoz egy kimeneti
  folyamot (`std::ostream`), a falhasználó által meghatározott adat exportálót
  (`CSVWriter` vagy `SVGWriter`) példányosítja, majd átadja az exportálónak a
  paramétereket, statisztikákat és a folyamot.
+ Az exportáló végeztével a program kilép.

==== A szimuláció menete <cpp-sim-steps>

A `Simulator::run` metódus egy teljes kísérletet lefuttat, majd visszaadja
a lépésenként mért populáció létszámot, gének számát és fajok számát. Az alábbi
lépésekből áll:

+ A szimuláció létrehoz egy új `Environment` példányt. Ez az osztály tartja
  számon a környezet energiaszintjét.
+ Létrehoz egy vektort a szimuláció állapotok tárolásához. Ezt a vektort úgy
  méretezi, hogy a megadott maximális lépésszám (`steps`) mellett futás közben
  ne kelljen újraallokálni a vektort.
+ Létehoz $M_"init"$ `Entity` egyedet egyenként $N_"init"$ méretű genotípus
  vektorral, $0$ korral és $0$ energiával.
+ A következő lépéseket a szimuláció legfeljebb `steps` alkalommal ismétli:
  - A környezet (`Environment`) energiaszintjét megnöveli $E_"increase"$
    egységgel.
  - Lefuttatja a `Simulator::tick` metódust:
    - A életben lévő entitások indexeit véletlen sorrendben összekeveri
      (`Random::random_indices`). Ez biztosítja, hogy minden egyednek igazságos
      hozzáférése legyen a közös környezeti energia készlethez.
    - A kisorsolt sorrendben minden egyedhez:
      - Az `Environment::take(`$E_"intake"$`)` metódussal kiszámolja mennyi
        energiát tud az egyed magához venni a környezetből. Ez a metódus
        egyúttal csökkentiaz energia készletet.
      - Megemeli az egyed korát eggyel, majd módosítja annak energia szintjét a
        @energy-gain-formula egyenlet (`model::energy_gain_formula()`) szerint.
  - A szimuláció töröl minden olyan egyedet, melynek energiaszintje már nem
    pozitív.
  - Lefuttatja a `Simulator::reproduce` metódust:
    - Inicializál egy $N_"new" := 0$ számlálót.
    - Minden egyedhez, melyhez egy véletlen $P_"encounter"$ feltétel teljesül,
      keres egy kompatiblis párt a kapott `ISelection::select` implementációval.
    - Ha talált egy kompatibilis párt, kiszámolja a kapott
      `ISimilarity::offspring_count` implementáció segítségével, hogy hány
      utódjuk fog születni.
    - Minden utódhoz inicializál egy új `Entity` objektumot, majd a kapott
      `IReproduction::reproduce` segítségével inicializálja az utód genotípusát.
      Az `IReproduction::reproduce` metódus visszatérési értéke egy logikai
      érték, akkor igaz, ha az utód genotípusának minden génje a megengedett
      alléltartományba esik. Ezesetben a `Simulator` hozzáadja az utódot a
      populációhoz.
    - Minden sikeresen hozzáadott utód után $P_"change"$ valószínűséggel
      inkrementálja eggyel $N_"new"$-t.
    - Végül visszatér a $N_"new"$ értékével.
  - A `Simulator` minden egyedhez hozzáad $N_"new"$ új gént a kapott
    `IGeneAdder::add_gene` implementációval.
  - Megszámolja a fajok számát a kapott `ISpeciesCounter::count_species`
    implementációval.
  - Az egyedek, gének és fajok számát egy `State` objektumba csomagolja és
    hozzáadja az állapotvektorhoz.
  - Ha nem maradt több egyed, a ciklus terminál.
+ A szimuláció végül visszatér az állapotvektorral.

==== A szimuláció paraméter objektumainak rövid bemutatása

A modell paraméterei (@model-params) a `RunParameters` objektumban vannak,
az alábbi struktúrákba csoportosítva:

/ `Limits`: A megengedett $[V_"min", V_"max"]$ alléltartomány
/ `ReproductionProbabilities`: A párosodás során használt $P_"encounter"$
  párosodási esély és $P_"change"$ genotípus bővítés valószínűsége.
/ `ReproductionParamters`: Az $M_"init"$ kezdő létszám és a @stretch-formula
  egyenletben használt $M_"const"$, $M_"slope"$ és $M_"limit"$.
/ `GeneticProbabilities`: A genetikai operátorok valószínűségi paraméterei:
  $P_"crossing"$ és $P_"mutation"$
/ `GeneticParamters`: A kezdő génszám $N_"init"$, valamint a genotípusokat
  érintő műveletek paraméterei: $V_"mutation"$ és $V_"stretch"$.
/ `EnergyParameters`: A környezet energiaszintjét növelő paraméter
  $E_"increase"$, valamint az @energy-gain-formula egyenletben használt
  paraméterek: $E_"consumption"$, $E_"intake"$ és $E_"discount"$.

==== A szimuláció egyéb objektumainak rövid bemutatása

A környezet energiakészletét az *`Environment`* osztály kezeli. Az aktuális
energia szint lekérhető a `current_energy` getterrel, de közvetlenül nem
módosítható. A `replenish` metódus növeli a szintet a megadott értékkel,
a `take` metódus pedig csökkenti legfeljebb a megadott mértékkel, de legfeljebb
annyival, hogy nulla alá ne süllyedjen az energiaszint. A tényleges csökkentés
mértékét visszaadja.

Az *`Entity`* struktúra tárolja az egyed egyedek állapotát: a korát (`age`),
energiszintjét (`energy`), és genotípusát (`genotype`).

A *`State`* struktúra foglalja össze a szimulációban tapasztalható állapotokat egy
adott időpillanatban (lépésben). Tartalmazza az egyedek számát (`entity_count`),
az egyes egyedek génjeinek számát (`gene_count`) és a fajok számát
(`species_count`).

A *`RunStates`* a `State` struktúrákból álló `vector`, a `Simulator::run`
visszatérési értéke. Az adott szimuláció állapotának időbeli alakulásának
története.

==== Az impementációk rövid bemutatása

A *`EuclideanDistanceSimilarity`* a kapott egyedek genotípusának eukédeszi
távolságából állapítja meg az $M_"limit"$ és az @offspring-count-formula
egyenlet segítségével, hogy lehet-e utóduk és hány.

A *`ReservoirSelection`* a `ReservoirSampling` technikát alkalmazza, hogy
végigiterálva az összes egyeden (kihagyva a kapott alanyt) igazságosan
válasszon egy `ISimilarity` szerint kompatiblis párt ismeretlen számú,
lehetséges választás közül anélkül, hogy minden találatot el kéne tárolnia egy
tömbbe. A `ReservoirSamnpling` futása során egy választást tartalmaz,
és minden bemutatott opciónál $1 / n$ valószínűséggel cseréli le az addigi
választását az új opcióra, ahol $n$ az addig bemutatott opciók száma.
Visszatérési értéke `std::optional<T>`, mert ha egy opciót sem kapott nincs mit
visszaadni. A FATINT C++ implementiációjában az egyetlen sablonos osztály.

A *`GeneticReproduction`* két általános genetikai operátort használ új egyedek
létrehozásához: `ICombination`, ami két szülő egyed tulajdonágait kombinálja,
és `IMutation`, ami az utód génjeit véletlenszerűen módosíthatja.

A *`BoundedMutation`* az `IMutation` implementációja, génenként $P_"mutation"$
valószínűséggel módosítja azt egy $[-V_"mutation", V_"mutation"]$ intervallumba
eső véletlen számmal. Nem garantálja, hogy a kapott genotípus betartja az
megengedett alléltartományt.

A *`Crossover`* az `ICombination` implementiációja, a kapott utód genotípus
minden génjét egyenként $P_"crossover"$ valószínűséggel az egyik szülőből,
$1 - P_"crossover"$ valószínűséggel a másik szülőből másolja.

A *`RandomGeneAdder`* egy véletlenszerű, a megengedett alléltartományba eső gént
fűz hozzá a kapott genotípushoz.

A *`VStretchGeneAdder`* a @stretch-formula egyenletet használja a kapott
genotípus utolsó génjéből számolja ki az új gént, amit hozzáfűz a genotípushoz.

A *`DepthFirstSearchSpeciesCounter`* mélységi bejárást használja számolja meg
a fajokat a kapott populációban:
+ Initializálja a fajok számát $0$-ra.
+ Amíg van meg nem jelölt egyed:
  - Inkrementálja a fajok számát eggyel.
  - Behelyezi egy meg nem jelölt egyed populáción belüli indexét egy verembe,
    majd megjelöli az egyedet.
  - Amíg a verem nem üres:
    - Kiveszi a veremből a legfelső indexet.
    - A hozzá tartozó egyedhez megkeresi a populáció összes kompatibilis
      egyedét, a jelöletleneket behelyezi a verembe majd megjelöli őket.
+ Miután minden egyedet megjelölt visszatér a fajok számával.
Mivel minden lépésben összehasonlít minden egyed párt, ezért időbeli
komplexitása $O(|V| + |V|^2) approx O(|V|^2$ ahol, $|V|$ a populáció létszáma.

A *`DisjointSetsSpeciesCounter`* a Diszjunkt-Halmaz adatszerkezetet használja
a fajok megszámolásához:
+ Inicializálja a fajok számát $|V|$-re, azaz a populáció létszámára.
+ Minden egyedhez társít egy "szülő" indexet (kezdetben a saját indexét),
  valamint egy rangot. Ezzel létrehoz $|V|$ db fát. Hívjuk azon egyedeket
  "gyökérnek", melyek saját maguk szülei.
+ Minden kompatibilis egyed párt "egyesít":
  - Leköveti a mindkét egyed szülő indexet amíg meg nem találja a gyökerüket.
    Egy, a fák magasságát csökkentő optimalizáció, ha út közben minden egyed
    szülőjét lecseréljük a nagyszülőjére (_"path halving"_).
  - Ha mindkét egyednek ugyanaz a gyökere, nincs további teendő ezzel a párral.
  - Ha a gyökerek eltérnek, de a rangjuk egyforma, az egyik gyökér rangját
    megnöveli eggyel.
  - A kisebb rangú győkér szülőjét beállítja a nagyobb rangú györkérnek, ezzel
    az alacsonyabb fát beolvasztva a magasabbikba.
    Az algorimus működik rangok nélkül is, de a fák magasabbra nőhetnek.
  - Csökkenti a fajok számát eggyel.
Az egyesítés időigénye $O(1)$, a györkér keresés időigénye pedig
$O(alpha(|V|))$, ahol $alpha$ az elhanyagolhatóan lassan növekvő inverz
Ackermann függény. Viszont az időigényt dominálja a kompatilis párok
megkeresése, ami $O(|V|^2)$ időigényű.

==== A fajszámlálók teljesítményének összehasonlítása

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
    A fajszámláló algorimusok időigénye populáció létszámának függvényében
    (logaritmikus skála).
  ],
) <libfatint-species-counter-perf>

A @libfatint-species-counter-perf diagramon látható, hogy magas fajszám mellett
a hogy amíg magas fajszám mellett a Diszjunkt-Halmaz gyorsabb a mélységi
bejárásnál, addig az alacsony fajszám a mélységi bejárásnak kedvez.

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
Az automatizált teszteket a projekt GitHub oldalán beállított CI pipeline is
lefuttatja minden kommit feltöltése után.

==== Automatizált tesztek

A fenti fordítási parancsok előállítanak számos egység- és integrációs tesztet.
Ezek a tesztek a CMake `ctest` eszközével indíthatók, a
`build/libs/libfatint/tests` mappából:

```bash
$ cd build/libs/libfatint/tests
tests$ ctest --output-on-failure
```

Az `--output-on-failure` kapcsolóval a CTest egy összefoglalót nyújt a sikeresen
futtatott tesztekről és részleteket a sikertelenül lefutó tesztekről.

A C++ implementáció tesztjei a `doctest` könytárat használják, és a
következőkről bizonyosodnak meg:

A könytár forrásának `tests/genetics/` könytára 8 egység tesztet tartalmaz:
- `EuclideanDistanceSimilarity` hasonlónak tart két egyforma egyedet $M_"limit" = 1$ mellet.
- `EuclideanDistanceSimilarity` különbözőnek tart két egymástól távol eső genotusú egyedet $M_"limit" = 1$ mellett.
- `BoundedMutation` nem módosítja a géneket $P_"mutation" = 0$ mellett.
- `BoundedMutation` minden gént módosít $P_"mutation" = 0$ mellett.
- `Crossover` mindig az első szülő egyed génjeit választja $P_"crossover" = 0$ mellett.
- `Crossover` mindig a második szülő egyed génjeit választja $P_"crossover" = 1$ mellett.
- `RandomGeneAdder` betartja a megszabott $[V_"min", V_"max"]$ alléltartományt.
- `VStretchGeneAdder` a @stretch-formula egyenletnek megfelelő gént ad a

A `tests/math/` könyvtárban 8 egységteszt ellenőrzi a `Random` véletlenszám generátort és egy teszt a statisztikai segédfüggvényt:
- Két `Random` példány azonos kezdőállapot ($42$) mellett azonos számokat generál.
- `Random` állapota korábbi használat után is alapállapotba $42$ hozható, a kapott számok nem függenek a korábbi állapotoktól.
- `Random` ezer hívás után is betartja a megadott $[10, 20]$ zárt intervallumot.
- `Random` valós számok generálásakor betartja a megadott $[0, 1)$ balról zárt, jobbról nyílt intervallumot.
- `Random` $P = 0$ valószínűség mellett mindig hamis értéket sorsol.
- `Random` $P = 1$ valószínűség mellett mindig igaz értéket sorsol.
- `Random` $P = 0$ valószínűség mellett az esetek $50% plus.minus 5%$-ban igaz értéket sorsol.
- `Random` által kevert sorrendben generált $5$ elemű index sorozat rendezés után a $[0..4] in NN$ sorozat
- `measure` segédfüggvény az $S = [1..5] in NN$ sorozat szerint $min S = 1$, $max S = 5$, $(sum S) / (|S|) = 3$, $s approx 1.5811$ és $s / sqrt(|S|) approx 0.7071$.

A `tests/measurement/`: könyvtárban található 5-5 teszt a `DepthFirstSearchSpeciesCounter` és `DisjointSetsSpeciesCounter` számlálóknak, valamint 5 teszt a `ReservoirSampling` mintavételezőnek:

- `DepthFirstSearchSpeciesCounter` üres populációra $0$ fajt számol
- `DepthFirstSearchSpeciesCounter` egy egyedet egy fajként számol
- `DepthFirstSearchSpeciesCounter` két kompatibilis egyedet egy fajként számol
- `DepthFirstSearchSpeciesCounter` két inkompatiblis egyedet két fajként számol
- `DepthFirstSearchSpeciesCounter` négy egyedet, melyek két párt alkotnak, két fajként számol
- `DisjointSetsSpeciesCounter` üres populációra $0$ fajt számol
- `DisjointSetsSpeciesCounter` egy egyedet egy fajként számol
- `DisjointSetsSpeciesCounter` két kompatibilis egyedet egy fajként számol
- `DisjointSetsSpeciesCounter` két inkompatiblis egyedet két fajként számol
- `DisjointSetsSpeciesCounter` négy egyedet, melyek két párt alkotnak, két fajként számol
- `ReservoirSampling` opciók felajánlása nélkül lekérésre `nullopt`-ot ad
- `ReservoirSampling` egy opció felajánlása után azt az opciót mindig visszaadja
- `ReservoirSampling` egy opció felajánlása után alaphelyzetbe hozhtató, és `nullopt`-ot ad
- `ReservoirSampling` azonos kezdőállapotok mellett determinisztikus
- `ReservoirSampling` azonos valószínűséggel válaszja bármelyik felajánlott opciót

A `tests/model/` könyvtárban 10 egységteszt vizsgálja a modell egyenleteit, és 6 további a paraméter struktúrák túlterhelt `+=` operátorait:

- `entity_energy_change` (@energy-gain-formula egyenlet) $0$ korú egyedek energiabevitelét nem rontja
- `entity_energy_change` (@energy-gain-formula egyenlet) rontja az energia bevitelt ha az egyed öreg
- `offspring_count` (@offspring-count-formula egyenlet) megfelelő értéket ad tökéletes szűrői kompatibitás mellett
- `offspring_count` (@offspring-count-formula egyenlet) megfelelő értéket ad magas szűrői kompatibitás mellett
- `offspring_count` (@offspring-count-formula egyenlet) megfelelő értéket ad alacsony szűrői kompatibitás mellett
- `offspring_count` (@offspring-count-formula egyenlet) $0$ értéket ad inkompatibilis párra
- `offspring_count` (@offspring-count-formula egyenlet) meredekségi változója megfelelően befolyásolja az eredményt
- `stretch_gene` (@stretch-formula egyenlet) megfelelő myújtással működik
- `stretch_gene` (@stretch-formula egyenlet) megfelelő modulussal működik
- `stretch_gene` (@stretch-formula egyenlet) pozitív $V_"min"$ értékkel is működik
- `Limits` `A` példányt incrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `ReproductionProbabilities` `A` példányát incrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `ReproductionParameters` `A` példányát incrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `GeneticProbabilities` `A` példányát incrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `GeneParameters` `A` példányát incrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `EnergyParameters` `A` példányát incrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több

A `tests/performance` könyvtárban 4 teljesítmény teszt méri a faj számlálók időgényét, és 2 további teszt a `Simulator` időigényét:

- `DisjointSetsSpeciesCounter` időigénye $2^n, n in NN inter [3, 11]$ darab közös fajba tartozó egyed megszámolásához
- `DisjointSetsSpeciesCounter` időigénye $2^n, n in NN inter [3, 11]$ darab önálló fajba tartozó egyed megszámolásához
- `DepthFirstSearchSpeciesCounter` időigénye $2^n, n in NN inter [3, 11]$ darab közös fajba tartozó egyed megszámolásához
- `DepthFirstSearchSpeciesCounter` időigénye $2^n, n in NN inter [3, 11]$ darab önálló fajba tartozó egyed megszámolásához
- `Simulator` időigénye $2^n, n in NN inter [3, 11]$ darab hallhatatlan, steril egyed szimulálásához 1000 lépésben
- `Simulator` időigénye 1000 lépés szimulálásához, ahol $E_"increase" in {2^n | n in NN inter [3, 11]}$, azaz a környezet egyre több egyedet tud eltartani, növelve körönkénti születések és halálok számát

A `tests/simulation` könyvtárban 22 teszt vizsálja a paraméter validáló függvényeket, egy a `RunParameters` túlterhelt `+=` operátorát, 1-1 teszt az `ExperimentParameters` és `ExperimentSweepParameters` `expand` segédfüggvényeit és 6 integrációs teszt a `Simulator` osztályt:

- `RunParameters` minden lehetséges tartoményszegést jelez
- `ExperimentParameters` minden lehetséges tartoményszegést jelez
- `ExperimentSweepParameters` minden lehetséges tartoményszegést jelez
- `RunParameters` `A` példányát incrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `ExperimentParameters::expand()` a megfelelő `RunParamters` objektumokat hozza létre
- `ExperimentSweepParameters::expand()` a megfelelő `RunParamters` objektumokat hozza létre
- `Simulator` szaporodás híján ($P_"encounter" = 0$) $50$ lépésen belül terminál
- `Simulator` szimulációjában laza párosodási preferencia mellett ($M_"limit" = 100$) 50 lépés után is van még elő egyed
- `Simulator` determinisztikus; azonos kezdőparaméterű véletlenszám generátorok melett azonos eredményeket produkál
- `Simulator` $M_"limit" = 100, P_"encounter" = 0.2$ mellett 50 lépés után magasabb génszámot ad, mint $N_"init"$
- `Simulator` szimulációja alapértelmezett paraméterek mellett egy stabit fajt képez
- `Simulator` $P_"change" = 0.001$ mellett 2000 lépés után több, mint egy fajt produkál

A @fatint cikkben szereplő kísérletek adaptált megfelelői a következők:

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
