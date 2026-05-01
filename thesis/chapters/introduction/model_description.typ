#import "/lib/elteikthesis.typ": definition, todo

== A modell leírása <model-desc>

#definition[
  *Nyitott evolúciónak* hívjuk azon szimulációs rendszereket, melyek
  folyamatosan új komplexitást alkotnak, nem rekednek meg egy adott állapotban.
  Fontos megjegyezni, hogy ezek nem optimalizációs algoritmusok, nincs "céljuk"
  vagy minimalizálandó "költségfüggvényük".
]

A *FATINT* modell (melynek neve a #text("Fat Interactions", lang: "en"), magyarul _kövér interakciók_
rövidítése) egy olyan egyed szimulációs modell, melynek célja a nyitott evolúció
demonstrálása egy stabil, de folyamatosan változó "ökoszisztéma" fenntartásával.
Ezt arra a megfigyelésre alapozza, hogy való életben az élőlények génjeinek
működésére hatást gyakorol a környezetük és az élőlények egymással való
viselkedése.

A cikk egy lehetséges példaként a zsiráfok nyakát hozza fel, mely akkor vált
egy fontos, meghatározó tulajdonsággá, amikor az egymással összecsapó hímek a
nyakuk hosszának függvényében tudtak sikeresen párt találni.

A FATINT modellben semleges nemű egyedeket szimulálunk. Ezek az egyedek energiát
vesznek fel egy közös környezetből, párosodnak, és végül meghalnak, ha a
környezet nem tud minden elő egyedet eltartani, vagy ha az egyed a kora
előrehaladtával már nem képes megfelelően hasznosítani a felvett energiát.

#definition[
  / Genotípus: Az egyed génállománya. A FATINT modellben egész számok vektora.
  / Fenotípus: Az egyed genotípusa által kifejezett tulajdonságok összessége.
  / Gén: Az egyed genotípusának egy eleme.
  / Allél: Egy gén egy lehetséges értéke.
]

Minden egyednek van egy úgynevezett *genotípusa*, mely meghatározza, hogy mely további egyedekkel tud párosodni. Ezen párosodási "preferenciák" mentén az egyedek külön halmazokba sorolhatók, ahol az egyes egyedek a halmazukon kívül eső egyedekkel
nem tudnak párosodni.

#definition[
  Egy *faj* felfogható azon *$G_P$* irányítatlan "preferenciagráf" összefüggő
  komponensének, melynek csúcsai az életben lévő egyedek, az élei pedig a
  párosodni képes párok.
]

A modell célja, hogy az idő előrehaladtával újabb és újabb fajokat alkosson,
ezzel demonstrálva a nyitott evolúciót.

A FATINT modell legfontosabb sajátossága, hogy a párosodási preferenciákon túl
a környezet is hatással van az egyedek fenotípusára. Ugyanis előre meghatározott
módon a szimuláció során az egyedekben újabb és újabb géneket "aktiválhatunk"
(valójában hozzáadunk), ezzel befolyásolva azok párosodási preferenciáját, mely
új fajok létrejöttéhez vezethet.

Új fajok több módon is létrejöhetnek:
- Egy egyed halálával annak faja két vagy több új fajjá eshet szét, ha a $G_P$
  preferenciagráfban az egyednek egy vagy több híd éle volt.
- Párosodás során két szülő egyed létrehoz egy vagy több gyermek egyedet. Ezen
  egyedek mindkét szülőtől örökölnek géneket, valamint mutálódhatnak is.
  Előfordulhat, hogy az új egyedek már képesek más fajok egyedeivel párosodni,
  egyesítve két vagy több fajt egy új fajjá. Az is előfordulhat, hogy nem
  képesek párosodni senkivel, önmagukban alkotva új fajokat.
- Új gének aktiválásakor a párosodási preferenciák megváltozásának következtében a meglévő fajok összeolvadhatnak vagy széteshetnek.

=== A szimuláció körei <model-steps>

A szimuláció körökre van osztva. Az első kör előtt létrehozunk egy $M_"init"$
egyedből álló populációt, véletlenszerű $N_"init"$ méretű genotípusú, nulla korú
és energiájú egyedekkel. A környezet energiaszintjét szintén nullára állítjuk.
Utána minden kör az alábbi forgatókönyvet követi:

+ A környezet energiatartalékát növeljük $E_"increase"$ értékével.
+ Minden egyed megpróbál magához venni $E_"intake"$ energiát a környezetből.
  Az igazságosság érdekében erre körönként véletlenszerű sorrendben van
  lehetőségük. Az egyedek koruk és $E_"discount"$ értékétől függő energiát
  "elpazarolnak", illetve $E_"consumption"$ egységnyi energiát elhasználnak.
  Lásd @energy-gain-formula egyenlet.
+ Azon egyedeket, melyek energia szintje már nem pozitív, eltávolítjuk.
+ Az többi egyed külön-külön $P_"encounter"$ valószínűséggel véletlenszerűen
  keres egy kompatibilis párt. Két egyed kompatibilis, ha genotípusuk távolsága
  egy adott metrika (például Euklideszi távolság) szerint nem több, mint
  $M_"limit"$.
+ Minden kompatibilis pár a @offspring-count-formula egyenletnek megfelelő
  számú új egyedet hoz létre, a genotípusuk távolsága, $M_"limit"$, $M_"const"$
  és $M_"slope"$ függvényében. Egy új egyed génjeit az alábbi módon határozzuk
  meg:
  - $P_"crossover"$ valószínűséggel az egyik, vagy másik szülő génjét vesszük
    alapul.
  - $P_"mutation"$ valószínűséggel a gént véletlenszerűen módosítjuk
    $[-V_"mutation", V_"mutation"]$ közötti értékkel.
  - Ha a gén egy meghatározott $[V_"min", V_"max"]$ allél tartományon kívül
    esik, a gyermeket eltávolítjuk.
+ Minden sikeres új egyed után $P_"change"$ valószínűséggel hozzáadunk egy-egy
  új gént az összes meglévő és jövőben létrejövő egyed genotípusához. Az új gén
  kísérlettől függően lehet véletlenszerű vagy függhet $V_"stretch"$ mértékben a
  meglévő utolsó géntől, lásd @stretch-formula egyenlet.

A szimuláció minden köre után méréseket végezhetünk, például az egyedek számát
vagy a környezet energiaszintjét. A legfontosabb emergens tulajdonság azonban az
egyedek párosodási preferenciái által alkotott fajok száma.

=== A modell paraméterei <model-params>

A modellben számos paramétert beállíthatunk a szimuláció indítása előtt:

==== Energiával kapcsolatos paraméterek

/ $E_"increase" in NN$, avagy környezet energianövekedése: Minden szimulációs
  kör előtt ennyi energiát adunk a környezet tartalékához.
/ $E_"consumption" in NN$, energia igény: Ennyi energiát veszít minden egyed a
  szimulációs kör végére.
/ $E_"intake" in NN$, avagy energia bevitel: Ennyi energiát próbál felvenni a
  környzetből minden egyes egyed a szimulációs kör folyamán. Kevesebb energiát
  is felvehet az egyed ha a környezet energiaszintje nem éri el az $E_"intake"$
  szintet.
/ $E_"discount" in RR$, avagy energiapazarlás: Az egyed a kora
  előrehaladtával egyre kevesebb energiát tud hasznosítani a felvett energiából,
  lásd @energy-gain-formula egyenlet.

==== Szaporodással kapcsolatos paraméterek

/ $[V_"min" in ZZ, V_"max" in ZZ]$, avagy allél intervallum: Az egyes gének
  minimum és maximum megengedett értéke. Ha egy egyed bármely génje ezen kívül
  esik, az adott egyed nem vehet részt a szimulációban.
/ $M_"limit" in NN$, avagy maximális különbözőség: Két egyed akkor kompatibilis
  egymással, hogyha a genotípusaik közötti távolságmetrika nem nagyobb, mint
  $M_"limit"$. Befolyásolja a párosodás során létrejövő egyedek számát is, lásd
  @offspring-count-formula egyenlet.
/ $M_"const" in NN$, avagy minimum gyermekszám: Két kompatibilis egyed párosdása során
  legalább $M_"const"$ új egyed jön létre. Lásd @offspring-count-formula
  egyenlet.
/ $M_"slope" in RR$: Befolyásolja a létrejövő egyedek számában a szülők hasonlóságának
  szerepét, lásd @offspring-count-formula egyenlet.
/ $P_"encounter" in RR$, avagy a párosodás valószínűsége: annak az esélye hogy az
  adott körben egy egyed párosodhat egy másik kompatibilis egyeddel.

==== Genetikai paraméterek

/ $P_"crossover" in RR$, avagy keresztezés valószínűsége: meghatározza, hogy az
  újonnan létrejövő egyed egy adott génje melyik szülőtől származzon.
/ $P_"mutation" in RR$, avagy mutáció valószínűsége: meghatározza annak a
  valószínűségét, hogy az újonnan létrejövő egyed egy adott génje eltolódik a
  szülő génjéhez képest
/ $V_"mutation" in NN$, avagy mutáció mértéke: meghatározza, hogy mutáció során a gén
  legfeljebb mekkora mértékben tolódhat el bármely irányba.
/ $P_"change" in RR$, avagy génállomány módosulás valószínűsége: meghatározza annak a
  valószínűségét, hogy egy új egyed létrejötte nyomán hozzáadunk-e minden egyes
  egyed genotípusához egy-egy új gént.
/ $V_"stretch" in NN$, avagy a _"stretch"_ eljárás együtthatója: Lásd @stretch-formula
  egyenlet.

==== Egyéb paraméterek

A @fatint cikkben ezek a paraméterek nem a modell jellemzői, de az
implementációk fontos paraméterei:

/ $M_"init" in NN$, avagy kezdő populáció mérete: Ennyi egyedet hozunk létre a
  szimuláció első köre előtt.
/ $N_"init" in NN$, avagy kezdő génszám: Ennyi génből fognak állni az egyedek
  genotípusai az első körben.

==== Alapértelmezett értékek <model-defaults>

#figure(
  caption: "A modell paramétereinek alapértelmezett értékei",
  [
    #show table.cell.where(x: 0): it => align(left)[#it]
    #table(
      columns: 3,
      table.header[Paraméter][Megengedett érték tartomány][Alapértelmezett érték],
      [$P_"encounter"$], [$RR inter [0.0, 1.0]$], [$0.1$],
      [$P_"change"$], [$RR inter [0.0, 1.0]$], [$0$],
      [$P_"crossing"$], [$RR inter [0.0, 1.0]$], [$0.2$],
      [$P_"mutation"$], [$RR inter [0.0, 1.0]$], [$0.2$],
      [$[V_"min", V_"max"]$], [$V_"min" in ZZ$, $V_"max" in ZZ$], [$[0, 100]$],
      [$V_"mutation"$], [$NN$], [$2$],
      [$V_"stretch"$], [$NN$], [$0$],
      [$M_"const"$], [$NN$], [$1$],
      [$M_"limit"$], [$NN$], [$15$],
      [$M_"slope"$], [$RR$], [$0$],
      [$E_"increase"$], [$RR inter [0.0, infinity)$], [$1000$],
      [$E_"consumption"$], [$RR inter [0.0, infinity)$], [$5$],
      [$E_"intake"$], [$RR inter [0.0, infinity)$], [$10$],
      [$E_"discount"$], [$RR inter [0.0, 1.0]$], [$0.9$],
      [$M_"init"$], [$NN inter [1, infinity)$], [$100$],
      [$N_"init"$], [$NN inter [1, infinity)$], [$5$],
    )
  ]
)

=== Egyenletek

Minden körben az entitások energiaszintje az alábbi @energy-gain-formula
egyenlet szerint módosul:
$ E_"change" = E_"intake" dot (E_"discount") ^ "age" - E_"consumption" $ <energy-gain-formula>
ahol $"age"$ az egyed "kora", azaz az egyed által megtett körök száma.

Egy kompatibilis pár szaporodás során létrejövő egyedeinek számát a
@offspring-count-formula egyenlet határozza meg:
$ "offspring count" = M_"const" + (M_"limit" - d) dot M_"slope" $ <offspring-count-formula>
ahol $d$ az alkalmazott távolságmetrika (pl. Euklédeszi távolság) a két szülő
egyed genotípusa között.

Amennyiben új géneket véletlenszám generálás helyett az úgynevezett
_"Stretch method"_ (_nyújtási eljárás_) módszerével állapítunk meg, akkor az
alábbi @stretch-formula egyenletet kell használni:
$ "new gene" = V_"min" dot ( "last gene" dot V_"stretch" ) mod ( V_"max" - V_"min" + 1 ) $ <stretch-formula>
ahol $"last gene"$ az adott entitás genotípusának utolsó eleme.

=== Kísérletek

A FATINT modell mindkét implementációjának dokumentációja használni fogja
*Kísérlet* és *Kísérletsor* fogalmakat:

#definition(title: "Kísérlet")[
  A szimuláció többszöri futtatása ugyanazon kezdő paraméterekkel, de különböző
  véletlen számokkal.
]

#definition(title: "Kísérletsor")[
  Kísérletek futtatása az egyik paraméter több lehetséges értékével, a többi
  paraméter rögzítése mellett.
]
