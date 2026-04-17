#import "/lib/elteikthesis.typ": todo

== C++ implementáció

#todo("Rationale for implementing in C++ vs NetLogo. Compare performance.")

=== Specifikáció

=== Architektúra

=== Forráskód fordítása

A forráskód fordításához a következő elemekre van szükség:

- *CMake* 3.11 vagy újabb
- Egy C++20 szabványt támogató *C++ fordító* (pl. GCC 9 vagy újabb)
- Intel Thread Building Blocks (Elhagyható, de ajánlott, különben a szimuláció egyetlen szálon fog futni, jelentősen lassítva azt)

#todo("Migrate from TBB to custom job queue")

#todo("Check versions")

Minden további függőséget már tartalmaz a repó.

A fordításhoz nyisson egy parancssort a repó gyökérmappájában, majd adja ki a következő parancsokat:

```bash
$ cmake -S . -B ./build -DCMAKE_BUILD_TYPE=Release
$ cmake --build build --parallel
```

A kész program a `./build/fatint` mappába kerül.

=== Tesztek futtatása

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
fatint -e 11 --p_encounter 0.05 --sweep_p_encounter 0.005 \
> p_encounter_0.05-0.10.csv
fatint -e 11 --p_encounter 0.05 --sweep_p_encounter 0.005 \
-f svg > p_encounter_0.05-0.10.svg

fatint -e 6 --p_mutation 0 --sweep_p_mutation 0.1 \
> p_mutation_0.00-0.50.csv
fatint -e 6 --p_mutation 0 --sweep_p_mutation 0.1 \
-f svg > p_mutation_0.00-0.50.svg

fatint -e 9 --p_crossing 0 --sweep_p_mutation 0.1 \
> p_crossing_0.00-0.80.csv
fatint -e 9 --p_crossing 0 --sweep_p_mutation 0.1 \
-f svg > p_crossing_0.00-0.80.svg

fatint -e 11 --p_change 0.0005 --sweep_p_mutation 0.00005 \
> p_change_0.0005-0.001.csv
fatint -e 11 --p_change 0.0005 --sweep_p_mutation 0.00005 \
-f svg > p_change_0.0005-0.001.svg

fatint -e 21 --p_change 0.0005 --m_limit 0 --sweep_m_limit 1 \
> p_change_0.0005_m_limit_0-20.csv
fatint -e 21 --p_change 0.0005 --m_limit 0 --sweep_m_limit 1 \
-f svg > p_change_0.0005_m_limit_0-20.svg

fatint -e 20 --p_change 0.0005 --v_stretch 1 --sweep_v_stretch 1 \
> p_change_0.0005_v_stretch_1-20.csv
fatint -e 20 --p_change 0.0005 --v_stretch 1 --sweep_v_stretch 1 \
-f svg > p_change_0.0005_v_stretch_1-20.svg
```

#todo("Add command-line option to output multiple formats at once")

#todo([
  Explore better alternatives to "eyeballing it", such as:
  - Comparing graph characteristics
  - Computing Cross-Correlation, Dynamic Time Wapring or Fréchet distance
  - Comparing inter-spike intervals
])
