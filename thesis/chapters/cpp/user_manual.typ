#import "../../lib/elteikthesis.typ": todo, warning

== Felhasználói dokumentáció (C++) <cpp-user-manual>

Ugyan a NetLogo egy könnyen kezelhető, látványos módja a modellek viselkedésének
elemzéséhez, sajnos meglehetősen lassú. //lásd @performance fejezet.

A C++ implementáció (továbbiakban *`fatint` program*) egy felület nélküli,
parancssorból futtatható implementációja a FATINT modellnek (@model-desc),
továbbá egy könyvtár (továbbiakban *libfatint*), mely beépíthető egyéb
programokba.

=== Rendszerkövetelmények

- 2 évnél nem régebbi Linux disztribúció, például Ubuntu Linux 24.04 LTS
- C++ futásidejű könyvtárak (pl `libc++` vagy `libstdc++`). Nagy valószínűséggel
  az operációs rendszer már tartalmazza.
- 1MB tárhely a programnak
- Nagyjából 100MB tárhely a generálandó adatoknak
- Legalább 128MB memória
- #link("https://www.intel.com/content/www/us/en/developer/tools/oneapi/onetbb.html")[Intel Threading Building Blocks] futásidejű könyvtárai

=== Telepítés

==== Linux rendszer

+ Telepítsük az Intel Threading Building Blocks futásidejű könyvtárat.
  Ubuntu rendszeren ehhez a `libtbb12` csomagot kell telepíteni vagy egy
  grafikus csomagkezelővel, vagy az alábbi pararanccsal:
  ```bash
  $ sudo apt install libtbb12
  ```
+ Látogassuk meg #link("https://github.com/hamrik/fatint-thesis/releases/latest")[a projekt GitHub tárhelyét].
+ Töltsük le a legfrissebb verzió bejegyzésének alján linkelt ZIP fájlt.
+ Csomagoljuk ki egy nekünk tetsző helyre.
+ Nyissunk egy terminált a kicsomagolt mappában.
+ Ellenőrizzük, hogy a program elindul:
  ```bash
  $ ./fatint -h
  ```
  - Ha egy súgót kapunk, minden készen áll a kísérletek futtatására.
  - Ha `No such file or directory` hibaüzetet kapjuk akkor nem jó mappában áll
    a parancssor. Győződjünk meg róla, hogy abban a mappában áll a parancssor,
    amelyikben a `fatint` nevű fájl is található. Ehhez használhatjuk a `pwd`,
    `ls` és `cd` parancsokat, melyről bővebb lerást a `man pwd`, `man cd` és
    `mav ls` parancsok nyújtanak.
    Ha a megfelelő mappában állunk, győződjünk meg róla, hogy a kiadott
    `./fatint` parancs a `./` karakterekkel kezdődik. Ez utasítja a parancssort,
    hogy a programot a jelenlegi mappában kell keresni, és nem a rendszerben.
  - Ha `error while loading shared libraries: libtbb.so.12` hibaüzenetet kapunk,
    győződjünk meg róla, hogy telepítettük az Intel Threading Building Blocks
    könyvtárat (lásd 1. lépés).

==== Egyéb rendszer

A program nem volt tesztelve egyéb operációs rendszereken, így a megfelelő
működés nem garantálható. Forráskódból való fordításhoz lásd a fejlesztői
dokumentáció @build-from-source fejezetét.

=== Parancssori opciók

A modell leírásban (@model-desc) szereplő paraméterek kapcsolók
formájában átadhatóak a `fatint` parancssori programnak, lásd @fatint-flags.

#[
  #show figure: set block(breakable: true)
  #figure(
    table(
      columns: 3,
      table.header[*Kapcsoló*][*Magyarázat*][*Alapérték*],
      [`--experiments arg`],[Kísérletek száma],[$1$],
      [`--runs arg`],[Szimulációk száma kíséletenként],[$10$],
      [`--steps arg`],[Maximális körök száma szimulációnként],[$6000$],
      [`--seed arg`],[Véletlenszám generátor kezdőparamétere kísérletenként],[$1$],
      [`--starting-population arg`],[Populáció kezdő mérete],[$100$],
      [`--starting-allele-count arg`],[Egyedek genotípusainak kezdőmérete],[$5$],
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
      [`--dp arg`],[Populáció kezdő méretének módosítása kíséletenként],[$0$],
      [`--dg arg`],[Egyedek genotípusának kezdőértékének módosítása kísérletenként],[$0$],
      [`--sweep_p_encounter arg`],[$P_"encounter"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_p_change arg`],[$P_"change"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_p_crossing arg`],[$P_"crossing"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_p_mutation arg`],[$P_"mutation"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_v_min arg`],[$V_"min"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_v_max arg`],[$V_"max"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_v_mutation arg`],[$V_"mutation"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_v_stretch arg`],[$V_"stretch"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_m_const arg`],[$M_"const"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_m_limit arg`],[$M_"limit"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_m_slope arg`],[$M_"slope"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_e_increase arg`],[$E_"increase"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_e_consumption arg`],[$E_"consumption"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_e_intake arg`],[$E_"intake"$ értékének módosulása kísérletenként],[$0$],
      [`--sweep_e_discount arg`],[$E_"discount"$ értékének módosulása kísérletenként],[$0$],
      [`--disjoint-sets`],[
        Diszjunkt-Halmaz alapú fajszámlálás mélységi bejárás helyett.
        Kapcsoló, tahát nem kell a `true` értéket kiírni.
      ],[`false`],
      [`--format`],[Eredmények kimeneti formátuma, `csv` vagy `svg`.],[`csv`],
      [`--output`],[Kimeneti fájl útvonala. Ha `-` az értéke, a standard kimenetre ír a program],[`-`],
      [`--help`],[Súgó megjelenítése],[]
    ),
    caption: [A `fatint` program kapcsolói. Az `arg` kulcsszó helyére kell írni a kívánt értéket. Részletekért lásd a @model-desc fejezetet.],
  ) <fatint-flags>
]

Kísérletsor esetén a kísérletek közötti különbségek a `--sweep_<parameter>`
kapcsolókkal adhatók meg (@param-sweep).

#warning[
  Fontos, hogy a program nem állít elő a paraméterekből Descartes-szorzatot. Ha
  több `sweep` paramétert használunk, egyszerre változik mindegyik `sweep`
  paraméter, garantálva, hogy összesen `--experiments` számú kísérlet fut.
  Ez megtévesztő lehet, ezért erősen javasolt egyszerre csak egy `sweep`
  paramétert megadni.
]

Megadható továbbá a véletlenszám generátor kezdőparamétere (`--seed`), a
kimeneti fájl útvonala (`--output`) és annak formátuma (`--format`, @plotting).

=== Egy kísérlet futtatása

Egyetlen kísérlet futtatásához nincs más teendőnk, mint a `fatint` eszközt az
általunk kívánt paraméterekkel futtatni. Minden meg nem adott paraméter a fent
meghatározott alapértelmezett értéket kapja, lásd @model-desc fejezet.

Például, ha a $P_"change"$ paramétert $0.03$-ra szerenénk állítani egy
kísérletben, akkor a `--p_change 0.03` kapcsolót kell beállítanunk. Példa:

```bash
$ ./fatint --p_change 0.03
```

A program az eredményeket CSV formátumban a standard kimenetre fogja írni. Ha
fájlba szeretnénk irányítani, azt az `output` kapcsolóval tehetjük meg:

```bash
$ ./fatint --p_change 0.03 --output results.csv
```

Egy kísérlet alapértelmezett beállítás mellett 10 szimulációt futtat, és azok
eredményeit átlagolja. Ez a szám a `--runs` kapcsolóval állítható:

```bash
$ ./fatint --runs 20 --p_change 0.03 --output results.csv
```

Egy szimuláció addig tart, amíg az utolsó egyed eltávolításra nem kerül, vagy
amíg a megtett körök száma el nem ér egy limitet. Ez a limit alapértelmezett
beállítások mellett 6000 kör. A generált CSV fájlok mindig a maximális körök
számának megfelelő sort fognak tartalmazni kísérletenként, akkor is, ha a
szimuláció hamarabb terminál. Ez a limit a `--steps` kapcsolóval állítható:

```bash
$ ./fatint --runs 20 --steps 1000 --p_change 0.03 --output results.csv
```

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
      [`starting_entity_count`, `starting_allele_count`, ..., `e_discount`],[A szimulációk paraméterei az adott lépésben, lásd @model-desc fejezet vagy @fatint-flags táblázat],
      [`minimum_entity_count`, `average_entity_count`, `maximum_entity_count`],[Az egyedek minimuma, átlaga, maximuma az szimulációk adott lépésében],
      [`entity_count_sd`, `entity_count_error`],[Az egyedek számának normális eloszlása és standard hibája az adott lépésben],
      [`minimum_allele_count`, `average_allele_count`, `maximum_allele_count`],[Az genotípusok hosszának minimuma, átlaga, maximuma az szimulációk adott lépésében],
      [`allele_count_sd`, `allele_count_error`],[Az genotípusok hosszának normális eloszlása és standard hibája az adott lépésben],
      [`minimum_species_count`, `average_species_count`, `maximum_species_count`],[Az fajok számának minimuma, átlaga, maximuma az szimulációk adott lépésében],
      [`species_count_sd`, `species_count_error`],[Az fajok számának normális eloszlása és standard hibája az adott lépésben],
      [`run_N_entity_count`],[Az $N$-dik szimuláció populációjának száma az adott lépésben],
      [`run_N_allele_count`],[Az $N$-dik szimulációban a genotípus hossza az adott lépésben],
      [`run_N_species_count`],[Az $N$-dik szimulációban a fajok száma az adott lépésben],
    ),
    caption: "A generált CSV fájl szerkezete"
  ) <fatint-csv-columns>
]

=== Egy paramétervizsgálat futtatása <param-sweep>

Egyetlen kísérlet gyakran nem elég ahhoz, hogy felmérjük egy paraméter hatását
a modell viselkedésére. Kerekebb képet kapunk, ha a paraméter több értékével
lefuttatunk egy-egy kísérletet. Ezt nevezzük *paramétervizsgálatnak*,
*kísérletsornak*, _"parameter sweep"_-nek vagy _"experiment sweep"_-nek.

Több kísérlet futtatásához az `--experiments` kapcsoló értékét kell beállítani:

```bash
$ ./fatint --experiments 5 --runs 20 --steps 1000 --p_change 0.03 --output results.csv
```

A fenti beállításokkal mindegyik szimuláció ugyanúgy fog viselkedni, mert a
kezdeti paramétereik egyeznek.

Ahhoz, hogy egy paraméter több különböző értékével futtassunk kírérletet a
`--sweep_` kapcsolókra van szükség. Minden beállítható paraméterhez tartozik
egy, és azt adja meg, hogy az egyes kísérletek között mennyit módosítson a
program az adott paraméter kezdőértékén.

Például, hogy egyszerre szerenénk kísétleteket futtatni
$M_"limit" in {10, 20, 30}$ értékkel:

```bash
$ ./fatint --experiments 3 --m_limit 10 --sweep_m_limit 10 --output results.csv
```

A @fatint-csv-desc fejezetben definiált formátumban itt kap jelentőséget az,
hogy lépésenként listázzuk a paramétereket. Az egyes kísérletek egymás alá
kerülnek a fájlban, a későbbi elemzés során a paraméterek értéke alapján lehet
az egyes eredményeket szétválogatni.

=== Grafikon előállítása <plotting>

A C++ implementáció képes a nyers adatok helyett grafikonon ábrázolni azokat
vektorgrafika (SVG) formátumban. Ehhez a `--format svg` kapcsolót kell
használni.

```bash
$ fatint --experiments 3 --m_limit 10 --sweep_m_limit 10 --format svg --output results.svg
```

A grafikonon minden kísérlet ugyanarra a grafikonra kerül, más-más színnel.

=== A FATINT modell implementáció könyvtárként való használata

A C++ implementáció egyszerre egy eszköz és egy könyvtár, mely beépíthető egyéb
programokba.

Ehhez a projektünkbe fel kell venni a `libfatint` könyvtárat, majd hivatkozni
rá:

```cmake
#...
add_subdirectory(libs/libfatint)
add_executable(some_program "src/main.cpp")
target_link_libraries(some_program PRIVATE libfatint)
#...
```

A könytár magja a `Simulator` osztály. Ez az osztály végzi a szimuláció
futtatását, a konstruktárában megadott implementációs példányok koordinálásával.

A konstruktorába a következő függőségeket kell injektálni:

/ `fatint::genetics::ISimilarity`: A távolságmetrika. A könyvár jelenleg egy implmentációt tartalamaz: `SimilarityImpl`
/ `fatint::genetics::ISelection`: A párválasztó algoritmus. A könyvtár jelenleg egy implementációt tartalmaz: `SelectionImpl`
/ `fatint::genetics::IReproduction`: Az egyed örökítő algoritmus. A könyvtár jelenleg egy implementációt tartalmaz: `GeneticReproduction`
/ `fatint::genetics::IValidator`: A gyermekegyed megfelelőségi feltétel. A könyvtár jelenleg egy implementációt tartalmaz: `ValidatorImpl`
/ `fatint::genetics::IAlleleAdder`: Az egyedek új genotípusát bővítő algoritmus. A könyvtár jelenleg két implementációt kínál: `RandomAlleleAdder` és `VStretchAlleleAdder`
/ `measurement::ISpeciesCounter`: A faj számláló algoritmus. A könytár jelenleg két implementációt kínál: `DepthFirstSearchSpeciesCounter` és `DisjointSetsSpeciesCounter`

A konstruktor referenciákat vesz át, és nem birtokolja a függőségek
élettartamát. A könyvtár használójának felelőssége életben tartani a
dependenciákat. Ennek az az előnye, hogy több, párhuzamosan futó szimulátor is
használhatja a dependenciákat egyszerre. Egy minimális példát nyújt a
@libfatint-example

#todo[Consider switching to move semantics]

#figure(
  align(left)[```cpp
  fatint::genetics::SimilarityImpl similarity;
  fatint::genetics::SelectionImpl selection;
  fatint::genetics::MutationImpl mutation;
  fatint::genetics::CrossoverImpl crossover;
  fatint::genetics::GeneticReproduction reproduction(
      mutation,
      crossover
  );
  fatint::genetics::ValidatorImpl validator;
  fatint::genetics::RandomAlleleAdder allele_adder;
  fatint::measurement::DepthFirstSearchSpeciesCounter species_counter;

  fatint::simulation::Simulator simulator(
      similarity,
      selection,
      reproduction,
      validator,
      allele_adder,
      species_counter
  );

  fatint::simulation::RunParameters params;

  fatint::math::Random rng(params.seed);
  fatint::simulator::RunStates states = simulator.run(rng, params);

  fatint::math::ExperimentResults = fatint::math::measure(1, params.steps, states);
  ```],
  caption: "Minimális példa egy szimuláció futtatására és kiértékéelésére, alapértelmezett paraméterekkel"
) <libfatint-example>
