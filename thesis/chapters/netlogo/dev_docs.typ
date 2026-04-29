#import "/lib/elteikthesis.typ": todo
#import "/lib/plot.typ": *

== Fejlesztői dokumentáció (NetLogo)

A fejlesztői dokumentáció részletezi a FATINT modell NetLogo implementációjának
működési követelményeit, az implementációban meghozott döntéseket és tesztelés
menetét.

=== Specifikáció

A NetLogo implementáció feladata a FATINT (@model-desc) modell pontos
szimulációja, és a @fatint cikkben közölt adatok replikációja. A NetLogo ehhez
egyszerű programozási nyelvével, felülettervező eszközeivel, a processzor magok
hatékony kihasználásával, és a BehaviorSpace nevű kísérletsor szerkesző és
futtató eszközzel járul hozzá.

==== Funkcionális követelmények

Az implementáció:
- Lehetőséget nyújt a @model-params fejeztben szereplő összes paraméter
  beállítására.
- Ellenőrzi a felhasználó által megadott paramétereket és jelenti a hibákat.
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
- A szimuláció nem fut hibára, feltéve, hogy a felhasználó által megadott
  kiinduló paraméterek a @model-defaults táblában szereplő tartományokba esnek.
- A felület reszponzív marad a szimuláció állapotától függetlenül.
- Az implementáció igyekszik takarékoskodni a memóriával és a számítási
  kapacitással.
- Egy 200 szimulációból, szimulációnként legfeljebb 6000 lépésből álló
  kísérletsort 5 percen belül lefuttat egy munkaállomás kategóriás számítógépen.
- Minden kísérlet terminál.

==== Felhasználói esetek

#figure(
  image("/assets/diagrams/netlogo_usecase.svg"),
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
    [Érvénytelen paramétereket állított be], [Rákattint a _"Setup"_ gombra], [A hibás paraméterekről hibaüzenetet kap],
    [Érvénytelen paramétereket állított be], [Rákattint a _"Step"_ vagy _"500 steps"_ gombra], [A hibás paraméterekről hibaüzenetet kap],
    [Érvénytelen paramétereket állított be], [Rákattint a _"Go"_ gombra], [A hibás paraméterekről hibaüzenetet kap],

    [Elindított egy szimulációt], [A populáció mérete nullára csökken], [A szimuláció leáll],

    [Elindított egy szimulációt], [Megszakítja a szimulációt], [A szimuláció leáll],

    [Legalább egy paramétert módosított],
    [Rákattint a _"Reset"_ gombra],
    [Minden paraméter visszaáll alapértelmezett értékre],

    [Elindított korábban kézzel egy szimulációt],
    [Megnyomja a _"Setup"_ gombot],
    [A korábbi szimuláció állapota törlődik, és egy új kezdő populáció jön létre],

    [Elindított kézzel egy szimulációt, a populáció nem üres, `use-v-stretch-formula` kapcsoló KI állásban van],
    [Megnyomja a `+` gombot],
    [Minden egyed genotípusa bővül egy-egy véletlen új génnel],

    [Elindított kézzel egy szimulációt, a populáció nem üres, `use-v-stretch-formula` kapcsoló BE állásban van],
    [Megnyomja a `+` gombot],
    [Minden egyed genotípusa bővül egy-egy új génnel a @stretch-formula egyenletnek megfelelően],

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

==== A NetLogo architekturája

A NetLogo programozási nyelv az *ágensek* koncepciója köré szervezve. Minden
ágens felfogható egy-egy objektumként, mezői vannak és függvényeket, eljárásokat
hajt végre. Ezen eljárások egy globális névtérben helyezkednek el, nem tartoznak
osztályhoz vagy modulhoz. A NetLogo különbséget teszt *függvények*
(`to report foo`) és *eljárás* (`to bar`) között. A függvényeknek mindig van
visszatérési értékük. Az eljárásoknak nincs, ők *mellékhatásokat* (_"effect"_)
váltanak ki, azaz módosítják egy vagy több ágens állapotát. A függvényeknek is
lehetnek mellékhatásaik. Nincs szoros összerendelés a függvények/eljárások és az
ágensek között. Néhány beépített függvényt és eljárást csak egyes ágens típusok
képesek futtatni, ezek használata határozza meg, hogy a fejlesztő által írt
függényeket és eljárásokat mely típusok képesek futtatni. Lekérhetők az ágensek
különböző *ágenshalmazai*, és ezeken egyszerre futtathatóak eljárások
(függvények nem). A NetLogo az ágenshalmaz tagjain véletlenszerű sorrendben
futtatja a eljárást, garantálva az igazságosságot, ha az ágensek egy közös
forrásért versenyeznek (mint például a környzet energiakészlete).

A NetLogo alapból négy ágens típust definiál:

/ Turtle, avagy teknős: A tradícionális Logo nyelvekből származó, fizikai térben
  létező, mozgó, rajzolni tudó ágensek. A NetLogo egy _"World"_, avagy _világ_
  nevű térben helyezi el őket, de ezt a nézetet a FATINT nem használja.
  A FATINT modellben a teknősök alkotják a szimuláció populációját.
/ Link, avagy él: Nincs saját pozíciójuk, hanem két teknőst kötnek össze.
  A FATINT modellben a $G_P$ párosodási preferencia gráf éleit reprezentálják.
/ Patch: A környzet fizikai terei, a FATINT modell nem használja.
/ Observer: Egyke objektum (singleton), nincs pozíciója vagy megjelenése, a
  szimuláció kezeléséért és az egyedek koordinálásáért felel.

A fejlesztő definiálhat altípusokat (_"breed"_). Ez nem keverendő a FATINT
modell által definiált *faj* fogalmával. A FATINT NetLogo implementációja nem
használ típusokat.

A fejlesztő definiálhat globális változóket, valamint bármely típushoz rendelhet
további mezőket. Ezek mindig publikusak. A grafikus felületre felvett gombok
szintén globális válzotók. A FATINT modell implmenetáció globális változóként
tárolja:
/ `p-encounter`, `v-min`, `m-limit`, stb: a modell kezdő paraméterei
/ `starting-pop`: a szimuláció populációjának kezdő létszáma
/ `starting-allele-count`: az egyedek genotípusának kezdő hossza
/ `available-energy`: a környezet energiaszintje
/ `allele-count`: az egyedek genotípusának hossza
/ `species-count`: a fajok száma

Optimalizációs céllal definiálja továbbá az *`M-limit-sqr`*-t, azaz a
$M_"limit"^2$ értékét, mint külön változót, csökkentve ezzel a költséges
négyzetgyök számítások számát.

Az egyes teknősökön a következő mezőket definiálja:
/ `phenotype`: Az egyed genotípusa
/ `accumulated-energy`: Az egyed aktuális energiaszintje

Továbbá definiálja rajtuk a következő segédmezőket:
/ `e-discounting`: A @stretch-formula egyenlet $E_"discount"^"age"$ része.
  Minden kör végén felszorozzuk $E_"dicount"$-tal, ezzel megspórolva a költséges
  hatványra emeléseket.
/ `visited`: A mélységi bejárás segédváltozója.
/ `parent` és `rank`: A Diszjunkt-Halmaz algoritmus segédváltozói.

A NetLogoban konvenció egy `setup` és egy `go` eljárás definiálása.
/ `setup`: Eltakarítja a korábbi szimulációk állapotát és inicializál egy új
  kezdőállapotot.
/ `go`: Végrehajt egy szimulációs kört.

Ezen függvények a felhasználó által kattintható gombok formájában ki vannak
vezetve a felületre.

==== Az egyedek életciklusa

A szimuláció megkezése előtt a felhasználó rákattinint a _"Setup"_ gombra. Majd
kézzel (A _"Step"_ gombra kattintva) vagy automatikusan (A _"Go"_ gombra
kattintva) futtatja a `go` eljárást.

A FATINT modellben a `setup` eljárás:
+ Kitöröl minden élt és teknőst
+ Nullázza az eltelt körök számát (*`tick`*)
+ Beállítja `M-limit-sqr`-t
+ Létehoz `starting-pop` számú új teknőst:
  - A teknős a korát és energiaszinjét nullára állítja
  - Az `e-discounting` segédváltozót $E_"dicount"^"age" = E_"discount"^0 = 1$-re állítja
  - Genotípusnak létrehoz egy `strating-allele-count` elemű vektort,
    $[V_"min", V_"max"]$ alléltartományba eső véletlen génekkel.
  - A teknős létrehoz egy-egy közös, irányítatlan élt minden olyan teknőssel,
    mellyel még nincs éle, de genotípusuk euklédeszi távolsága nem nagyobb, mint
    $M_"limit"$

A `go` eljárás lefuttat egy szimulációs kört, mely négy lépésből áll:
+ Környezet energiaszintjét megnöveli $E_"increase"$-szel
+ Utána az `eat-or-die` procedúrával a minden teknőst tartalmazó `turtles`
  ágenshalmaz minden tagján futtatja az alábbi lépéseket:
  - A teknős legfeljebb $E_"intake"$ energia elvesz a környezettől, vagy a
    környezet összes energiáját, ha az kevesebb, mint $E_"intake"$.
    A felvett mennyiséggel csökkenti a környezet energiakészletét.
  - A teknős energiaszintje @energy-gain-formula egyenletnek megfelelően módosul.
  - Ha a teknős energiája már nem pozitív, meghal és eltávolításra kerül éleivel
    együtt.
  - Ha a teknős életben maradt, `e-discounting` mezőjét felszorozza
    $E_"discount"$ értékével.
+ Utána a `reproduce` procedúrával a minden teknőst tartalmazó `turtles`
  ágenshalmazt leszűri egy $P_"encounter"$ valószínűségű feltétellel.
  A halmazban maradt tagokon futtatja az alábbi lépéseket:
  - Ha nincs a teknősnek éle a tenős nem csinál semmit.
  - Ha van legalább egy éle, véletlenszerűen kiválaszt egyet.
  - A kiválasztott él lekéri a két csúcsának genotípusát, kiszámolja azok
    euklédeszi távolságát, majd a @offspring-count-formula egyenletnek megfelelő
    gyermekszámot.
  - Az él a megkéri a teknőst, hogy hozzon létre a kiszámolt gyermekszámnak
    megfelelő mennyiségű egyedet.
  - Mindegyik létrehozott egyed:
    - Nullázza korát, energiaszintjét, és $1$-re állítja az `e-discounting`
      segédváltozót.
    - Felépíti genotípusát: Génenként $P_"crossing"$ valószínűséggel az egyeik
      szülő génjét választja az másik szülő génje helyett.
    - Utána génenként $P_"mutation"$ valószínűséggel módosítja azt egy
      $[-V_"mutation", V_"mutation"]$ intervallumba eső véletlen egész
      számmal.
    - Ha a genotípusban szerepel olyan gén, mely nem esik a $[V_"min", V_"max"]$
      allél tartományba, a teknős meghal.
    - Ha életben maradt, létrehoz egy-egy közös, irányítatlan élt minden
      olyan teknőssel, mellyel genotípuk euklédeszi távolsága nem nagyobb, mint
      $M_"limit"$
+ A `count-species` procedúrával megszámolja a fajokat. Lásd
  @fatint-counting-species.
+ A szimulációban eltelt körök számát (*`tick`*) megnöveli eggyel.

==== A fajok megszámlálása <fatint-counting-species>

A fajok megszámlálására két algoritmust kínál az implementáció:
/ `dft-count-species`: Mélységi bejárással számolja meg a fajokat.
/ `ds-count-species`: Diszjunkt-Halmaz algoritmussal számolja meg a fajokat.

Az implementációk között a `use-ds` kapcsoló / globális változóval lehet
váltani.

A mélységi bejárás algorimus működése:
+ Nullázzuk a fajok számát
+ Töröljük minden teknősből a `visited` flag-et. (Hamisra állítjuk)
+ Amíg van olyan teknős mely nincs megjelölve `visited` flag-gel:
  - Megnöveljük a fajok számát eggyel
  - Kiválasztunk egy `visited` flag nélküli teknőst
  - A kiválasott teknőson beállítjuk a `visited` flag-et
  - A kiválaszott tenkős összes élének minden csúcsára, és azok élei mentén
    rekurzívan beállítjuk a `visited` flaget.

A Diszjunk-Halmaz algoritmus működése:
+ A fajok számát beállítjuk az aktuális egyed számra
+ Minden teknős `parent` változóját (szülő hivatkozás) beállítjuk a saját
  magára (ezzel gyökérelemként megjelölve őket), valamint a `rank` (rang)
  változóját beállítjuk $1$-re. Ezzel a diszjunk-halmaz fában minden teknős egy
  külön fa / halmaz.
+ Az összes élen egybeolvasztjuk a két csúcs halmazát:
  - Megkeressük mindkét él szülő változói mentén a gyökér egyedet. A keresés
    közben a közbenső egyedek szülőjét beállíthatjuk a szölő szölőjére,
    csökkentve a fa magasságát. Ezt az optimalizációt hívják úgy, hogy
    *Path halving* (_"Útvonal felezés"_)
  - Ha a két gyökér egyezik, nem csinálunk semmit, ez az él it végzett.
  - Ha a két gyökér eltér, de rangjuk egyezik, az egyik gyökér rangját növeljük
    eggyel. A rangok bevezetése is és egy optimalizáció, mely szintén csökkenti
    a fák magasságát azáltal, hogy az alacsonyabb fát olvasztja a magasabbikba.
  - Ha a két gyökér eltér, és rangjuk is (már) eltér, akkor a kisebb rangú
    gyökér a másik gyökeret beállítja szülő elemének. Ez az egyed többé nem
    gyökér, az altala feszített fa beolvad a másik gyökér fájába.
  - A halmazok száma eggyel csökkent, tehát a fajok számát eggyel csökkentjük.

#figure(
  perf_plot(
    [Populáció],
    (
      (
        path: "/data/benchmark-species-counter-dfs-one-species-NetLogo.csv",
        label: [Mélységi bejárás, egy faj],
        skip: 7,
        x: 0,
        y: 2,
      ),
      (
        path: "/data/benchmark-species-counter-dfs-many-species-NetLogo.csv",
        label: [Mélységi bejárás, sok faj],
        skip: 7,
        x: 0,
        y: 2,
      ),
      (
        path: "/data/benchmark-species-counter-ds-one-species-NetLogo.csv",
        label: [Diszjunkt-Halmaz, egy faj],
        skip: 7,
        x: 0,
        y: 2,
      ),
      (
        path: "/data/benchmark-species-counter-ds-many-species-NetLogo.csv",
        label: [Diszjunkt-Halmaz, sok faj],
        skip: 7,
        x: 0,
        y: 2,
      ),
    ),
  ),
  caption: [
    Az élek létrehozásának és a fajszámláló algorimusok futásidejének összege a
    populáció létszámának függvényében (logaritmikus skála).
  ],
) <netlogo-species-counter-perf>

A @netlogo-species-counter-perf diagram alapján elmondható, hogy a fajok száma
sokkal nagyobb hatással van az időigényre, mint a választott algoritmus.
Sok faj esetén a különbség elhanyagolható. Kevés faj esetén a mélységi bejárás
kicsit gyorsabb.

==== Teljesítmény

#figure(
  perf_plot(
    [$E_"increase"$],
    (
      (
        path: "/data/benchmark-simulator-churn-NetLogo.csv",
        label: [NetLogo 6.4.0],
        skip: 7,
        x: 0,
        y: 2,
      ),
    ),
  ),
  caption: [Egy 1000 lépéses szimuláció időigénye a környezet eltartóképességének függvényében],
) <netlogo-simulation-perf>

A @netlogo-simulation-perf diagram azt a látszatot kelti, mintha az egyedszám
növekedése egy bizonyos pont után nem befolyásolná a futásidőt. Ezt vizsgálni kell.

#todo[This result seems anomalous, investigate]

=== Tesztelés

Az implementáció két módon tesztelhető: a felületen kézzel bevitt adatokra adott
reakció elemzésével, illetve a kísérletsorok által

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

#todo("Eliminate wasteful whitespace")

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
  ],
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
