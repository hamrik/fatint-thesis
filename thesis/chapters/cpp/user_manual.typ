#import "../../lib/elteikthesis.typ": *

== Felhasználói dokumentáció (C++) <cpp-user-manual>

A C++ implementáció (továbbiakban *a program*) egy felület nélküli,
parancssorból futtatható implementációja a FATINT modellnek (@model-desc),
továbbá egy könyvtár (továbbiakban *`libfatint`*), mely beépíthető egyéb
programokba. Elsődleges célja, hogy a @fatint cikkben megfogalmazott
kísérletsorokat gyorsabban lefuttassa, mint a NetLogo implementáció. Másodlagos
célja egy objektumelvű megvalósítása a FATINT modellnek.

=== Rendszerkövetelmények

A `fatint` program futtatásához az alábbiak a minimális követelmények:

- 2 évnél nem régebbi Linux disztribúció, például #text("Ubuntu Linux 24.04 LTS", lang: "en")
- C++ futásidejű könyvtárak (például `libc++` vagy `libstdc++`).
  Nagy valószínűséggel az operációs rendszer már tartalmazza.
- 1MB tárhely a programnak
- Nagyjából 100MB tárhely a generálandó adatoknak
- Legalább 128MB memória
- #link("https://www.intel.com/content/www/us/en/developer/tools/oneapi/onetbb.html")[#text("Intel Threading Building Blocks", lang: "en")] futásidejű könyvtárai

=== Telepítés

==== Telepítés Linux rendszeren

#list(caption: "A program telepítése Ubuntu 20.04 rendszeren")[
+ Telepítsük az #text("Intel Threading Building Blocks", lang: "en") futásidejű
  könyvtárat. Ubuntu rendszereken ehhez a `libtbb12` csomagot kell telepíteni vagy
  egy grafikus csomagkezelővel, vagy a @cpp-install-tbb paranccsal:
  #command(caption: "Intel Threading Building Blocks telepítése Ubuntun")[
  ```bash
  $ sudo apt install libtbb12
  ```
  ] <cpp-install-tbb>
+ Látogassuk meg #link("https://github.com/hamrik/fatint-thesis/releases/latest")[a projekt GitHub tárhelyét].
+ Töltsük le a legfrissebb verzió bejegyzésének alján linkelt `fatint` nevű programot.
+ Csomagoljuk ki egy nekünk tetsző helyre.
+ Nyissunk egy terminált a kicsomagolt mappában.
+ Ellenőrizzük, hogy a program elindul:
  #command(caption: [`fatint` súgó lehívása])[
  ```bash
  $ ./fatint -h
  ```
  ] <cpp-help>
+ Ha a @cpp-help kiadása után egy súgót kapunk, minden készen áll a kísérletek futtatására.
] <cpp-install>

Kövessük a @cpp-install lépéseit.

Ha `No such file or directory` hibaüzenetet kapjuk akkor nem jó mappában áll
a parancssor. Győződjünk meg róla, hogy abban a mappában áll a parancssor,
amelyikben a `fatint` nevű fájl is található. Ehhez használhatjuk a `pwd`,
`ls` és `cd` parancsokat, melyről bővebb leírást a `man pwd`, `man cd` és
`mav ls` parancsok nyújtanak. Ha a megfelelő mappában állunk, győződjünk meg róla,
hogy a kiadott `./fatint` parancs a `./` karakterekkel kezdődik.
Ez utasítja a parancssort, hogy a programot a jelenlegi mappában kell keresni,
és nem a rendszerben.

Ha `error while loading shared libraries: libtbb.so.12` hibaüzenetet kapunk,
győződjünk meg róla, hogy telepítettük az #text("Intel Threading Building Blocks", lang: "en") könyvtárat (lásd 1. lépés).

Ha `constraint violation` hibaüzenetet kapunk, akkor a kézzel megadott vagy
a kísérletsorban generált egyik paraméter a megengedett intervallumán kívül
esik. Ellenőrizzük a hivatkozott paraméter kapcsolóját.


==== Telepítés egyéb rendszeren

A program csak Ubuntu operációs rendszeren került tesztelésre, így a megfelelő
működés egyéb operációs rendszereken nem garantálható. Forráskódból való
fordításhoz lásd a fejlesztői dokumentáció @build-from-source fejezetét.

=== Parancssori opciók

A modell leírásban (@model-desc) szereplő paraméterek kapcsolók
formájában átadhatóak a `fatint` parancssori programnak, lásd @fatint-flags.

#[
  #show figure: set block(breakable: true)
  #figure(
    [
      #show table.cell.where(x: 0): it => align(left)[#it]
      #show table.cell.where(x: 1): it => align(left)[#it]
      #table(
        columns: 3,
        table.header[*Kapcsoló*][*Magyarázat*][*Alapérték*],
        [`--runs arg`],[Szimulációk száma kísérletenként],[$10$],
        [`--steps arg`],[Maximális körök száma szimulációnként],[$6000$],
        [`--seed arg`],[Véletlenszám generátor kezdőparamétere kísérletenként],[$1$],
        [`--m_init arg`],[$M_"init"$, avagy a populáció kezdő mérete],[$100$],
        [`--n_init arg`],[$N_"init"$, avagy az egyedek genotípusainak kezdőmérete],[$5$],
        [`--p-encounter arg`],[$P_"encounter"$, avagy párosodás valószínűsége],[$0.1$],
        [`--p-crossing arg`],[$P_"crossing"$, avagy keresztezés valószínűsége],[$0.2$],
        [`--p_mutation arg`],[$P_"mutation"$, avagy mutáció valószínűsége],[$0.1$],
        [`--v_min arg`],[$V_"min"$, avagy minimum megengedett gén érték (allél)],[$0$],
        [`--v_max arg`],[$V_"max"$, avagy maximum megengedett gén érték (allél)],[$100$],
        [`--v_mutation arg`],[Maximális abszolút gén módosulás mutáció során],[$2$],
        [`--v_stretch arg`],[
          Gének hozzáadása során:
          - _"Stretch"_ eljárás $V_"stretch"$ együtthatója ha nem nulla,
          - _"Stretch"_ eljárás helyett véletlen gének generálása, ha nulla
        ],[$0$],
        [`--m_const arg`],[$M_"const"$, avagy minimum születésszám egy pár párosodáskor],[$1$],
        [`--m_limit arg`],[$M_"limit"$, több szerepet betölt, lásd @model-desc fejezet],[$15$],
        [`--m_slope arg`],[$M_"slope"$, születésszám együtthatója, lásd @offspring-count-formula egyenlet],[$0$],
        [`--e_increase arg`],[$E_"increase"$, környezet energiapótlása körönként],[$1000$],
        [`--e_consumption arg`],[$E_"consumption"$, egyedek energiaigénye körönként],[$5$],
        [`--e_intake arg`],[$E_"intake"$, egyedek energiabevitele körönként],[$10$],
        [`--e_discount arg`],[$E_"discount"$, egyedek energiapazarlása körönként, lásd @energy-gain-formula egyenlet],[$0.9$],
        [`--sweep arg`],[Kísérletsor futtatása a fenti paraméterek egyikével],[],
        [`--sweep-from arg`],[Kísérletsor paraméterének kezdőértéke],[],
        [`--sweep-by arg`],[Kísérletsor paraméterének változása kísérletről kísérletre],[$1$],
        [`--sweep-to arg`],[Kísérletsor paraméterének utolsó értéke],[],
        [`--disjoint-sets`],[
          Diszjunkt-Halmaz alapú fajszámlálás mélységi bejárás helyett.
          Kapcsoló, tehát nem kell a `true` értéket kiírni.
        ],[`false`],
        [`--format`],[Eredmények kimeneti formátuma, `csv` vagy `svg`.],[`csv`],
        [`--output`],[Kimeneti fájl útvonala. Ha `-` az értéke, a standard kimenetre ír a program],[`-`],
        [`--help`],[Súgó megjelenítése],[]
      )
    ],
    caption: [A `fatint` program kapcsolói. Az `arg` kulcsszó helyére kell írni a kívánt értéket. Részletekért lásd a @model-desc fejezetet.],
  ) <fatint-flags>
]

=== Egy kísérlet futtatása

Egyetlen kísérlet futtatásához nincs más teendőnk, mint a `fatint` eszközt a
kívánt paraméterekkel futtatni. Minden meg nem adott paraméter a fent
meghatározott alapértelmezett értéket kapja, lásd @model-desc fejezet.

Például, ha a $P_"change"$ paramétert $0.03$-ra szeretnénk állítani egy
kísérletben, akkor a `--p_change 0.03` kapcsolót kell beállítanunk, lásd @cpp-demo-p-change:

#command(caption: [Paraméter átadása `fatint` programnak])[
```bash
$ ./fatint --p_change 0.03
```
] <cpp-demo-p-change>

A program az eredményeket CSV formátumban a standard kimenetre fogja írni. Ha
fájlba szeretnénk irányítani, azt az `output` kapcsolóval tehetjük meg, lásd @cpp-demo-output:

#command(caption: [`fatint` eredmények fájlba írása])[
```bash
$ ./fatint --p_change 0.03 --output results.csv
```
] <cpp-demo-output>

Egy kísérlet alapértelmezett beállítás mellett 10 szimulációt futtat, és azok
eredményeit átlagolja. Ez a szám a `--runs` kapcsolóval állítható, lásd @cpp-demo-runs:

#command(caption: [Szimulációk számának megadása `fatint` programnak])[
```bash
$ ./fatint --runs 20 --p_change 0.03 --output results.csv
```
] <cpp-demo-runs>

Egy szimuláció addig tart, amíg az utolsó egyed eltávolításra nem kerül, vagy
amíg a megtett körök száma el nem ér egy limitet. Ez a limit alapértelmezett
beállítások mellett 6000 kör. A generált CSV fájlok mindig a maximális körök
számának megfelelő sort fogják tartalmazni kísérletenként, akkor is, ha a
szimuláció hamarabb terminál. Ez a limit a `--steps` kapcsolóval állítható, lásd @cpp-demo-steps:

#command(caption: [Szimulációk számának megadása `fatint` programnak])[
```bash
$ ./fatint --runs 20 --steps 1000 --p_change 0.03 --output results.csv
```
] <cpp-demo-steps>

=== A generált CSV fájl szerkezete <fatint-csv-desc>

A generált CSV a fejléc után soronként tartalmazza a sornak megfelelő lépés
szimulációkon átívelő statisztikáit, például az fajok átlagos számát az adott
lépésben, lásd @fatint-csv-columns.

#[
  #show figure: set block(breakable: true)
  #figure(
    table(
      columns: 2,
      table.header[*Oszlopok*][*Magyarázat*],
      [`m_init`, `n_init`, ..., `e_discount`],[A szimulációk paraméterei az adott lépésben, lásd @model-desc fejezet vagy @fatint-flags táblázat],
      [`minimum_entity_count`, `average_entity_count`, `maximum_entity_count`],[Az egyedek minimuma, átlaga, maximuma az szimulációk adott lépésében],
      [`entity_count_sd`, `entity_count_error`],[Az egyedek számának normális eloszlása és standard hibája az adott lépésben],
      [`minimum_gene_count`, `average_gene_count`, `maximum_gene_count`],[Az genotípusok hosszának minimuma, átlaga, maximuma az szimulációk adott lépésében],
      [`gene_count_sd`, `gene_count_error`],[Az genotípusok hosszának normális eloszlása és standard hibája az adott lépésben],
      [`minimum_species_count`, `average_species_count`, `maximum_species_count`],[Az fajok számának minimuma, átlaga, maximuma az szimulációk adott lépésében],
      [`species_count_sd`, `species_count_error`],[Az fajok számának normális eloszlása és standard hibája az adott lépésben],
      [`run_N_entity_count`],[Az $N$. szimuláció populációjának száma az adott lépésben],
      [`run_N_gene_count`],[Az $N$. szimulációban a genotípus hossza az adott lépésben],
      [`run_N_species_count`],[Az $N$. szimulációban a fajok száma az adott lépésben],
    ),
    caption: "A generált CSV fájl szerkezete"
  ) <fatint-csv-columns>
]

=== Egy paramétervizsgálat futtatása <param-sweep>

Egyetlen kísérlet gyakran nem elég ahhoz, hogy felmérjük egy paraméter hatását
a modell viselkedésére. Kerekebb képet kapunk, ha a paraméter több értékével
lefuttatunk egy-egy kísérletet. Ezt nevezzük *kísérletsornak*, paramétervizsgálatnak, _"parameter sweep"_-nek vagy _"experiment sweep"_-nek.

Több kísérlet futtatásához az `--sweep`, `--sweep-from`, `--sweep-by` és
`--sweep-to` kapcsolók értékét kell beállítani. Ezen kapcsolókat egyszerre kell
alkalmazni, különben hibaüzenetet kapunk. Ez alól egyedüli kivétel a `--sweep-by`,
melynek alapértelmezett értéke $1$.

Például a @cpp-demo-sweep három kísérletet futtat
$M_"limit" in {10, 20, 30}$ értékkel

#command(caption: [Kísérletsor paraméterezése `fatint` programmal])[
```bash
$ ./fatint --sweep m_limit 10 --sweep-from 10 --sweep-by 10 --sweep-to 30 --output results.csv
```
] <cpp-demo-sweep>

A @fatint-csv-desc fejezetben definiált formátumban itt kap jelentőséget az,
hogy lépésenként listázzuk a paramétereket. Az egyes kísérletek egymás alá
kerülnek a fájlban, a későbbi elemzés során a paraméterek értéke alapján lehet
az egyes eredményeket szétválogatni.

=== Grafikon előállítása <plotting>

A C++ implementáció képes a nyers adatok helyett grafikonon ábrázolni azokat
vektorgrafika (SVG) formátumban. Ehhez a `--format svg` kapcsolót kell
használni, lásd @cpp-demo-plot:

#command(caption: [`fatint` eredményének ábrázolása grafikonon])[
```bash
$ ./fatint --sweep m_limit 10 --sweep-from 10 --sweep-by 10 --sweep-to 30 --format svg --output results.svg
```
] <cpp-demo-plot>

A grafikonon minden a kísérletsor minden kísérlete ugyanarra a grafikonra kerül,
más-más színnel.

=== A FATINT modell implementáció könyvtárként való használata

A C++ implementáció egyszerre egy eszköz és egy könyvtár, mely beépíthető egyéb
programokba.

Ehhez a projektünkbe fel kell venni a `libfatint` könyvtárat, majd hivatkozni
rá, lásd @cpp-cmake:

#source-listing(caption: [`fatint` hivatkozása `CMakeLists.txt` fájlban])[
```cmake
#...
add_subdirectory(libs/libfatint)
add_executable(some_program "src/main.cpp")
target_link_libraries(some_program PRIVATE libfatint)
#...
```
] <cpp-cmake>

A könyvtár magja a `Simulator` osztály. Ez az osztály végzi a szimuláció
futtatását, a konstruktorában megadott implementációs példányok koordinálásával.

A konstruktorába a következő függőségeket kell injektálni:

/ `fatint::genetics::ISimilarity`: Ellenőrzi egy távolságmetrika alapján, hogy két egyed hány utódot képes létrehozni. A könyvár jelenleg egy implementációt tartalmaz: `EulideanDistanceSimilarity`
/ `fatint::genetics::ISelection`: A párválasztó algoritmus. A könyvtár jelenleg egy implementációt tartalmaz: `ReservoirSelection`
/ `fatint::genetics::IReproduction`: Az egyed örökítő algoritmus. A könyvtár jelenleg egy implementációt tartalmaz: `GeneticReproduction`
/ `fatint::genetics::IGeneAdder`: Az egyedek új genotípusát bővítő algoritmus. A könyvtár jelenleg két implementációt kínál: `RandomGeneAdder` és `VStretchGeneAdder`
/ `fatint::measurement::ISpeciesCounter`: A faj számláló algoritmus. A könyvtár jelenleg két implementációt kínál: `DepthFirstSearchSpeciesCounter` és `DisjointSetsSpeciesCounter`

A konstruktor `unique_ptr` pointereket vesz át, tehát az implementációs
példányok élettartamát a `Simulator` osztály kezeli. Egy minimális példát nyújt
a @libfatint-example.

#source-listing(caption: [Minimális példa egy szimuláció futtatására és kiértékelésére, alapértelmezett paraméterekkel])[
#show block: set text(size: 8pt)
```cpp
auto make_simulator(fatint::simulation::RunParameters params)
  -> std::unique_ptr<fatint::simulation::Simulator>
{
    fatint::genetics::EuclideanDistanceSimilarity similarity(
        params.reproduction_parameters
    );

    return std::make_unique<fatint::simulation::Simulator>(
        std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity),
        std::make_unique<fatint::genetics::ReservoirSelection>(
            std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity)
        ),
        std::make_unique<fatint::genetics::GeneticReproduction>(
            std::make_unique<fatint::genetics::BoundedMutation>(
                params.genetic_probabilities.p_mutation,
                params.genetic_parameters.v_mutation
            ),
            std::make_unique<fatint::genetics::Crossover>(
                params.genetic_probabilities.p_crossing
            ),
            params.limits.v_min,
            params.limits.v_max
        ),
        std::make_unique<fatint::genetics::RandomGeneAdder>(
            params.limits.v_min,
            params.limits.v_max
        ),
        std::make_unique<fatint::measurement::DepthFirstSearchSpeciesCounter>(
            std::make_unique<fatint::genetics::EuclideanDistanceSimilarity>(similarity)
        ),
        params
    );
}

fatint::simulation::RunParameters params;
auto simulator = make_simulator(params);

fatint::math::Random rng(params.seed);
fatint::simulator::RunStates states = simulator->run(rng);

fatint::math::ExperimentResults results = fatint::math::measure(1, params.steps, states);
```
] <libfatint-example>
