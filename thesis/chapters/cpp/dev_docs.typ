#import "/lib/plot.typ": *
#import "/lib/elteikthesis.typ": *
#import "@preview/lovelace:0.3.1": *

== Fejlesztői dokumentáció (C++) <cpp-spec>

A fejlesztői dokumentáció részletezi a FATINT modell C++ implementációjának
működési követelményeit, az implementációban meghozott döntéseket és tesztelés
menetét.

=== Specifikáció

A C++ implementáció feladata a FATINT (@model-desc) modell pontos szimulációja,
és a @fatint cikkben közölt adatok replikációja. Ehhez nyújt egy könyvtárat és
parancssori eszközt, mellyel könnyen és gyorsan futtathatók kísérletek és
kísérletsorok.

==== Funkcionális követelmények

Az implementáció:
- Lehetőséget nyújt a @model-params fejezetben szereplő összes paraméter
  beállítására.
- Ellenőrzi a felhasználó által megadott paramétereket és jelenti a hibákat.
- A modell pontosan követi a @model-desc fejezetben leírt viselkedést.
- Lehetőséget nyújt kísérletek és kísérletsorok futtatására.
- Lehetőséget nyújt a kísérlet vagy kísérletsor eredményeinek
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
felhasználó a parancssorban adja meg. A program induláskor ellenőrzi a megadott
paraméterek helyességét, és probléma esetén tájékoztatja a felhasználót a
hibáról. Ha a paraméterek megfelelnek a @model-defaults táblázatban
foglaltaknak, a program a kísérletsor lefutásáig nem nyújt további visszajelzést
a felhasználónak. Ha a felhasználó nem adott meg mentési útvonalat, a program a
standard kimenetre írja az eredményeket, lehetővé téve azok szkriptekben vagy
csővezetékeken keresztül történő további feldolgozását. Ha a felhasználó
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
    table.header[*#text("GIVEN", lang: "en") / Feltéve, hogy a felhasználó...*][*#text("WHEN", lang: "en") / Amikor...*][*#text("THEN", lang:"en") / Akkor...*],

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
    [A program a szimulációk statisztikáit grafikonon ábrázolja SVG formátumban, a grafikon forráskódját a standard kimenetre írja, majd kilép],

    [Helyes parancssori paramétereket adott meg, és a `--format` kapcsolót `SVG`-re állította],
    [A felhasználó elindítja a programot `--output` kapcsolóban megadva a mentési útvonalat],
    [A program a szimulációk statisztikáit grafikonon ábrázolja SVG formátumban, a grafikon forráskódját a megadott fájlba írja, majd kilép],
  ),
  caption: "A C++ implementáció elvárt viselkedése a paraméterek függvényében",
) <cpp-gwt>

=== Implementáció részletei

==== Architektúra

A C++ implementáció erősen épít a _"Stratégia"_ fejlesztési mintára. A
szimuláció minden eleme, a genetikus algoritmusoktól a fajszámolásig egy-egy
különálló, cserélhető algoritmus.

A szimuláció fontosabb komponensei interfészként vannak definiálva:

/ `ISimilarity`: távolságmetrika, mellyel meghatározható, hogy mely egyedek kompatibilisek egymással. Például a genotípusaik euklideszi távolsága.
/ `ISelection`: Keres egy kompatibilis párt egy adott egyedhez.
/ `IReproduction`: Kombinálja két szülő egyed tulajdonságait egy gyermek egyedben. Például `GeneticReproduction`.
/ `IGeneAdder`: Meghatározza egy egyed genotípusa alapján a következő aktiválandó gént. Például `RandomGeneAdder` vagy `VStretchGeneAdder`.
/ `ISpeciesCounter`: Megszámolja a párzási preferenciák mentén elkülöníthető fajok számát. Például `DepthFirstSearchSpeciesCounter` vagy `DisjointSetsSpeciesCounter`. Az implementáció nem lehet hatással a végeredményre.

/ `IMutation`: A `GeneticReproduction` mutációs operátora. Az gyermekegyed génjeit módosítja.
/ `ICrossover`: A `GeneticReproduction` keresztezés operátora. A két szülő egyed génjeit kombinálja egy gyermekegyedben.

Minden interfész egy tiszta függvény, nem tartalmazhatnak állapotot. Ez
garantálja, hogy a több szimuláció több szálon egyszerre használhassa ugyanazon
példányokat koordináció nélkül, mégis reprodukálható módon, versenyhelyzetek
nélkül.

Az interfészeket, azok kapcsolatát és implementációikat a
@libfatint-simulator-class-diagram, @libfatint-simulator-params-diagram,
@libfatint-simulator-usages-diagram és @libfatint-experiment-class-diagram
diagramok részletezik. Az összetettség csökkentése érdekében az ábrán látható
osztályok egyszerűsítve vannak ábrázolva a forráshoz képest.
Diagramon szereplő összes osztály összes mezője érték ha primitív vagy struktúra és
`unique_ptr`, azaz birtokolt példány, ha implementáció. Minden osztály
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
  caption: [A `Simulator` osztály és az általa használt típusok osztálydiagramja],
) <libfatint-simulator-usages-diagram>
#figure(
  image("/assets/diagrams/cpp_experiment_classes.svg", width: 60%),
  caption: [A kísérletsorok és alkotóelemeinek osztálydiagramja],
) <libfatint-experiment-class-diagram>

==== A program szakaszai

Az egyes elemek egy adatcsővezetéket (_"#text("data pipeline", lang: "en")"_) alkotnak, több transzformációs lépéssel, lásd @libfatint-dataflow.

#pseudocode-listing(caption: [A `fatint` adatfolyama])[
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
  függőségekkel és a paraméterekkel, inicializál egy `Random` véletlenszám
  generátort a megfelelő kezdőállapottal, majd lefuttatja a szimulációt
  (`Simulator::run`). A kapott `RunStates` állapotokat kigyűjti egy
  `ExperimentStates` gyűjteménybe. A szimulációs lépéseket a @cpp-sim-steps
  részletezi.
+ A program a `math::measure` segédfüggvénnyel minden kísérlethez lépésenkénti
  statisztikákat (`ExperimentStatistics`) állít elő az egyes kísérletek
  szimulációinak azonos lépéskori állapotából, majd a kísérletek statisztikáit
  kigyűjti egy `ExperimentSweepStatistics` gyűjteménybe.
+ A program a felhasználó által meghatározott útvonalhoz létrehoz egy kimeneti
  folyamot (`std::ostream`), a falhasználó által meghatározott adat exportálót
  (`CSVWriter` vagy `SVGWriter`) példányosítja, majd átadja az exportálónak a
  paramétereket, statisztikákat és a folyamot.
+ Az exportáló végeztével a program kilép.
] <libfatint-dataflow>

==== A szimuláció menete <cpp-sim-steps>

A `Simulator::run` metódus egy teljes kísérletet lefuttat, majd visszaadja
a lépésenként mért populáció létszámot, gének számát és fajok számát. Az alábbi
lépésekből áll:

#figure(
  pseudocode-list[
    + *metódus* `Simulator::run`(&rng):
      + környezet := `Environment`()
      + állapotok := `vector<State>`(lépésszám)
      + egyedek := `vector<Entity>`($M_"init"$)
      + génszám := $N_"init"$
      + *ciklus* $forall "egyed" in "egyedek"$:
        + $"egyed.kor" := 0$
        + $"egyed.energia" := 0$
        + $"egyed.genotípus" := N_"init"$ darab véletlenszám $[V_"min", V_"max"]$ között
      + *ciklus vége*
      + *ciklus* $forall "állapot" in "állapotok"$
        + *ha* $"egyedek" = emptyset$
          + $"állapot.egyedszám" := 0$
          + $"állapot.fajszám" := 0$
          + $"állapot.génszám" := "génszám"$
        + *különben*
          + környezet energiaszintjének növelése $E_"increase"$-szel
          + `tick`(környezet, egyedek)
          + $N_"add"$ := `reproduce`(egyedek)
          + *ismétlés* $N_"add"$ *alkalommal:*
            + *ciklus* $forall "egyed" in "egyedek"$:
              + `IGeneAdder.add_gene(`egyed.genotípus`)`
            + *ciklus vége*
            + $"génszám" := "génszám" + 1$
          + *ismétlés vége*
          + $"állapot.egyedszám" := |"egyedek"|$
          + $"állapot.fajszám" :=$ `ISpeciesCounter::count_species(`egyedek`)`
          + $"állapot.génszám" := "génszám"$
        + *elágazás vége*
      + *ciklus vége*
      + *visszatér* állapotok
    + *metódus vége*
  ],
  caption: [A `Simulator::run` lépései]
) <cpp-simulator-run-listing>
#figure(
  pseudocode-list[
    + *metódus* `Simulator::tick`(&környezet, &egyedek)
      + *ciklus* $forall "egyed" in "egyedek"$ véletlen sorrendben:
        + $"egyed.kor" := "egyed.kor" + 1$
        + $E_"in" :=$ legfeljebb $E_"intake"$ energia kivonása a környezetből
        + $"egyed.energia" := "egyed.energia" + E_"in" dot (E_"discount") ^ "egyed.kor" - E_"consumption"$
      + *ciklus vége*
      + $"egyedek" := { e in "egyedek" | "e.energia" > 0 }$
    + *metódus vége*
  ],
  caption: [A `Simulator::tick` lépései]
) <cpp-simulator-tick-listing>
#figure(
  pseudocode-list[
    + *metódus* `Simulator::reproduce`(&rng, &egyedek)
      + $N_"add" := 0$
      + *ciklus* $forall "egyed" in "egyedek"$
        + egyed kihagyása, ha $P_"encounter"$ nem teljesül
        + partner := `ISelection::select(`rng, egyedek, egyed`)`
        + *ismétlés* `ISimilarity::offspring_count(`egyed, partner`)`  *alkalommal*:
          + $"utód" := "Egyed"()$
          + $"utód.kor" := 0$
          + $"utód.energia" := 0$
          + $"életképes" := $ `IReproduction::reproduce(`egyed, partner, utód`)`
          + *ha* életképes:
            + utód hozzáfűzése egyedekhez
            + *ha* $P_"change"$ teljesül:
              + $N_"add" := N_"add" + 1$
            + *elágazás vége*
          + *elágazás vége*
        + *ismétlés vége*
      + *ciklus vége*
      + *visszatér* $N_"add"$
    + *metódus vége*
  ],
  caption: [A `Simulator::reproduce` lépései]
) <cpp-simulator-reproduce-listing>

/*
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
*/

==== A szimuláció paraméter objektumainak rövid bemutatása

A modell paraméterei (@model-params) a `RunParameters` objektumban vannak,
az alábbi struktúrákba csoportosítva:

/ `Limits`: A megengedett $[V_"min", V_"max"]$ alléltartomány
/ `ReproductionProbabilities`: A párosodás során használt $P_"encounter"$
  párosodási esély és $P_"change"$ genotípus bővítés valószínűsége.
/ `ReproductionParameters`: Az $M_"init"$ kezdő létszám és a @stretch-formula
  egyenletben használt $M_"const"$, $M_"slope"$ és $M_"limit"$.
/ `GeneticProbabilities`: A genetikai operátorok valószínűségi paraméterei:
  $P_"crossing"$ és $P_"mutation"$
/ `GeneticParameters`: A kezdő génszám $N_"init"$, valamint a genotípusokat
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
energiaszintjét (`energy`), és genotípusát (`genotype`).

A *`State`* struktúra foglalja össze a szimulációban tapasztalható állapotokat egy
adott időpillanatban (lépésben). Tartalmazza az egyedek számát (`entity_count`),
az egyes egyedek génjeinek számát (`gene_count`) és a fajok számát
(`species_count`).

A *`RunStates`* a `State` struktúrákból álló `vector`, a `Simulator::run`
visszatérési értéke. Az adott szimuláció állapotának időbeli alakulásának
története.

==== Az implementációk rövid bemutatása

A *`EuclideanDistanceSimilarity`* a kapott egyedek genotípusának euklideszi
távolságából állapítja meg az $M_"limit"$ és az @offspring-count-formula
egyenlet segítségével, hogy lehet-e utóduk és hány.

A *`ReservoirSelection`* a `ReservoirSampling` technikát alkalmazza, hogy
végigiterálva az összes egyeden (kihagyva a kapott alanyt) igazságosan
válasszon egy `ISimilarity` szerint kompatibilis párt ismeretlen számú,
lehetséges választás közül anélkül, hogy minden találatot el kéne tárolnia egy
tömbbe. A `ReservoirSamnpling` futása során egy választást tartalmaz,
és minden bemutatott opciónál $1 / n$ valószínűséggel cseréli le az addigi
választását az új opcióra, ahol $n$ az addig bemutatott opciók száma.
Visszatérési értéke `std::optional<T>`, mert ha egy opciót sem kapott nincs mit
visszaadni. A FATINT C++ implementációjában az egyetlen sablonos osztály.

A *`GeneticReproduction`* két általános genetikai operátort használ új egyedek
létrehozásához: `ICombination`, ami két szülő egyed tulajdonágait kombinálja,
és `IMutation`, ami az utód génjeit véletlenszerűen módosíthatja.

A *`BoundedMutation`* az `IMutation` implementációja, génenként $P_"mutation"$
valószínűséggel módosítja azt egy $[-V_"mutation", V_"mutation"]$ intervallumba
eső véletlen számmal. Nem garantálja, hogy a kapott genotípus betartja az
megengedett alléltartományt.

A *`Crossover`* az `ICombination` implementációja, a kapott utód genotípus
minden génjét egyenként $P_"crossover"$ valószínűséggel az egyik szülőből,
$1 - P_"crossover"$ valószínűséggel a másik szülőből másolja.

A *`RandomGeneAdder`* egy véletlenszerű, a megengedett alléltartományba eső gént
fűz hozzá a kapott genotípushoz.

A *`VStretchGeneAdder`* a @stretch-formula egyenletet használja a kapott
genotípus utolsó génjéből számolja ki az új gént, amit hozzáfűz a genotípushoz.

A *`DepthFirstSearchSpeciesCounter`* mélységi bejárást (@cpp-dfs-listing) használja számolja meg
a fajokat a kapott populációban:

#figure(
  pseudocode-list[
    + *függvény* `DepthFirstSearchSpeciesCounter::count-species`
      + Inicializálja a fajok számát nullára.
      + *ciklus* Amíg van meg nem jelölt egyed:
        + Inkrementálja a fajok számát eggyel.
        + Behelyezi egy meg nem jelölt egyed populáción belüli indexét egy verembe,
          majd megjelöli az egyedet.
        + *ciklus* Amíg a verem nem üres:
          + Kiveszi a veremből a legfelső indexet.
          + A hozzá tartozó egyedhez megkeresi a populáció összes kompatibilis
            egyedét, a jelöletleneket behelyezi a verembe majd megjelöli őket.
        + *ciklus vége*
      + *ciklus vége*
      + Miután minden egyedet megjelölt visszatér a fajok számával.
      + *visszatérés* A fajok számával
    + *függvény vége*
  ],
  caption: [A mélységi bejárás alapú fajszámláló lépései]
) <cpp-dfs-listing>

Mivel minden lépésben összehasonlít minden egyed párt, ezért időbeli
komplexitása $ O(|V| + |V|^2) approx O(|V|^2) $ ahol, $|V|$ a populáció létszáma.

A *`DisjointSetsSpeciesCounter`* a Diszjunkt-Halmaz adatszerkezetet (@cpp-ds-listing) használja a fajok megszámolásához:

#figure(
  pseudocode-list[
    + *függvény* `DepthFirstSearchSpeciesCounter::count-species`
      + Inicializálja a fajok számát $|V|$-re, azaz a populáció létszámára.
      + Minden egyedhez társít egy "szülő" indexet (kezdetben a saját indexét),
        valamint egy rangot. Ezzel létrehoz $|V|$ db fát. Hívjuk azon egyedeket
        "gyökérnek", melyek saját maguk szülei.
      + *ciklus* Minden kompatibilis egyed párt "egyesít":
        + Leköveti a mindkét egyed szülő indexet amíg meg nem találja a gyökerüket.
          Egy, a fák magasságát csökkentő optimalizáció, ha út közben minden egyed
          szülőjét lecseréljük a nagyszülőjére (_"path halving"_).
        + Ha mindkét egyednek ugyanaz a gyökere, nincs további teendő ezzel a párral.
        + Ha a gyökerek eltérnek, de a rangjuk egyforma, az egyik gyökér rangját
          megnöveli eggyel.
        + A kisebb rangú gyökér szülőjét beállítja a nagyobb rangú gyökérnek, ezzel
          az alacsonyabb fát beolvasztva a magasabbikba.
          Az algoritmus működik rangok használata nélkül is, de a fák magasabbra nőhetnek.
        + Csökkenti a fajok számát eggyel.
      + *ciklus vége*
      + *visszatérés* A fajok számával
    + *függvény vége*
  ],
  caption: [A Diszjunkt-Halmaz adatszerkezet alapú fajszámláló lépései]
) <cpp-ds-listing>

Az egyesítés időigénye $O(1)$, a gyökér keresés időigénye pedig
$O(alpha(|V|))$, ahol $alpha$ az elhanyagolhatóan lassan növekvő inverz
Ackermann függvény. Viszont az időigényt dominálja a kompatibilis párok
megkeresése, ami $O(|V|^2)$ időigényű. Így a teljes időigény
$ O(alpha(|V|) + |V|^2) $

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
    A fajszámláló algoritmusok időigénye populáció létszámának függvényében
    (logaritmikus skála).
  ],
) <libfatint-species-counter-perf>

A @libfatint-species-counter-perf diagramon látható, hogy magas fajszám mellett
a hogy amíg magas fajszám mellett a Diszjunkt-Halmaz gyorsabb a mélységi
bejárásnál, addig az alacsony fajszám a mélységi bejárásnak kedvez.

=== Forráskód fordítása <build-from-source>

A forráskód fordításához a következő elemekre van szükség:

- *#text("CMake", lang:"en")* 3.11 vagy újabb.
- Egy C++20 szabványt támogató *C++ fordító* (például #text("GCC", lang:"en") 9 vagy újabb)
- *#text("Intel Thread Building Blocks", lang:"en")*.
  A C++ standard könyvtárának paralel algoritmusait implementálja.
  Egyes standard könyvtárak (például `libstdc++`) megkövetelik, mások
  (például `libc++`) nem.

Például Ubuntu 24.04 rendszeren a függőségeket a @cpp-install-deps paranccsal
telepítjük:

#command(caption: [`fatint` fordításához szükséges eszközök telepítése Ubuntun])[
```bash
$ sudo apt install build-essential cmake libtbb12 libtbb-dev
```
] <cpp-install-deps>

Minden további függőség a forráskód része.

A fordításhoz a projekt `fatint-cpp` könyvtárában állva kiadjuk az alábbi
parancsokat:

#command(caption: [`fatint` fordításához szükséges parancsok])[
```bash
$ cmake -S . -B ./build -DCMAKE_BUILD_TYPE=Release
$ cmake --build build --parallel
```
] <cpp-build>

A @cpp-build parancsok lefutása után kész program a `./build` mappába kerül.

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

A C++ implementáció tesztjei a `doctest` könyvtárat használják, és a
következőkről bizonyosodnak meg:

A könyvtár forrásának `tests/genetics/` könyvtára 8 egység tesztet tartalmaz:
- `EuclideanDistanceSimilarity` hasonlónak tart két egyforma egyedet $M_"limit" = 1$ mellet.
- `EuclideanDistanceSimilarity` különbözőnek tart két egymástól távol eső genotípusú egyedet $M_"limit" = 1$ mellett.
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
- `DepthFirstSearchSpeciesCounter` két inkompatibilis egyedet két fajként számol
- `DepthFirstSearchSpeciesCounter` négy egyedet, melyek két párt alkotnak, két fajként számol
- `DisjointSetsSpeciesCounter` üres populációra $0$ fajt számol
- `DisjointSetsSpeciesCounter` egy egyedet egy fajként számol
- `DisjointSetsSpeciesCounter` két kompatibilis egyedet egy fajként számol
- `DisjointSetsSpeciesCounter` két inkompatibilis egyedet két fajként számol
- `DisjointSetsSpeciesCounter` négy egyedet, melyek két párt alkotnak, két fajként számol
- `ReservoirSampling` opciók felajánlása nélkül lekérésre `nullopt`-ot ad
- `ReservoirSampling` egy opció felajánlása után azt az opciót mindig visszaadja
- `ReservoirSampling` egy opció felajánlása után alaphelyzetbe hozható, és `nullopt`-ot ad
- `ReservoirSampling` azonos kezdőállapotok mellett determinisztikus
- `ReservoirSampling` azonos valószínűséggel választja bármelyik felajánlott opciót

A `tests/model/` könyvtárban 10 egységteszt vizsgálja a modell egyenleteit, és 6 további a paraméter struktúrák túlterhelt `+=` operátorait:

- `entity_energy_change` (@energy-gain-formula egyenlet) $0$ korú egyedek energiabevitelét nem rontja
- `entity_energy_change` (@energy-gain-formula egyenlet) rontja az energia bevitelt ha az egyed öreg
- `offspring_count` (@offspring-count-formula egyenlet) megfelelő értéket ad tökéletes szűrői kompatibilitás mellett
- `offspring_count` (@offspring-count-formula egyenlet) megfelelő értéket ad magas szűrői kompatibilitás mellett
- `offspring_count` (@offspring-count-formula egyenlet) megfelelő értéket ad alacsony szűrői kompatibilitás mellett
- `offspring_count` (@offspring-count-formula egyenlet) $0$ értéket ad inkompatibilis párra
- `offspring_count` (@offspring-count-formula egyenlet) meredekségi változója megfelelően befolyásolja az eredményt
- `stretch_gene` (@stretch-formula egyenlet) megfelelő nyújtással működik
- `stretch_gene` (@stretch-formula egyenlet) megfelelő modulussal működik
- `stretch_gene` (@stretch-formula egyenlet) pozitív $V_"min"$ értékkel is működik
- `Limits` `A` példányt inkrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `ReproductionProbabilities` `A` példányát inkrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `ReproductionParameters` `A` példányát inkrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `GeneticProbabilities` `A` példányát inkrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `GeneParameters` `A` példányát inkrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `EnergyParameters` `A` példányát inkrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több

A `tests/performance` könyvtárban 4 teljesítmény teszt méri a faj számlálók időigényét, és 2 további teszt a `Simulator` időigényét:

- `DisjointSetsSpeciesCounter` időigénye $2^n, n in NN inter [3, 12]$ darab közös fajba tartozó egyed megszámolásához (5 futás átlaga)
- `DisjointSetsSpeciesCounter` időigénye $2^n, n in NN inter [3, 12]$ darab önálló fajba tartozó egyed megszámolásához (5 futás átlaga)
- `DepthFirstSearchSpeciesCounter` időigénye $2^n, n in NN inter [3, 12]$ darab közös fajba tartozó egyed megszámolásához (5 futás átlaga)
- `DepthFirstSearchSpeciesCounter` időigénye $2^n, n in NN inter [3, 12]$ darab önálló fajba tartozó egyed megszámolásához (5 futás átlaga)
- `Simulator` időigénye $2^n, n in NN inter [3, 12]$ darab hallhatatlan, steril egyed szimulálásához 1000 lépésben (5 futás átlaga)
- `Simulator` időigénye 1000 lépés szimulálásához, ahol $E_"increase" in {2^n | n in NN inter [3, 12]}$, azaz a környezet egyre több egyedet tud eltartani, növelve körönkénti születések és halálok számát (5 futás átlaga)

A `tests/simulation` könyvtárban 22 teszt vizsgálja a paraméter validáló függvényeket, egy a `RunParameters` túlterhelt `+=` operátorát, 1-1 teszt az `ExperimentParameters` és `ExperimentSweepParameters` `expand` segédfüggvényeit és 6 integrációs teszt a `Simulator` osztályt:

- `RunParameters` minden lehetséges tartományszegést jelez
- `ExperimentParameters` minden lehetséges tartományszegést jelez
- `ExperimentSweepParameters` minden lehetséges tartományszegést jelez
- `RunParameters` `A` példányát inkrementáljuk `B`-vel; utána `A` minden mezője `B` azonos mezőjének értékével több
- `ExperimentParameters::expand()` a megfelelő `RunParameters` objektumokat hozza létre
- `ExperimentSweepParameters::expand()` a megfelelő `RunParameters` objektumokat hozza létre
- `Simulator` szaporodás híján ($P_"encounter" = 0$) $50$ lépésen belül terminál
- `Simulator` szimulációjában laza párosodási preferencia mellett ($M_"limit" = 100$) 50 lépés után is van még elő egyed
- `Simulator` determinisztikus; azonos kezdőparaméterű véletlenszám generátorok mellett azonos eredményeket produkál
- `Simulator` $M_"limit" = 100, P_"encounter" = 0.2$ mellett 50 lépés után magasabb génszámot ad, mint $N_"init"$
- `Simulator` szimulációja alapértelmezett paraméterek mellett egy stabil fajt képez
- `Simulator` $P_"change" = 0.001$ mellett 2000 lépés után több, mint egy fajt produkál

A @fatint cikkben szereplő kísérletek adaptált megfelelői a következők:

==== A cikk grafikonjai, mint kézi integrációs tesztek

A @fatint cikkben demonstrált kísérletsorok segítségével meggyőződhetünk róla,
hogy a C++ implementáció az elvárt módon viselkedik. A @fatint cikkben szereplő
összes kísérlet elvégezhető az @cpp-run-paper-experiments parancsaival:

#command(caption: [@fatint kísérletsorainak futtatása `fatint` programmal])[
```bash
$ fatint \
    --output thesis/data/default-libfatint.csv
$ fatint \
    --sweep p_encounter \
    --sweep-from 0.05 \
    --sweep-by 0.005 \
    --sweep-to 0.095 \
    --output thesis/data/p_encounter-libfatint.csv
$ fatint \
    --sweep p_crossing \
    --sweep-from 0 \
    --sweep-by 0.1 \
    --sweep-to 0.5 \
    --output thesis/data/p_crossing-libfatint.csv
$ fatint \
    --sweep p_mutation \
    --sweep-from 0 \
    --sweep-by 0.1 \
    --sweep-to 0.5 \
    --output thesis/data/p_mutation-libfatint.csv
$ fatint \
    --sweep p_change \
    --sweep-from 0.0005 \
    --sweep-by 0.00005 \
    --sweep-to 0.001 \
    --output thesis/data/p_change-libfatint.csv
$ fatint \
    --p_change 0.0005 \
    --sweep m_limit \
    --sweep-from 0 \
    --sweep-to 20 \
    --output thesis/data/m_limit-libfatint.csv
$ fatint \
    --p_change 0.0005 \
    --sweep v_stretch \
    --sweep-from 1 \
    --sweep-to 20 \
    --output thesis/data/v_stretch-libfatint.csv


```
] <cpp-run-paper-experiments>

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

Alapértelmezett paraméterek mellett a fajok átlagos száma nem eshet 0-ra, lásd
@cpp-species-comp-default.

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

$P_"encounter"$ alacsony értékeknél biztos kipusztulást, és magasabb értékeknél
is legfeljebb egy faj fennmaradását garantálja, lásd
@cpp-species-comp-p-encounter.

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

$P_"mutation"$ magasabb értékeknél létrehozhat egy-egy rövid életű fajt, de
mivel ezen fajok gyakran egy egyedből állnak, így az egyed halálával a faj is
kihal. Továbbra is egyetlen faj dominál. Lásd @cpp-species-comp-p-mutation.

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

$P_"crossing"$ magas értékeknél hasonlóan viselkedik, mint a $P_"mutation"$
eset, lásd @cpp-species-comp-p-crossing.

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

Ahogy a @model-desc fejezet is kifejtette, $P_"change"$ a FATINT modell egyik
legfontosabb paramétere. Ahogy a @cpp-species-comp-p-change ábrán is
látható, bármilyen nem nulla érték mellett "tüskéket" okoz a faj számokban, mert
egyszerre hat az összes egyed párosodási preferenciáira. Minél magasabb
$P_"change"$, annál gyakoribbak a tüskék.

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

$P_"change" = 0.0005$-el garantálva az új gének hozzáadását, $M_"limit"$
különböző értékei arra hatással vannak a "tüskék" méretére. Minél magasabb,
annál több faj keletkezik a gének hozzáadásakor, ugyanakkor ezen fajok annál
kisebbek és rövidebb életűek. Lásd @cpp-species-comp-m-limit.

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

Ha véletlenszerű gének helyett a @stretch-formula egyenletet használjuk, akkor
ahogy a @cpp-species-comp-v-stretch ábrán is látható, a létrejövő fajok
száma hirtelen megugrik, majd lassabban csökken, mint amikor
véletlenszerűen adunk az egyedekhez új géneket.

==== Teljesítmény

#figure(
  perf_plot(
    [Populáció],
    (
      (
        path: "/data/benchmark-species-counter-dfs-one-species-libfatint.csv",
        label: [C++, Mélységi bejárás, egy faj],
        skip: 0,
        x: 0,
        y: 1,
      ),
      (
        path: "/data/benchmark-species-counter-dfs-many-species-libfatint.csv",
        label: [C++, Mélységi bejárás, sok faj],
        skip: 0,
        x: 0,
        y: 1,
      ),
      (
        path: "/data/benchmark-species-counter-ds-one-species-libfatint.csv",
        label: [C++, Diszjunkt-Halmaz, egy faj],
        skip: 0,
        x: 0,
        y: 1,
      ),
      (
        path: "/data/benchmark-species-counter-ds-many-species-libfatint.csv",
        label: [C++, Diszjunkt-Halmaz, sok faj],
        skip: 0,
        x: 0,
        y: 1,
      ),
      (
        path: "/data/benchmark-species-counter-dfs-one-species-NetLogo.csv",
        label: [NetLogo, Mélységi bejárás, egy faj],
        skip: 7,
        x: 0,
        y: 2,
      ),
      (
        path: "/data/benchmark-species-counter-dfs-many-species-NetLogo.csv",
        label: [NetLogo, Mélységi bejárás, sok faj],
        skip: 7,
        x: 0,
        y: 2,
      ),
      (
        path: "/data/benchmark-species-counter-ds-one-species-NetLogo.csv",
        label: [NetLogo, Diszjunkt-Halmaz, egy faj],
        skip: 7,
        x: 0,
        y: 2,
      ),
      (
        path: "/data/benchmark-species-counter-ds-many-species-NetLogo.csv",
        label: [NetLogo, Diszjunkt-Halmaz, sok faj],
        skip: 7,
        x: 0,
        y: 2,
      ),
    ),
  ),
  caption: [
    Az élek létrehozásának és a fajszámláló algoritmusok futásidejének összege a
    populáció létszámának függvényében. Logaritmikus skála.
  ],
) <cpp-species-counter-perf-comp>

#figure(
  perf_plot(
    [Létszám],
    (
      (
        path: "/data/benchmark-simulator-nochurn-libfatint.csv",
        label: [C++ implementáció],
        skip: 0,
        x: 0,
        y: 1,
      ),
      (
        path: "/data/benchmark-simulator-nochurn-NetLogo.csv",
        label: [NetLogo implementáció],
        skip: 7,
        x: 0,
        y: 2,
      ),
    ),
  ),
  caption: [Egy 1000 lépéses szimuláció időigénye steril, hallhatatlan egyedek számának függvényében. Logaritmikus skála.],
) <cpp-simulation-nochurn-perf>

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
      (
        path: "/data/benchmark-simulator-churn-NetLogo.csv",
        label: [NetLogo implementáció],
        skip: 7,
        x: 0,
        y: 2,
      ),
    ),
  ),
  caption: [Egy 1000 lépéses szimuláció időigénye a környezet eltartóképességének függvényében. Logaritmikus skála.)],
) <cpp-simulation-perf>

A @cpp-species-counter-perf-comp, @cpp-simulation-nochurn-perf és @cpp-simulation-perf diagramok alapján elmondható, hogy a C++ implementáció
jelentősen gyorsabb a NetLogo implementációnál.
