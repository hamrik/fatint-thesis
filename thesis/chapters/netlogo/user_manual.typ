#import "/lib/elteikthesis.typ": definition, todo, warning

== Felhasználói dokumentáció (NetLogo)

A NetLogo (@Wilensky_NetLogo_1999) egy modellszimulációs fejlesztőrendszer,
mellyel természetes és szociális modellek vizsgálhatók. Kiválóan alkalmas a
FATINT modell (lásd @model-desc) egyedeinek és kapcsolatainak szimulálására.

Ezen implementációval a NetLogo 6.4 keretrendszerben szimulálható a FATINT
modell, előre megadott vagy testreszabott paraméterekkel. Felmérhető lépésenként
az egyedek és az általuk alkotott fajok száma, és ezek az adatok exportálhatóak
több táblázatos formátumban. Statisztikák állíthatók fel több szimuláció között,
és következtetések szűrhetők le a modell viselkedését illetően.

#todo[Sounds weird, rephrase.]

=== Rendszerkövetelmények

- NetLogo 6.4
- Java 1.4 vagy újabb
- Legalább 8GB rendszermemória
- Legalább 500MB térhely a programnak és a végeredményeknek

#warning[
  A modell nem volt tesztelve a NetLogo 7-es verziójával. A modell viselkedése
  feltehetően változatlan, de a felület a szoftver új arculata miatt széteshet.
  Erősen javasolt a NetLogo 6.4 verziójának használata. A modell NetLogo 6.3
  vagy régebbi verzióban nem nyitható meg.
]

=== Telepítés és indítás

+ Látogassuk meg
#link("https://github.com/hamrik/fatint-thesis/releases/latest")[a projekt GitHub tárhelyét].
+ Töltsük le a legfrissebb verzió bejegyzésének alján linkelt ZIP fájlt.
+ Csomagoljuk ki egy nekünk tetsző helyre.
+ Töltsük le a NetLogo 6.4.0 verziójának telepítőjét a
  #link("https://www.netlogo.org/downloads/archive/6.4.0/")[NetLogo archívumból],
  majd indítsuk el és kövessük a képernyőn megjelenő utasításokat.
+ Nyissuk meg a NetLogo programot.
+ A menüsorban kattintsunk a *File* (_Fájl_) menüre, majd válasszuk ki az *Open*
  (_megnyitás_) opciót. Lásd @netlogo-menu-open.
  #figure(
    image("../../assets/screenshots/netlogo_menu_open.png", width: 50%),
    caption: [ A NetLogo 6.4.0 fő ablaka, a lenyitott _Fájl_ menüvel ],
  ) <netlogo-menu-open>
+ Tallózzuk ki a `model.nlogo` nevű fájlt és nyissuk meg.
+ Az ablak megjeleníti a szimuláció paramétereiből és mérhető tulajdonságaiból
  álló kezelőfelületet. Lásd @netlogo-model-ui.

=== A felület leírása <netlogo-ui-desc>

#figure(
  image("../../assets/screenshots/netlogo_model_ui.png", width: 50%),
  caption: [ A NetLogo 6.4.0 fő ablaka a modell paraméter mezőkkel ],
) <netlogo-model-ui>

A @netlogo-model-ui ábrán is látható felületen tudjuk állítani a
kezdőparamétereket, elindítani a szimulációt, illetve figyelni a modell
állapotának alakülását.

A modell paramétereit az @model-params fejezet részletezi.

A zöld dobozok beviteli mezők. A fehér mező nélküliek ki/be kapcsolók. A
kapcsoló piros nyelvére kattintva állítható. Ha a kapcsoló piros nyelve felfelé
néz, akkor az opció be van kapcsolva. A fehér mezős zöld dobozkba gépelve
testreszabhatóak a szám típusú paraméterek.

/ Starting population: A szimuláció populációjának kezdő mérete, $M_"init"$.
/ Starting allele count: Az egyedek genotípusának kezdő mérete, $N_"init"$.
/ Use stretch method: Új gének véletlenszerű generálása helyett a
  @stretch-formula egyenletben megfogalmazott _"Stretch"_ módszer használata.

Az alábbi paraméterek nem befolyásolják a szimuláció lefutását, de hatással
lehetnek annak hatékonyságára:

/ Measure every n steps: A fajok megszámlálása erőforrásigényes. Ezzel az
  opcióval megszabható, hogy hány szimulációs lépést követően fusson számlálás.
/ Use DS: A Diszjunkt-Halmaz algoritmus használata mélységi bejárás helyett a
  fajok megszámlálásakor. A modell viselkedését nem befolyásolja.

A lila dobozok nyomógombok:

/ Reset: Minden változót visszaállít az alapértelmezett értékekre, lásd
  @model-defaults fejezet.
/ Setup: Kezdőállapotba állítja a szimulációt. Törli a korábbi szimulációkból
  hátramaradt egyedeket, kezdőértékre állítja a gének számát és léthoz egy új
  populációt.
/ 1 step: Lefuttat pontosan egy szimulációs kört.
/ 500 steps: Lefuttat legfeljebb 500 szimulációs kört. Ha a populáció létszáma
  nullára esik, a szimuláció teminál akkor is, ha még nem futott le 500 kör.
/ Go: Folyamatosan futtatja a szimulációt amíg a populáció létszáma nullára nem
  csökken. Ha idő előtt szeretnénk leállítani a szimulációt, kattintsunk futás
  közben ismét gombra. Ha a program erre nem reagál, akkor a *Tools*
  (_Eszközök_) menü *Halt* (_Megállít_) opciójával kényszeríthetjük ki a
  leállást.
/ `+`: Kikényszeríti egy új gén hozzáadását minden egyed genotípusához.

A sárga dobozokban nyomon követhető a szimuláció aktuális állapota.

/ Population: A szimulációs körben részt vevő egyedek száma.
/ Species count: A szimulációs körben résztvevő egyedek által alkotott fajok
  száma.
/ Allele count: Az egyedek genotípusának elemszáma (gének száma).

==== Szimuláció futtatása

Egy szimuláció előkészítésének és futtatásának menete a következő:

+ Rákattintunk a _Reset_ gombra, ezzel minden paramétert visszaállítva
  alapértelmezett értékére.
+ A @netlogo-ui-desc fejezetben részletezett kezelőszervekkel beállítjuk a
  kívánt paramétereket.
+ Rákattintunk a _Setup_ gombra a szimuláció alaphelyzetbe állítására. Ha egy
  paraméter érvénytelen értékre van állítva, erről hibaüzetet kapunk.
+ Rákattintunk a _Step_, _500 steps_ vagy _Go_ gombra, rendre egy kör
  futtatásához, legfeljebb 500 kör futtatásához, vagy a megszakítás nélküli
  futtatáshoz.
+ Tanulmányozzuk a _Population_, _Species count_ és _Allele count_ grafikonokat.

A NetLogo kezelőfelületének egyéb elemeiről, illetve a szoftver használatához
szükséges programozási nyelvről bővebb információt
#link("https://docs.netlogo.org/")[a NetLogo használati utasítása]
nyújt.

#todo[_Allele_ is an incorrect term for this, use _Gene_]

=== Kísérletek futtatása

A grafikus kezelőfelülettel első kézből megtapasztalható a modell viselkedése,
de adatelemzésre ez a felület nem alkalmas. A modell NetLogo implementációja a
beépített kísérleteit és kísérletsorait a BehaviorSpace eszközzel definiálja.
A NetLogo BehaviorSpace nevű eszköze képes több szimulációt futtatni egyszerre,
táblázatos formátumban menteni a szimulációk lépésenkénti állapotát, valamint
statisztikákat előállítani a szimulációk állapotának átlagolásával. Használata
egyszerű:

#grid(
  columns: 2,
  gutter: 0.5cm,
  align: horizon,
  image("../../assets/screenshots/netlogo_menu_behaviorspace.png"),
  [
    #text("1.") A menüsorban kattintsunk a *Tools* (_Eszközök_) menüre, majd
    válasszuk ki a *BehaviorSpace* opciót.
  ],

  image("../../assets/screenshots/netlogo_behaviorspace_ui.png"),
  [
    #text("2.") Egy felugró ablak felsorolja az előre beállított kísérleteket és
    kísérletsorokat. Válasszuk ki a kívánt kísérletet vagy kísérletsort.
  ],

  image("../../assets/screenshots/netlogo_behaviorspace_edit.png"),
  [
    #text("3.") Az *Edit* (_Szerkesztés_) gombra kattintva testreszabhatjuk a
    szimuláció paramétereit.

    A paramétereknek megadható egy vagy több érték
    `["paraméter" érték1 érték2 érték3]` formában, vagy egy intervallum
    `["paraméter" [kezdőérték különbség végérték]]` formában. A paraméter nevét
    úgy kell írni, ahogy a hozzá tartozó zöld dobozba van írva.

    A többi mezőről bővebb leírást a
    #link("https://ccl.northwestern.edu/netlogo/6.4.0/docs/behaviorspace.html")[NetLogo használati utasítása]
    nyújt.
  ],

  image("../../assets/screenshots/netlogo_behaviorspace_run.png"),
  [
    #text("4.") A *Run* (_Futtatás_) gombra kattintva egy dialógus fog
    megnyílni.
    Az egyes fájl mezőkben tallózza ki az eredmények mentési útvonalát.
    / Spreadsheet: Nyers adatok exportálása, minden szimuláció külön oszlop,
    / Table: Nyers adatok exportálása, soronként egy szimuláció lépése
      minden lépés külön sor
    / Stats: Több futás lépésenkénti statiszkái (pl. átlag), soronként egy közös
      lépés
    / Lists: Listás kimenetek esetén minden lista elem egy oszlop. A FATINT
      modell nem alkalmazza.
    Azt is megadhatjuk, hogy a grafikonok a szimuláció alatt folyamatosan
    frissüljenek-e. Ez lassíthatja a kísérlet futását.
  ],

  image("../../assets/screenshots/netlogo_behaviorspace_running.png"),
  [
    5. Az *OK* gombra kattintva elindul a szimuláció. Egy ablak fogja mutatni
    annak aktuális állását. A szimuláció végén követően az ablak automatikusan
    bezárul.

    Ha idő előtt szeretnénk félbeszakítani a szimulációt, az a *Pause*
    (_Felfüggeszt_) vagy *Abort* (_Megszakít_) gombbal tehetjük. A felfüggesztés
    megvárja amíg a már elindított szimulációk lefutnak, de folytatható. A
    megszakítás azonnal leállítja a futó szimulációkat, de az nem folytatható,
    és az exportált adatok pontatlanok lesznek.
  ],
)
