#import "/lib/elteikthesis.typ": definition, todo

== A modell leírása <model-desc>

*Nyitott evolúciónak* hívjuk azon szimulációs rendszereket, melyek folyamatosan
új komplexitást alkotnak, nem rekednek meg egy adott állapotban. Fontos
megjegyezni, hogy ezek nem optimalizációs algoritmusok, nincs "céljuk" vagy
minimalizálandó "költségfüggvényük".

A *FATINT* modell (melynek neve a Fat Interactions, magyarul _kövér interakciók_
rövidítése) egy olyan egyed szimulációs modell, melynek célja a nyitott evolúció
demonstrálása egy stabil, de folyamatosan változó "ökoszisztéma" fenntartásával.
Ezt arra a megfigyelésre alapozza, hogy való életben az élőlények génjeinek
működésére hatást gyakorol a környezetük és az élőlények egymással való
viselkedése.

A cikk egy lehetséges példaként a zsiráfok nyakát hozza fel, mely akkor vált
egy fontos, meghatározó tulajdonsággá, amikor az egymással összecsapó hímek a
nyakuk hosszának függvényében tudtak sikeresen párt találni.

A FATINT modellben semleges nemű egyedeket szimulálunk. Ezek az egyedek energiát
vesznek fel a környezetből, párosodnak, veszítenek energiájukból, és végül
meghalnak, ha a környezet nem tud minden elő egyedet eltartani, vagy ha az
egyed kora előrehaladtával már nem képes megfelelően hasznosítani a felvett
energiát.

Minden egyednek van egy genotípusa (egész számok vektoraként ábrázolva), mely
meghatározza, hogy mely további egyedekkel tud párosodni (egy meghatározott
távolságmetrika és küszöbérték szerint). Ezen párosodási "preferenciák" mentén
az egyedek külön halmazokba sorolhatók, ahol az egyes egyedek a halmazukon kívül
eső egyedekkel nem tudnak párosodni. Ezeket a halmazokat nevezzük *fajoknak*. A
modell célja, hogy az idő előrehaladtával újabb és újabb fajokat alkosson, ezzel
demonstrálva a nyitott evolúciót.

Egy faj felfogható azon gráf összefüggő komponensének, melynek csúcsai az
életben lévő egyedek, az élek pedig a párosodni képes párok.
#todo("This second definition is a little out of place here")

Új fajok több módon is létrejöhetnek:
- Egy egyed halálával annak faja két vagy több külön fajjá eshet szét, ha a két
  alfajok között ez az egy egyed volt a "kapocs".
- Párosodás során két szülő egyed létrehozhat egy vagy több gyermek egyedet.
  Ezen egyedek mindkét szülőtől örökölnek géneket, ezen felül pedig
  mutálódhatnak is. Előfordulhat, hogy az új egyedek már képesek más fajok
  egyedeivel párosodni, egyesítve két vagy több fajt egy új fajjá. Az is
  előfordulhat, hogy nem képesek párosodni senkivel, önmagukban alkotva új
  fajokat.
- A szimuláció során kiválthatunk olyan eseményeket, melyek minden egyed
  genotípusát egyszerre bővítik, módosítva az egyedek párosodási preferenciáit.
  Ez megfeleltethető a környezeti változások által aktivált géneknek. Ezen
  események új fajok kialakulásához vezethetnek, a korábbiak szétesésével vagy
  összeolvadásával.

=== A szimuláció körei

A szimuláció körökre van osztva. Minden kör az alábbi forgatókönyvet követi:

+ A környezet energiatartalékát növeljük $E_"increase"$ értékével.
+ Minden egyed megpróbál magához venni némi energiát a környezetből.
  Az igazságosság érdekében erre körönként véletlenszerű sorrendben van
  lehetőségük.
+ Minden egyed energiát veszít, lásd @energy-gain-formula egyenlet.
+ Azon egyedeket, melyek energia szintje már nem pozitív, eltávolítjuk.
+ Minden további egyed külön-külön $P_"encounter"$ valószínűséggel
  véletlenszerűen keres egy kompatibilis párt.
+ Minden kompatibilis pár az @offspring-count-formula egyenletnek megfelelő
  számú új egyedet hoz létre. Egy új egyed génjeit az alábbi módon határozzuk
  meg:
  - $P_"crossover"$ valószínűséggel az egyik, vagy másik szülő génjét vesszük
    alapul.
  - $P_"mutation"$ valószínűséggel a gént véletlenszerűen módosítjuk
    $[-V_"mutation", V_"mutation"]$ közötti értékkel.
  - Ha a gén egy meghatározott $[V_"min", V_"max"]$ allél tartományon kívül
    esik, a gyermeket eltávolítjuk.
+ Minden egyes új egyed után $P_"change"$ valószínűséggel hozzáadunk egy-egy új
  gént az összes meglévő és jövőben létrejövő egyed genotípusához. Az új gén
  kísérlettől függően lehet véletlenszerű vagy függhet a meglévő utolsó géntől,
  lásd @stretch-formula egyenlet.

A szimuláció minden köre után méréseket végezhetünk, például az egyedek számát
vagy a környezet energiaszintjét. A legfontosabb emergens tulajdonság azonban az
egyedek párosodási preferenciái által alkotott fajok száma.

=== Változók

Az egyedek az alábbi tulajdonságokkal rendelkeznek:

/ Kor: A egyed által megélt szimulációs körök száma.
/ Energia: Egy nemnegatív szám, mely az egyed energiaszintjét reprezentálja. Ha
  kör végén nulla, az egyed "meghal", és eltávolításra kerül a szimulációból.
/ Genotípus: A egész számokból álló vektor, melynek segítségével meghatározható,
  hogy az adott egyed mely további egyedekkel tud párosodni. A vektor elemeit
  *génekek* hívjuk.

Az egyedek közös környezete az alábbi tulajdonságokkal rendelkezik:

/ Energia: A környezet elérhető energiatartaléka. Ha elfogy, az egyedek nem
  tudják kipótolni saját energiaszintjüket.
/ Génszám: Meghatározza, hogy az egyes egyedek genotípusa hány elemből áll.

A fenti tulajdonságok a szimuláció előrehaladtával változnak. Az alábbi
paraméterek viszont a szimuláció előtt beállításra kerülnek, és a szimuláció
futása során nem módosulnak.

=== Energiával kapcsolatos paraméterek

/ $E_"increase"$, avagy környezet energianövekedése: Minden szimulációs kör
  előtt ennyi energiát adunk a környezet tartalékához.
/ $E_"consumption"$, energia igény: Ennyi energiát veszít minden egyed a
  szimulációs kör végére.
/ $E_"intake"$, avagy energia bevitel: Ennyi energiát próbál felvenni a
  környzetből minden egyes egyed a szimulációs kör folyamán. Kevesebb energiát
  is felvehet az egyed ha a környezet energiaszintje nem éri el az $E_"intake"$
  szintet.
/ $E_"discount"$, avagy energiapazarlás: Az egyed a kora előrehaladtával egyre
  kevesebb energiát tud hasznosítani a felvett energiából, lásd
  @energy-gain-formula egyenlet.

=== Szaporodással kapcsolatos paraméterek

/ $V_"min"$ és $V_"max"$, avagy allél intervallum: Az egyes gének minimum és
  maximum megengedett értéke. Ha egy egyed bármely génje ezen kívül esik, az
  adott egyed nem vehet részt a szimulációban.
/ $M_"limit"$, avagy maximális különbözőség: Két egyed akkor kompatibilis
  egymással, hogyha a genotípusaik közötti távolságmetrika nem nagyobb, mint
  $M_"limit"$. Befolyásolja a párosodás során létrejövő egyedek számát is, lásd
  @offspring-count-formula egyenlet.
/ $M_"const"$, avagy minimum gyermekszám: Két kompatibilis egyed párosdása során
  legalább $M_"const"$ új egyed jön létre. Lásd @offspring-count-formula
  egyenlet.
/ $M_"slope"$: Befolyásolja a létrejövő egyedek számában a szülők hasonlóságának
  szerepét, lásd @offspring-count-formula egyenlet.
/ $P_"encounter"$, avagy a párosodás valószínűsége: annak az esélye hogy az
  adott körben egy egyed párosodhat egy másik kompatibilis egyeddel.

=== Genetikai paraméterek

/ $P_"crossover"$, avagy keresztezés valószínűsége: meghatározza, hogy az
  újonnan létrejövő egyed egy adott génje melyik szülőtől származzon.
/ $P_"mutation"$, avagy mutáció valószínűsége: meghatározza annak a
  valószínűségét, hogy az újonnan létrejövő egyed egy adott génje eltolódik a
  szülő génjéhez képest
/ $V_"mutation"$, avagy mutáció mértéke: meghatározza, hogy mutáció során a gén
  legfeljebb mekkora mértékben tolódhat el bármely irányba.
/ $P_"change"$, avagy génállomány módosulás valószínűsége: meghatározza annak a
  valószínűségét, hogy egy új egyed létrejötte nyomán hozzáadunk-e minden egyes
  egyed genotípusához egy-egy új gént.

=== Egyenletek

Minden körben az entitások energiaszintje az alábbi egyenlet szerint módosul:
$ E_"change" = E_"intake" dot (E_"discount") ^ "age" - E_"consumption" $ <energy-gain-formula>
ahol $"age"$ az egyed "kora", azaz az egyed által megtett körök száma.

Egy kompatibilis pár szaporodás során létrejövő egyedeinek száma:
$ "offspring count" = M_"const" + (M_"limit" - d) dot M_"slope" $ <offspring-count-formula>
ahol $d$ az alkalmazott távolságmetrika (pl. Euklédeszi távolság) a két szülő
egyed genotípusa között.

Amennyiben új géneket véletlenszám generálás helyett az úgynevezett
_"Stretch method"_ (_nyújtási eljárás_) módszerével állapítunk meg, akkor az
alábbi egyenletet kell használni:
$ "new gene" = V_"min" dot ( "last gene" dot V_"stretch" ) mod ( V_"max" - V_"min" + 1 ) $ <stretch-formula>
ahol $"last gene"$ az adott entitás genotípusának utolsó eleme.
