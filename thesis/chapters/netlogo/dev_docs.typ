#import "/lib/plot.typ": *
#import "../../lib/elteikthesis.typ": *
#import "@preview/lovelace:0.3.1": *

== Fejlesztői dokumentáció (NetLogo)

A fejlesztői dokumentáció részletezi a FATINT modell NetLogo implementációjának
működési követelményeit, a fejlesztése során meghozott döntéseket és tesztelés
menetét.

=== Specifikáció

A NetLogo implementáció feladata a FATINT (@model-desc) modell pontos
szimulációja, és a @fatint cikkben közölt eredmények replikációja.
A NetLogo ehhez egyszerű programozási nyelvével, felülettervező eszközeivel,
a processzor magok hatékony kihasználásával, és a BehaviorSpace nevű kísérletsor
szerkesztő és futtató eszközzel járul hozzá.

Felhasználói felületén könnyen módosíthatóak az egyes paraméterek és
gyorsan tesztelhetőek a módosítások modellre gyakorolt hatásai.

==== Funkcionális követelmények

Az implementáció:
- Lehetőséget nyújt a @model-params fejezetben szereplő összes paraméter
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

A felhasználó és a NetLogo implementáció közötti interakciókat az @netlogo-usecase
diagram foglalja össze.

#figure(
  image("/assets/diagrams/netlogo_usecase.svg"),
  caption: [
    A NetLogo implementáció és a BehaviorSpace releváns funkcióinak felhasználói
    eset diagramja
  ],
) <netlogo-usecase>

==== Felületi terv

A NetLogo program grafikus felülete futás közben szerkeszthető, így megfelelő
eszköz a modell felületi tervének elkészítésére is, lásd @netlogo-model-ui-plan.

#figure(
  image("../../assets/screenshots/netlogo_model_ui.png", width: 50%),
  caption: [ A NetLogo 6.4.0 fő ablaka benne a modell "felülettervével" ],
) <netlogo-model-ui-plan>

A modell állapotának grafikonjait egy csoportba, egymás gyűjti, így futás közben
átlátható a modell állapotának alakulása, és könnyen felfedezhetőek ok-okozati
összefüggések, például a fajok számának megugrása a génszám növekedésének pillanatában.

==== Felhasználói történetek

A felhasználó szimulációkat szeretne futtatni, hogy elemezhesse a FATINT modell
viselkedését. Az implementáció akkor működik megfelelően, ha a @netlogo-gwt
táblázatban szereplő interakciókra a táblázatban előírt módon reagál.

#figure(
  table(
    columns: 3,
    table.header[*#text("GIVEN", lang: "en") / Feltéve, hogy a felhasználó...*][*#text("WHEN", lang: "en") / Amikor...*][*#text("THEN", lang:"en") / Akkor...*],

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
  caption: [
    A NetLogo implementáció elvárt viselkedése az interakciók függvényében
  ],
) <netlogo-gwt>

=== Implementáció részletei

==== A NetLogo implementáció architektúrája

A FATINT modell implementációja a `model.nlogo` fájlban van.
A mélységi bejárásos fajszámláló algoritmus ki van szervezve a `depth-first-search.nls` fájlba.
A diszjunkt-halmazos fajszámláló pedig a `disjoint-sets.nls` fájlba.
A `model.nlogo` fájl megnyitásához az `nls` mellékfájloknak ugyanabban a mappában kell lenniük, mint az `nlogo` fájl.

A NetLogo programozási nyelv az *ágensek* koncepciója köré szervezve. Minden
ágens felfogható egy-egy objektumként, saját mezőkkel rendelkeznek és függvényeket, eljárásokat hajtanak végre. Ezen függvények és eljárások egy globális névtérben helyezkednek el, nem tartoznak szorosan az ágenshez vagy annak típusához.
A NetLogo nyelv procedurális, nincsenek osztályok vagy modulok. Néhány beépített
függvényt és eljárást csak egyes ágens típusok képesek futtatni, ezek használata
határozza meg, hogy a fejlesztő által írt függvényeket és eljárásokat mely ágensek
képesek futtatni.

A NetLogo különbséget teszt *függvények* (`to report foo`) és *eljárások* (`to bar`)
között. A függvényeknek visszatérési értékük van. Az eljárásoknak nincs, azok célja a modell paramétereinek vagy a szimuláció elemeinek állapotának módosítása. Ezt *mellékhatásnak* (_"effect"_) hívjuk. A függvényeknek is lehetnek mellékhatásaik.

Leszűrhetők az szimulációban részt vevő ágensek különböző *ágenshalmazai*,
és ezeken a halmazokon egyszerre futtathatóak eljárások, de függvények nem.
A NetLogo az ágenshalmaz elemein véletlenszerű sorrendben futtatja az eljárást,
garantálva az igazságosságot, amikor az ágensek egy közös forrásért versenyeznek
(mint például a környezet energiakészlete).

#definition(caption: "NetLogo programnyelvi koncepciók")[
/ Ágens:
  Egy, a NetLogo szimulációban részt vevő objektum.
/ Ágenshalmaz:
  A szimuláció összes ágensének halmaza, vagy egy logikai feltétellel leszűrt részhalmaza.
/ Függvény:
  Egy visszatérési értéket előállító procedúra.
/ Eljárás:
  Egy visszatérési érték nélküli procedúra, mely egy vagy több mellékhatást
  kiválthat. Ágenshalmazokon is meghívható, ekkor a halmaz minden eleme
  lefuttatja.
/ Mellékhatás:
  Egy függvény vagy eljárás futtatása miatt bekövetkező állapotváltozás.
] <netlogo-concepts>

A @netlogo-concepts összefoglalja a fent tárgyalt koncepciókat.

A NetLogo alapból a @netlogo-agent-types definícióban részletezett négy ágens típust definiálja:

#definition(caption: "NetLogo ágens típusok")[
/ #text("Turtle", lang: "en"), avagy teknős:
  A tradicionális Logo nyelvekből származó, fizikai térben
  létező, mozgó, rajzolni tudó ágensek. A NetLogo egy _"World"_, avagy _világ_
  nevű térben helyezi el a teknősöket, de ezt a tényt, illetve az a világot ábrázoló nézetet a FATINT nem használja.
  A FATINT modellben a teknősök alkotják a szimuláció populációját.
/ #text("Link", lang: "en"), avagy él:
  Nincs saját pozíciójuk, hanem két teknőst kötnek össze.
  A FATINT modellben a $G_P$ párosodási preferencia gráf éleit reprezentálják.
/ #text("Patch", lang: "en"), avagy folt:
  A fizikai tér egy szekciója. A FATINT modell nem használja.
/ #text("Observer", lang: "en"), avagy megfigyelő: Egyke objektum (singleton), nincs
  pozíciója vagy megjelenése, a szimuláció kezeléséért és az egyedek koordinálásáért felel.
] <netlogo-agent-types>

A fejlesztő definiálhat altípusokat (_"breed"_). Ez nem keverendő a FATINT
modell által definiált *faj* fogalmával. A FATINT NetLogo implementációja nem
használ típusokat.

A fejlesztő definiálhat globális változókat, valamint bármely típushoz rendelhet
további mezőket. Ezek mindig publikusak. A grafikus felületre felvett gombok
szintén globális változók. A FATINT modell implementáció globális változóként
tárolja:
/ `p-encounter`, `v-min`, `m-limit`, ...: a modell kezdő paraméterei
/ `m-init`: $M_"init"$, a szimuláció populációjának kezdő létszáma
/ `n-init`: $N_"init"$, az egyedek genotípusának kezdő hossza
/ `available-energy`: a környezet energiaszintje
/ `gene-count`: az egyedek genotípusának hossza
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

Nem definiáljuk külön a teknős korát, az `e-discounting` elég információt tartalmaz a
korfüggő számításokhoz.

A NetLogo modelleknél bevett konvenció egy `setup` és egy `go` eljárás definiálása.
/ `setup`: Eltakarítja a korábbi szimulációk állapotát és inicializál egy új
  kezdőállapotot.
/ `go`: Végrehajt egy szimulációs kört.

Ezen függvények a felhasználó által kattintható gombok formájában ki vannak
vezetve a felületre.

==== Az egyedek életciklusa

Új szimuláció kezdése előtt a felhasználó rákattint a _"Setup"_ gombra, inicializálva
a szimuláció állapotát. Utána kézzel (A _"Step"_ gombra kattintva) vagy automatikusan (A _"Go"_ gombra kattintva) futtatja a `go` eljárást.

A `setup` eljárás alaphelyzetbe állítja a szimulációt a megadott paraméterekkel
(@netlogo-setup-listing).
A `go` eljárás (@netlogo-go-listing) egy szimulációs kört futtat le,
melynek részét képezi a környezet karbantartása,
az egyedek táplálkozása (@netlogo-eat-or-die-listing),
az egyedek párzása (@netlogo-reproduce-listing),
és a fajok megszámolása (lásd @netlogo-counting-species)

#pseudocode-listing(caption: [A `setup` eljárás lépései])[
  + *eljárás* `setup`:
    + Minden teknős és éleik törlése
    + NetLogo lépésszámláló nullázása (`reset-ticks`)
    + $"M-limit-sqr" := M_"limit" ^ 2$
    + $"available-energy" := 0$
    + $"gene-count" := N_"init"$
    + $M_"init"$ számú új teknős létrehozása
    + *ciklus* $forall a in "teknősök"$:
      + $"a.energy" := 0$
      + $"a.e-discounting" := E_"discount"^"a.kor" = E_"discount"^0 = 1$
      + $"a.genotype" := N_"init"$ darab $[V_"min", V_"max"]$ tartományba eső véletlen gén
      + *ciklus* $forall "b" in { b in "teknősök" | $`euclidean_distance_sqr(a,b)` $<= M_"limit"^2}$
        + közös irányítatlan él létrehozása a $a$ és $b$ között
      + *ciklus vége*
    + *ciklus vége*
  + *eljárás vége*
] <netlogo-setup-listing>

#pseudocode-listing(caption: [A `go` eljárás lépései])[
  + *eljárás* `go`:
    + $"available-energy" := "available-energy" + E_"increase"$
    + `eat-or-die`
    + `reproduce`
    + Ha nem maradt élő egyed, szimuláció megszakítása
    + `count-species`
    + NetLogo lépésszámláló inkrementálása (`tick`)
  + *eljárás vége*
] <netlogo-go-listing>

#pseudocode-listing(caption: [Az `eat-or-die` segédeljárás lépései])[
  + *eljárás* `eat-or-die`:
    + *ciklus* $forall t in "teknősök"$ véletlen sorrendben:
      + $E_"in" := min(E_"intake", "available-energy")$
      + $"available-energy" := "available-energy" - E_"in"$
      + $"t.energy" := "t.energy" + E_"in" dot "t.e-discounting" - E_"consumption"$
      + $"t.e-discounting" := "t.e-discounting" dot E_"discount"$
      + *ha* $"t.energy" <= 0$:
        + $t$ eltávolítása
      + *elágazás vége*
    + *ciklus vége*
  + *eljárás vége*
] <netlogo-eat-or-die-listing>

#pseudocode-listing(caption: [Az `reproduce` segédeljárás lépései])[
  + *eljárás* `reproduce`:
    + *ciklus* $forall a in {t in "teknősök" | P_"encounter" "valószínűség teljesül" }$:
      + Ha $a$ teknősnek nincs éle, ezt az iterációt kihagyjuk
      + Véletlenszerűen kiválasztjuk $a$ egyik $l$ élét, melyek másik vége $b$
      + $D := $`euclidean_distance_sqr(`$a$, $b$`)`
      + $o := M_"const" + (M_"limit" - sqrt(D)) * M_"slope"$
      + *ismétlés* $o$ alkalommal:
        + Új teknős $u$ létrehozása
        + $"u.energy" := 0$
        + $"u.e-discounting" := 1$
        + $"u.genotype" := $` combine(`$a$,$b$`)`
        + *ha* ${g in "u.genotype" | g in.not [V_"min", V_"max"]} != emptyset$
          + $u$ eltávolítása
        + *elágazás vége*
      + *ismétlés vége*
    + *ciklus vége*
  + *eljárás vége*
] <netlogo-reproduce-listing>

#pseudocode-listing(caption: [A `combine` függvény lépései])[
  + *függvény* `combine(a,b)`:
    + $c := "gene-count hosszú tömb"$
    + *ciklus* $i in [0.."gene-count") inter NN$
      + *ha* $P_"crossing"$ valószínűség teljesül:
        + $c[i] := b[i]$
      + *különben*:
        + $c[i] := a[i]$
      + *elágazás vége*
      + *ha* $P_"mutation"$ valószínűség teljesül:
        + $m := $ véletlenszám $[-V_"mutation", V_"mutation"] inter ZZ$ halmazból
        + $c[i] := c[i] + m$
      + *elágazás vége*
    + *ciklus vége*
    + *visszatérés* $c$ tömbbel
  + *függvény vége*
] <netlogo-combine-listing>

/*
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
  @netlogo-counting-species.
+ A szimulációban eltelt körök számát (*`tick`*) megnöveli eggyel.
*/

==== A fajok megszámlálása <netlogo-counting-species>

A fajok megszámlálására két algoritmust kínál az implementáció:
/ `dft-count-species`: Mélységi bejárással számolja meg a fajokat, lásd @netlogo-dft-listing.
/ `ds-count-species`: Diszjunkt-Halmaz algoritmussal számolja meg a fajokat, lásd @netlogo-ds-listing.

Az implementációk között a `use-ds` kapcsolóval / globális változóval lehet
váltani.

#pseudocode-listing(caption: [A mélységi bejárásos fajszámláló algoritmus])[
  + *eljárás* `dft-count-species`:
    + $"species-count" := 0$
    + ${ "t.visited" = "hamis" forall t in "teknősök" }$
    + *ciklus* Amíg $exists t in {t in "teknősök" | "t.visited" = "hamis"}$
      + $"species-count" := "species-count" + 1$
      + `dft-traverse(t)`
    + *ciklus vége*
  + *eljárás vége*
  + *eljárás* `dft-traverse(a)`:
    + $"t.visited" = "igaz"$
    + *ciklus* $a$ minden $l$ élének minden $b$ csúcsa ahol $"b.visited" = "hamis"$:
      + `dft-traverse(b)`
    + *ciklus vége*
  + *eljárás vége*
] <netlogo-dft-listing>

#pseudocode-listing(caption: [A diszjunkt-halmaz alapú fajszámláló algoritmus])[
  + *eljárás* `ds-count-species`:
    + $"species-count" := |"teknősök"|$
    + *ciklus* $forall t in "teknősök"$
      + $"t.parent" := t$ _Azaz $t$ gyökérelem_
      + $"t.rank" := t$ _Rang alapú fa magasság optimalizálás_
    + *ciklus vége*
    + *ciklus* $forall l in "élek"$
      + $a,b := l$ csúcsai
      + $R_a := $ `ds-find-root(a)`
      + $R_b := $ `ds-find-root(b)`
      + *ha* $R_a != R_b$ _azaz eddig két külön fába tartoztak_
        + $"species-count" := "species-count" - 1$
        + *ha* $R_a".rank" = R_b".rank"$:
          + $R_a".rank" := R_a".rank" + 1$
        + *elágazás vége*
        + *ha* $R_a".rank" > R_b".rank"$:
          + $R_b".parent" := R_a$ _$R_b$ fájának beolvasztása $R_a$ fájába_
        + *különben*:
          + $R_a".parent" := R_b$ _$R_a$ fájának beolvasztása $R_b$ fájába_
        + *elágazás vége*
      + *elágazás vége*
    + *ciklus vége*
  + *eljárás vége*
  + *függvény* `ds-find-root(a)`: _Gyökérelem megkeresése_
    + *ciklus* amíg $a".parent" != a$:
      + $a".parent" := a".parent.parent"$ _Útfelezési optimalizálás_
      + $a := a".parent"$
    + *ciklus vége*
    + *visszatérés* $a$ gyökérelemmel
  + *függvény vége*
] <netlogo-ds-listing>

/*
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
*/

=== Tesztelés

Az implementáció két módon tesztelhető: a felületen kézzel bevitt adatokra
adott reakciók elemzésével, illetve a kísérletsorok által generált eredmények
vizsgálatával.

==== Kézi tesztelés

Kézi tesztekre mutatnak példát a @netlogo-test-dying, @netlogo-test-defaults és @netlogo-test-speciation lépései.

#list(caption: "Készi teszt lépései populáció kipusztulásának teszteléséhez")[
+ Kattintsunk a *Reset* gombra, hogy minden paraméter alapértelmezett értéket
  vegyen fel.
+ Állítsuk $P_"encounter"$ értékét $0$-ra, minden mást hagyjunk alapértelmezett
  értéken.
+ Kattintsunk a *Setup*, majd a *500 steps* gombra.
+ A populáció létszáma 30 kör alatt nullára kell essen. A szimulációnak 30 körön
  belül terminálnia kell.
] <netlogo-test-dying>

#list(caption: "Készi teszt lépései alapértelmezett működés teszteléséhez")[
+ Kattintsunk a *Reset* gombra, hogy minden paraméter alapértelmezett értéket
  vegyen fel.
+ Kattintsunk a *Setup*, majd a *500 steps* gombra.
+ A populáció létszáma először megugrik, majd stabilizálódik a $[100, 120]$
  intervallumon belül. A fajok száma a szimuláció végére $1$. Lásd
  @netlogo-test-default-settings.
] <netlogo-test-defaults>

#list(caption: "Készi teszt lépései új gének automatikus létrehozásának teszteléséhez")[
+ Kattintsunk a *Reset* gombra, hogy minden paraméter alapértelmezett értéket
  vegyen fel.
+ Állítsuk $P_"change"$ értékét egy pozitív, egynél kisebb értékre, például $0.0005$.
+ Kattintsunk a *Setup*, majd a *500 steps* gombra.
+ A populáció létszáma először megugrik, majd stabilizálódik a $[100, 120]$
  intervallumon belül. A gének száma a szimuláció végére magasabb, mint $5$.
  A fajszámláló grafikonon előfordulhatnak kisebb tüskék. Lásd
  @netlogo-test-p-change.
] <netlogo-test-speciation>

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

==== A @fatint cikk grafikonjai, mint integrációs tesztek

A modellbe előre beépített kísérletsorok segítségével meggyőződhetünk róla,
hogy a NetLogo implementáció az elvárt módon viselkedik. Ezen kísérletek grafikus
felület nélkül is futtathatóak a NetLogo gyökérmappájában található
`NetLogo_Console` eszköz segítségével:

#command(caption: [A `NetLogo_Console` eszköz])[
```bash
NetLogo$ ./NetLogo_Console --headless --model model.nlogo --experiment experiment-name --table output.csv --stats stats.csv
```
] <netlogo-console>

A @netlogo-console paraméterei a következők:

/ `--headless`: Ez a kapcsoló megakadályozza a felhasználói felület betöltését
/ `--model`: Ennek a kapcsolónak kell megadni a modell fájl elérési útvonalát
/ `--experiment`: A futtatni kívánt BehaviorSpace kísérlet neve
/ `--table`: A szimuláció eredményének mentési útvonala
/ `--stats`: A statisztikák mentési útvonala

A @fatint cikkben szereplő kísérletek a @netlogo-experiment-table táblázatban
szereplő nevekkel lettek definiálva:

#figure(
  [
    #show table.cell.where(x: 0): it => align(left)[#it]
    #table(
      columns: 5,
      table.header[Név][Kulcs paraméter][Kezdő érték][Lépésméret][Végső érték],
      [`default-settings`], [Lásd @model-defaults], [], [], [],
      [`sweep-p-encounter`], [$P_"encounter"$], [$0.05$], [$0.005$], [$0.095$],
      [`sweep-p-mutation`], [$P_"mutation"$], [$0$], [$0.1$], [$0.5$],
      [`sweep-p-crossing`], [$P_"crossing"$], [$0$], [$0.1$], [$0.5$],
      [`sweep-p-change`], [$P_"change"$], [$0.0005$], [$0.00005$], [$0.001$],
      [`sweep-m-limit`], [$M_"limit"$,

      $P_"change" = 0.0005$], [$0$], [$1$], [$20$],
      [`sweep-v-stretch`], [$V_"stretch"$,

      $P_"change" = 0.0005$], [$1$], [$1$], [$20$],
    )
  ],
  caption: [A @fatint cikkben szereplő kísérletsorok NetLogo megfelelői]
) <netlogo-experiment-table>

A fenti kísérleten túl a modell tartalmaz néhány teljesítmény felmérést:

/ `benchmark-species-counter-dfs-one-species`:
  Mélységi bejárás futásideje egy fajba tartózó egyedekkel, ${2^4, 2^5, ..., 2^12}$ méretű populációval
/ `benchmark-species-counter-dfs-many-species`:
  Mélységi bejárás futásideje különböző egyelemű fajokba tartózó egyedekkel, ${2^4, 2^5, ..., 2^12}$ méretű populációval
/ `benchmark-species-counter-ds-one-species`:
  Diszjunkt-halmaz futásideje egy fajba tartózó egyedekkel, ${2^4, 2^5, ..., 2^12}$ méretű populációval
/ `benchmark-species-counter-ds-many-species`:
  Diszjunkt-halmaz futásideje különböző egyelemű fajokba tartózó egyedekkel, ${2^4, 2^5, ..., 2^12}$ méretű populációval
/ `benchmark-simulator-no-churn`:
  Szimuláció időigénye ${2^4, 2^5, ..., 2^12}$ darab steril, hallhatatlan egyedből álló populációval
/ `benchmark-simulator-churn`:
  Szimuláció időigénye $E_"intake" in {2^4, 2^5, ..., 2^12}$ esetekben, azaz ahol a környezet egyre több egyedet képes eltartani

#figure(
  grid(
    columns: 1,
    gutter: 12pt,
    netlogo_species_plot("/data/default-NetLogo.csv", none),
    image("/assets/paper_excerpts/default_params.png", height: 30%),
  ),
  caption: [
    Fajok számának átlagos alakulása alapértelmezett beállítások mellett.

    Felül: NetLogo 6.4.0 implementáció. Alul: @fatint.
  ],
) <netlogo-species-comp-default>

Alapértelmezett paraméterek mellett a fajok átlagos száma nem esik 0-ra,
egy faj stabilan fennmarad. Lásd @netlogo-species-comp-default.

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

$P_"encounter"$ alacsony értékeknél biztos kipusztulást, és magasabb értékeknél
is legfeljebb egy faj fennmaradását garantálja. A NetLogo grafikonon a keretrendszer
nem generál üres sorokat a populáció kipusztulása után, tehát a grafikonon nem esik
a fajok száma nullára. Helyette az idő előtt terminált szimulációhoz tartozó
pontok nem érnek el a grafikon végéig, hanem félbeszakadnak. Lásd
@netlogo-species-comp-p-encounter.

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

$P_"mutation"$ magasabb értékeknél létrehozhat egy-egy rövid életű fajt, de
mivel ezen fajok gyakran egy egyedből állnak, így az egyed halálával a faj is
kihal. Továbbra is egyetlen faj dominál. Lásd @netlogo-species-comp-p-mutation.

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

$P_"crossing"$ magas értékeknél hasonlóan viselkedik, mint a $P_"mutation"$
eset, lásd @netlogo-species-comp-p-crossing.

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

Ahogy a @model-desc fejezet is kifejtette, $P_"change"$ a FATINT modell egyik
legfontosabb paramétere. Ahogy az @netlogo-species-comp-p-change ábrán is
látható, bármilyen nem nulla érték mellett "tüskéket" okoz a faj számokban, mert
egyszerre hat az összes egyed párosodási preferenciáira. Minél magasabb
$P_"change"$, annál gyakoribbak a tüskék.

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

$P_"change" = 0.0005$-el garantálva az új gének hozzáadását, $M_"limit"$
különböző értékei arra hatással vannak a "tüskék" méretére. Minél magasabb,
annál több faj keletkezik a gének hozzáadásakor, ugyanakkor ezen fajok annál
kisebbek és rövidebb életűek. Lásd @netlogo-species-comp-m-limit.

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

Ha véletlenszerű gének helyett a @stretch-formula egyenletet használjuk, akkor
ahogy az @netlogo-species-comp-v-stretch ábrán is látható, a létrejövő fajok
száma gének hozzáadásakor hirtelen megugrik, majd néhány körön belül csökken.

==== Teljesítmény

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
    Az élek létrehozásának és a fajszámláló algoritmusok futásidejének összege a
    populáció létszámának függvényében (logaritmikus skála).
  ],
) <netlogo-species-counter-perf>

A @netlogo-species-counter-perf diagram alapján elmondható, hogy a fajok száma
sokkal nagyobb hatással van az fajszámlálás időigényére, mint a választott
algoritmus. Sok faj esetén a különbség elhanyagolható. Kevés faj esetén a
mélységi bejárás kicsit gyorsabb.

/*
#figure(
  perf_plot(
    [Egyedek száma],
    (
      (
        path: "/data/benchmark-simulator-nochurn-NetLogo.csv",
        label: [NetLogo 6.4.0],
        skip: 7,
        x: 0,
        y: 2,
      ),
    ),
  ),
  caption: [Egy 1000 lépéses szimuláció időigénye steril, hallhatatlan egyedek számának függvényében (logaritmikus skála)],
) <netlogo-simulation-nochurn-perf>
*/

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
  caption: [Egy 1000 lépéses szimuláció időigénye a környezet eltartóképességének függvényében (logaritmikus skála)],
) <netlogo-simulation-perf>

A @netlogo-simulation-perf grafikonokon látható, hogy a szimulációt jelentősen lassítja a régi egyedek és éleik törlése, az új egyedek inicializálása és azok éleinek felépítése.
