#import "../../lib/elteikthesis.typ": todo

== C++ implementáció <cli-user-manual>

Ugyan a NetLogo egy könnyen kezelhető, látványos módja a modellek viselkedésének elemzéséhez, sajnos meglehetősen lassú.
Például a `stretch-new-allele-sweep-stretch` kísérletsor futtatása egy i7 1360p processzoron 7 perc 4 másodpercet vesz igénybe.

A C++ implementáció egy felület nélküli, parancssorban futtatható változata a FATINT modellnek,
továbbá egy könyvtár, mely beépíthatő egyéb programokba.

A fenti kísérletsor futtatása a C++ implementációnak 10 másodpercbe telik.

=== Rendszerkövetelmények

- 2 évnél nem régebbi Linux disztró #todo("Windows and MacOS are also viable but needs testing")
- C++ futásidejű könyvtárak (pl `libc++` vagy `libstdc++`)
- 560KB tárhely a programnak
- Nagyjából 100MB tárhely a generálandó adatoknak
- Legalább 32MB memória #todo("Verify")

=== Telepítés

A legfrissebb verzió a projekt repójából tölthető le: #link("https://github.com/hamrik/fatint-thesis/releases").
Csak le kell tölteni a zip fájlt és egy tetszőleges helyre kicsomagolni.
#todo("Make a release via CI")

Forráskódból való fordításhoz lásd @build-from-source.

=== Parancssori opciók

A modell leírásban (@model-desc) szereplő paraméterek kapcsoló formájában
átadhatóak a `fatint` parancssori programnak.

Kísérletsor esetén a kísérletek közötti különbségek a `--sweep_<parameter>` kapcsolókkal adhatók meg (@param-sweep).

Ezenkívül megadható a véletlenszám generátor kezdőparamétere (`--seed`), a kimeneti fájl útvonala (`--output`) és formátuma (`--format`, @plotting)

```
Usage:
  ./fatint [OPTION...]

  -e, --experiments arg         Number of experiments (default: 1)
  -r, --runs arg                Number of runs per experiment (default: 10)
  -s, --steps arg               Number of iterations (default: 6000)
  -S, --seed arg                Random seed (default: 1)
  -p, --starting_population arg
                                Initial population size (default: 100)
  -g, --starting_allele_count arg
                                Initial number of alleles (default: 5)
      --p_encounter arg         Probability of reproduction attempt
                                (default: 0.1)
      --p_change arg            Probability of new gene per successful
                                reproduction (default: 0.0)
      --p_crossing arg          Probability of crossover per gene (default:
                                0.2)
      --p_mutation arg          Probability of mutation per gene (default:
                                0.1)
      --v_min arg               Minimum allele (default: 0)
      --v_max arg               Maximum allele (default: 100)
      --v_mutation arg          Maximum allele mutation (default: 2)
      --v_stretch arg           Stretch factor when introducing new gene
                                (0 = generate random gene) (default: 0.0)
      --m_const arg             Minimum number of offsprings per
                                reproduction (default: 1)
      --m_limit arg             Maximum number of offsprings per
                                reproduction (default: 15)
      --m_slope arg             How much should similarity affect offspring
                                count (default: 0.0)
      --e_increase arg          Amount of energy the environment
                                replenishes after each iteration (default:
                                1000.0)
      --e_consumption arg       Energy consumption per iteration (default:
                                5.0)
      --e_intake arg            Energy intake per iteration (default: 10.0)
      --e_discount arg          Energy discount per age (default: 0.9)
      --dp arg                  Initial population size delta (default: 0)
      --dg arg                  Initial number of alleles delta (default:
                                0)
      --sweep_p_encounter arg   The amount p_encounter is increased by
                                between experiments (default: 0)
      --sweep_p_change arg      The amount p_change is increased by between
                                experiments (default: 0)
      --sweep_p_crossing arg    The amount p_crossing is increased by
                                between experiments (default: 0)
      --sweep_p_mutation arg    The amount p_mutation is increased by
                                between experiments (default: 0)
      --sweep_v_min arg         The amount v_min is increased by between
                                experiments (default: 0)
      --sweep_v_max arg         The amount v_max is increased by between
                                experiments (default: 0)
      --sweep_v_mutation arg    The amount v_mutation is increased by
                                between experiments (default: 0)
      --sweep_v_stretch arg     The amount v_stretch is increased by
                                between experiments (default: 0.0)
      --sweep_m_const arg       The amount m_const is increased by between
                                experiments (default: 0)
      --sweep_m_limit arg       The amount m_limit is increased by between
                                experiments (default: 0)
      --sweep_m_slope arg       The amount m_slope is increased by between
                                experiments (default: 0.0)
      --sweep_e_increase arg    The amount e_increase is increased by
                                between experiments (default: 0)
      --sweep_e_consumption arg
                                The amount e_consumption is increased by
                                between experiments (default: 0)
      --sweep_e_intake arg      The amount e_intake is increased by between
                                experiments (default: 0)
      --sweep_e_discount arg    The amount e_discount is increased by
                                between experiments (default: 0)
  -o, --output arg              Output file (default: "")
  -f, --format arg              Output format (default: csv)
  -h, --help                    Print help
```
#todo("Translate")

=== Egy kísérlet futtatása

Egyetlen kísérlet futtatásához nincs más teendőnk, mint a `fatint` eszközt az álatunk kívánt paraméterekkel futtatni.
Minden meg nem adott paraméter a fent meghatározott alapértelmezett értéket kapja.

Például, ha a $P_"change"$ paramétert 0.03-ra szerenénk állítani egy kísérletben, akkor a `--p_change 0.03` kapcsolót kell beállítanunk. Példa:

```bash
build$ ./fatint --p_change 0.03
```

A program az eredményeket CSV formátumban a standard kimenetre fogja írni. Ha fájlba szeretnénk irányítani, azt az `output` kapcsolóval tehetjük meg:

```bash
build$ ./fatint --p_change 0.03 --output results.csv
```

Egy kísérlet alapértelmezett beállítás mellett 10 szimulációt futtat, és azokat átlagolja. Ez a szám a `--runs` kapcsolóval állítható:

```bash
build$ ./fatint --runs 20 --p_change 0.03 --output results.csv
```

Egy szimuláció addig tart, amíg az utolsó egyed eltávolításra nem kerül vagy amíg a megtett körök száma el nem ér egy limitet. Ez a limit alapértelmezett beállítások mellett 6000 kör. A generált CSV fájlok mindig a maximális körök számának megfelelő sort fognak tartalmazni, akkor is, ha a szimuláció hamarabb terminál. Ez a limit a `--steps` kapcsolóval állítható:

```bash
build$ ./fatint --runs 20 --steps 1000 --p_change 0.03 --output results.csv
```

=== Egy paramétervizsgálat futtatása <param-sweep>

#todo("Explain what a parameter sweep is")

Több kísérlet futtatásához az `--experiments` kapcsoló értékét kell beállítani:

```bash
build$ ./fatint --experiments 5 --runs 20 --steps 1000 --p_change 0.03 --output results.csv
```

A fenti beállításokkal mindegyik szimuláció ugyanúgy fog viselkedni, mert a kezdeti paramétereik egyeznek.

Ahhoz, hogy egy paraméter több különböző értékével futtassunk kírérletet a `--sweep_*` kapcsolókra van szükség. Minden beállítható paraméterhez tartozik egy, és azt adja meg, hogy az egyes kísérletek között mennyit módosítson a program az adott paraméter kezdőértékén.

Például, hogy egyszerre szerenénk kísétleteket futtatni $M_"limit" = 10$, $M_"limit" = 20$ és $M_"limit" = 30$ értékkel:

```bash
build$ ./fatint --experiments 3 --m_limit 10 --sweep_m_limit 10 --output results.csv
```

A kimeneti fájl minden sorában megtalálható az adott körnek a paraméterei, így követhető, hogy melyik érték milyen kimenetelt produkált.

Ha egyszerre több `sweep` kapcsolót is használunk, akkor mindegyik paraméter egyszerre lesz módosítva, azaz *nem* a lehetséges paraméterek Descartes-szorzatát állítja elő.

=== Grafikon előállítása <plotting>

A C++ implementáció képes a nyers adatok helyett grafikonon ábrázolni azokat vektorgrafika (SVG) formátumban.
Ehhez a `--format svg` kapcsolót kell használni.

```bash
build$ fatint --experiments 3 --m_limit 10 --sweep_m_limit 10 --format svg --output results.svg
```

=== A FATINT modell implementáció könyvtárként való használata

A C++ implementáció egyszerre egy eszköz és egy könyvtár, mely beépíthető egyéb programokba.

Ehhez a projektünkbe fel kell venni a könyvtárat, majd hivatkozni rá:

```cmake
#...
add_subdirectory(libs/libfatint)
add_executable(some_program "src/main.cpp")
target_link_libraries(some_program PRIVATE libfatint)
#...
```

#todo("Make library compatible with FindPackage()")

A projekt parancssori moduljának `main` függvénye egy jó példát biztosít a könyvtárként való használatra.
Részletekért lásd a fejlesztői dokumentációt.
