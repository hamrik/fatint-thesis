#import "/lib/elteikthesis.typ": todo
#import "/lib/plot.typ": *

== Fejlesztői dokumentáció (NetLogo)

A fejlesztői dokumentáció részletezi a FATINT modell NetLogo implementációjának
működési követelményeit, a meghozott döntéseket és tesztelés menetét.

=== Specifikáció

A NetLogo implementáció feladata a FATINT (@model-desc) modell pontos
szimulációja, és a @fatint cikkben közölt adatok replikációja.

==== Funkcionális követelmények

Az implementáció:
- Lehetőséget nyújt a @model-params fejeztben szereplő összes paraméter
  beállítására.
- Lehetőséget nyújt az összes paraméter alapértékre való visszaállítására.
- Lehetőséget nyújt a szimulációt körönként vagy folyamatosan futtatni.
- A modell állapotát a felületen grafikonok formájában tükrözi.
- A modell pontosan követi a @model-desc fejezetben leírt viselkedést.
- Lehetőséget nyújt kísérletek és kísérletsorok létrehozására, futtatására, a
  kísérlet részeként futtatott szimulációk állapotának folyamatos rögzítésére és
  mentésére.
- Lehetőséget nyújt a futó szimulációk félbeszakítására.
- Az @netlogo-usecase diagramon ábrázolt felhasználói eseteket támogatja.

==== Nem funkcionális követelmények

- Az implementáció nem függ a NetLogo keretrendszeren kívül semmilyen egyéb
  külső elemtől.
- Az implementáció felülete átlátható.
- A felület reszponzív marad a szimuláció állapotától függetlenül.
- Az implementáció igyekszik takarékoskodni a memóriával és a számítási
  kapacitással.
- Egy 200 szimulációból, szimulációnként legfeljebb 6000 lépésből álló
  kísérletsort 5 percen belül lefuttat egy munkaállomás kategóriás számítógépen.

==== Felhasználói esetek

#figure(
  image("/assets/netlogo_usecase.svg"),
  caption: [
    A NetLogo implementáció és a BehaviorSpace releváns funkcióinak felhasználói
    eset diagramja
  ],
) <netlogo-usecase>

==== Felületi terv

A NetLogo program grafikus felülete interaktívan szerkeszthető, így megfelelő
eszköz a felület terv elkészítésére is, lásd @netlogo-model-ui-plan.

#figure(
  image("../../assets/screenshots/netlogo_model_ui.png", width: 50%),
  caption: [ A NetLogo 6.4.0 fő ablaka benne a modell "felülettervével" ],
) <netlogo-model-ui-plan>

==== Felhasználói történetek

A felhasználó szimulációkat szeretne futtatni, hogy elemezhesse a FATINT modell
viselkedését. Az implementáció akkor működik megfelelően, ha a @netlogo-gwt
táblázatban szereplő interakciókra a táblázatban előírt módon reagál.

#figure(
  table(
    columns: 3,
    table.header[*GIVEN / Feltéve, hogy a felhasználó...*][*WHEN / Amikor...*][*THEN / Akkor...*],
    [Elindított egy szimulációt], [A populáció mérete nullára csökken], [A szimuláció leáll],
    [Elindított egy szimulációt], [Megszakítja a szimulációt], [A szimuláció leáll],
    [Legalább egy paramétert módosított],
    [Megnyomja a _"Reset"_ gombot],
    [Minden paraméter visszaáll alapértelmezett értékre],

    [Elindított korábban kézzel egy szimulációt],
    [Megnyomja a _"Setup"_ gombot],
    [A korábbi szimuláció állapota törlődik, és egy új kezdő populáció jön létre],

    [Elindított kézzel egy szimulációt, és a populáció nem üres],
    [Megnyomja a `+` gombot],
    [Minden egyed genotípusa bővül egy-egy új génnel],

    [Elindított egy kísérletet vagy kísérletsort],
    [A szimuláció sikeresen befejeződik],
    [Az eredmények a felhasználó által megadott útvonalon mentésre kerülnek],

    [Elindított egy kísérletet vagy kísérletsort],
    [A szimulációt megszakítja],
    [A részeredmények a felhasználó által megadott útvonalon mentésre kerülnek],
  ),
  caption: "A modell elvárt viselkedése a paraméterek függvényében",
) <netlogo-gwt>

=== Implementáció részletei

==== Az egyedek életciklusa

==== A fajok megszámlálása

==== Teljesítmény

=== Tesztelés

==== Populáció öregedése

+ Kattinsunk a *Reset* gombra, hogy minden paraméter alapértelmezett értéket
  vegyen fel.
+ Állítsuk $P_"encounter"$ értékét $0$-ra, minden mást hagyjunk alapértelmezett
  értéken.
+ Kattintsunk a *Setup*, majd a *500 steps* gombra.
+ A populáció létszáma 30 kör alatt nullára kell essen. A szimulációnak 30 körön
  belül terminálnia kell.

==== Alapértelmezett működés

+ Kattinsunk a *Reset* gombra, hogy minden paraméter alapértelmezett értéket
  vegyen fel.
+ Kattintsunk a *Setup*, majd a *500 steps* gombra.
+ A populáció létszáma először megugrik, majd stabilizálódik a $[100, 120]$
  intervallumon belül. A fajok száma a szimuláció végére $1$. Lásd
  @netlogo-test-default-settings.

==== Új gének létrejötte

+ Kattinsunk a *Reset* gombra, hogy minden paraméter alapértelmezett értéket
  vegyen fel.
+ Állítsuk $P_"change"$ értékét egy pozitív, egynél kisebb értékre, például $0.0005$.
+ Kattintsunk a *Setup*, majd a *500 steps* gombra.
+ A populáció létszáma először megugrik, majd stabilizálódik a $[100, 120]$
  intervallumon belül. A gének száma a szimuláció végére magasabb, mint $5$.
  A fajszámláló grafikonon előfordulhatnak kisebb tüskék. Lásd
  @netlogo-test-p-change.

#grid(
  columns: 2,
  gutter: 12pt,
  [
    #figure(
      image("/assets/screenshots/netlogo_test_default_settings.png"),
      caption: [Modell állapot grafikonok alakulása alapértelmezett beállítások mellett.],
    ) <netlogo-test-default-settings>
  ],
  [
    #figure(
      image("/assets/screenshots/netlogo_test_p_change.png"),
      caption: [Modell állapot grafikonok alakulása $P_"change" = 0.0005$ mellett.],
    ) <netlogo-test-p-change>
  ],
)

==== A cikk grafikonjai, mint integrációs tesztek

A modellbe előre beépített kísérletsorok segítségével meggyőződhetünk róla,
hogy a modell implmenetáció az elvárt módon viselkedik. Ezen kísérletek grafikus
felület nélkül is futtathatóak a NetLogo gyökérmappájában található
`NetLogo_Console` eszköz segítségével:

```bash
NetLogo$ ./NetLogo_Console --headless --model model.nlogo --experiment experiment-name --table output.csv --stats stats.csv
```

/ `--headless`: Ez a kapcsoló megakadályozza a felhasználói felület betöltését
/ `--model`: Ennek a kapcsolónak kell megadni a modell fájl elérési útvonalát
/ `--experiment`: A futtatni kívánt BehaviorSpace kísérlet neve
/ `--table`: A szimuláció ereményének mentési útvonala
/ `--stats`: A statisztikák mentési útvonala

A @fatint cikkben szereplő kísérletek az alábbi nevekkel érhetők el ebben a modellben:

- `default-settings`
- `sweep-p-encounter`
- `sweep-p-mutation`
- `sweep-p-crossing`
- `sweep-p-change`
- `sweep-m-limit`
- `sweep-v-stretch`

A fenti kísérleten túl a modell tartalmaz három teljesítmény felmérést:

- `benchmark-species-counter-dfs-one-species`
- `benchmark-species-counter-dfs-many-species`
- `benchmark-species-counter-ds-one-species`
- `benchmark-species-counter-ds-many-species`
- `benchmark-simulator-no-churn`
- `benchmark-simulator-churn`

Alapértelmezett paraméterek mellett a fajok átlagos száma nem eshet 0-ra,
lásd @netlogo-species-comp-default.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    netlogo_species_plot("/data/default-NetLogo.csv", none),
    image("/assets/paper_excerpts/default_params.png", height: 20%),
  ),
  caption: [
    Fajok számának átlagos alakulása alapértelmezett beállítások mellett.

    Felül: NetLogo 6.4.0 implementáció. Alul: @fatint.
  ],
) <netlogo-species-comp-default>

$P_"encounter"$ alacsony értékeknél biztos kipusztulást, és magasabb értékeknél
is legfeljebb egy faj fennmaradását garantálja, lásd
@netlogo-species-comp-p-encounter.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    netlogo_species_plot("/data/p_encounter-NetLogo.csv", [$P_"encounter"$]),
    image("/assets/paper_excerpts/P_encounter__0.05__0.095.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $P_"encounter"$ különböző értékei mellett.

    Felül: NetLogo 6.4.0 implementáció. Alul: @fatint.
  ],
) <netlogo-species-comp-p-encounter>

$P_"mutation"$ magasabb értékeknél létrehozhat egy-egy rövid életű fajt, de
mivel ezen fajok gyakran egy egydből állnak, így az egyed halálával a faj is
kihal. Továbbra is egyetlen faj dominál. Lásd @netlogo-species-comp-p-mutation.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    netlogo_species_plot("/data/p_mutation-NetLogo.csv", [$P_"mutation"$]),
    image("/assets/paper_excerpts/P_mutation__0__0.5.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $P_"mutation"$ különböző értékei mellett.

    Felül: NetLogo 6.4.0 implementáció. Alul: @fatint.
  ]
) <netlogo-species-comp-p-mutation>

$P_"crossing"$ magas értékeknél hasonlóan viselkedik, mint a $P_"mutation"$
eset, lásd @netlogo-species-comp-p-crossing.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    netlogo_species_plot("/data/p_crossing-NetLogo.csv", [$P_"crossing"$]),
    image("/assets/paper_excerpts/P_crossing__0__0.5.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $P_"crossing"$ különböző értékei mellett.

    Felül: NetLogo 6.4.0 implementáció. Alul: @fatint.
  ],
) <netlogo-species-comp-p-crossing>

Ahogy a @model-desc fejezet is kifejtette, $P_"change"$ a FATINT modell egyik
legfontosabb paramétere. Ahogy a @netlogo-species-comp-p-change ábrán is
látható, bármilyen nem nulla érték mellett "tüskéket" okoz a faj számokban, mert
egyszerre hat az összes egyed párosodási preferenciáira. Minél magasabb
$P_"change"$, annál gyakoribbak a tüskék.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    netlogo_species_plot("/data/p_change-NetLogo.csv", [$P_"change"$], cap: 20),
    image("/assets/paper_excerpts/P_change__0.0005__0.001.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $P_"change"$ különböző értékei mellett.

    Felül: NetLogo 6.4.0 implementáció. Alul: @fatint.
  ],
) <netlogo-species-comp-p-change>

$P_"change" = 0.0005$-el garantálva az új gének hozzáadását, $M_"limit"$
különböző értékei arra hatással vannak a "tüskék" méretére. Minél magasabb,
annál több faj keletkezik a gének hozzáadásakor, ugyanakkor ezen fajok annál
kisebbek és rövidebb életűek. Lásd @netlogo-species-comp-m-limit.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    netlogo_species_plot("/data/m_limit-NetLogo.csv", [$M_"limit"$], cap: 30),
    image("/assets/paper_excerpts/M_limit__0__20.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $M_"limit"$ különböző értékei mellett.
    $P_"change" = 0.0005$.

    Felül: NetLogo 6.4.0 implementáció. Alul: @fatint.
  ],
) <netlogo-species-comp-m-limit>

Ha véletlenszerű gének helyett a @stretch-formula egyenletet használjuk, akkor
ahogy a @netlogo-species-comp-v-stretch ábrán is látható, a létrejövő fajok
száma gének hozzáadások hirtelen megugrik, majd lassabban csökken, mint amikor
véletlenszerűen adunk az egyedekhez új géneket.

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    netlogo_species_plot("/data/v_stretch-NetLogo.csv", [$V_"stretch"$], cap: 3),
    image("/assets/paper_excerpts/V_stretch__1__20.png"),
  ),
  caption: [
    Fajok számának átlagos alakulása $V_"stretch"$ különböző értékei mellett.
    $P_"change" = 0.0005$.

    Felül: NetLogo 6.4.0 implementáció. Alul: @fatint.
  ],
) <netlogo-species-comp-v-stretch>
