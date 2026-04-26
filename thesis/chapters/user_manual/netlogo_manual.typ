#import "/lib/elteikthesis.typ": definition, todo

== NetLogo implementáció

A NetLogo egy modellszimulációs fejlesztőrendszer, mellyel természetes és
szociális modellek vizsgálhatók. Kiválóan alkalmas a FATINT modell
(lásd @model-desc) egyedeinek és kapcsolatainak szimulálására.

=== Rendszerkövetelmények

- NetLogo 6.4.0
- Java 1.4 vagy újabb
- Legalább 8GB rendszermemória
- Legalább 500MB térhely a programnak és a végeredményeknek

=== Telepítés és indítás

+ Töltse le a teljes repót, vagy annak `fatint-netlogo` nevű almappáját.
+ Töltse le és indítsa el a NetLogo 6.4.0 verziójának telepítőjét a
  #link("https://www.netlogo.org/downloads/archive/6.4.0/")[NetLogo archívumból].
+ Nyissa meg a NetLogo programot.
+ A menüsorban kattintson a *File* (_Fájl_) menüre, majd válassza ki az *Open*
  (_megnyitás_) opciót.
  #figure(
    image("../../assets/screenshots/netlogo_menu_open.png", width: 50%),
    caption: [ A NetLogo 6.4.0 fő ablaka, a lenyitott _Fájl_ menüvel ]
  )
+ Tallózza majd válassza ki a `model.nlogo` nevű fájlt.
+ Az ablak megjeleníti a szimuláció paramétereiből és mérhető tulajdonságaiból
  álló kezelőfelületet.
  #figure(
    image("../../assets/screenshots/netlogo_model_ui.png", width: 50%),
    caption: [ A NetLogo 6 fő ablaka a modell paraméter mezőkkel ]
  )


=== A szimuláció futtatása

A zöld dobozok olyan paraméterek, melyek kívánt értékeit a fehér mezőbe írhatja.
Azon zöld dobozok melyek nem tartalmaznak fehér mezőt, egyszerű ki/be kapcsolók.
A kapcsoló piros nyelvére kattintva állítható. Ha a kapcsoló piros nyelve
felfelé néz, akkor az opció be van kapcsolva.

/ Starting population: A szimuláció első lépése ekkora populációval indul
/ Starting allele count: Ennyi génnel indul minden egyed genotípusa az első
  körben
/ Use stretch method: Új gének véletlenszerű generálása helyett a
  @stretch-formula egyenletben megfogalmazott _"Stretch"_ módszer használata.

A modell további paramétereinek jelentéséről részletes leírást talál az
@model-desc fejezetben.

Az alábbi paraméterek nem befolyásolják a szimuláció lefutását, de hatással
lehetnek annak hatékonyságára, lásd @performance fejezet:

/ Measure every n steps: A fajok megszámlálása erőforrásigényes. Ezzel az
  opcióval megszabható, hogy hány szimulációs lépést követően fusson számlálás.
/ Use DS: A Diszjunkt-Halmaz algoritmus használata naív mélységi bejárás helyett
  a fajok megszámlálásakor. A modell viselkedését nem befolyásolja.

A lila dobozok nyomógombok:

/ Reset: Minden változót visszaállít az alapértelmezett értékekre, lásd
  @model-desc fejezet.
/ Setup: Kezdőállapotba állítja a szimulációt.
/ 1 step: Lefuttat pontosan egy szimulációs kört.
/ 500 steps: Lefuttat legfejlebb 500 szimulációs kört.
/ Go: Folyamatosan futtatja a szimulációt amíg a populáció létszáma nullára nem
  csökken. Ha idő előtt szeretnénk leállítani a szimulációt, azt a *Tools*
  (_Eszközök_) menü *Halt* (_Megállít_) opciójával tehetjük meg.
/ `+`: Kikényszeríti egy új gén bevezetését minden egyed genotípusába.

A sárga dobozban nyomon követhető a szimuláció aktuális állapota.

/ Population: A szimulációs körben részt vevő egyedek száma.
/ Species count: A szimulációban fellelhető fajok száma.
/ Allele count: Az egyedek genotípusának elemszáma (gének száma).

#todo[_Allele_ is an incorrect term for this, use _Gene_]

=== Kísérletek futtatása

#definition(title: "Kísérlet")[
  A szimuláció többszöri futtatása ugyanazon kezdő paraméterekkel, de különböző
  véletlen számokkal.
]

#definition(title: "Kísérletsor")[
  Olyan kísérletek sorozata, melyek csak egy paraméterben térnek egy egymástól.
]

#grid(
  columns: (1fr, 1fr),
  gutter: 0.5cm,
  align: horizon,
  image("../../assets/screenshots/netlogo_menu_behaviorspace.png"),
  [
    #text("1.") A menüsorban kattintson a *Tools* (_Eszközök_) menüre és válassza ki a
    *BehaviorSpace* opciót.
  ],
  image("../../assets/screenshots/netlogo_behaviorspace_ui.png"),
  [
    #text("2.") Egy felugró ablak felsorolja az előre beállított kísérleteket és
    kísérletsorokat. Válassza ki a kívánt kísérletet vagy kísérletsort.
  ],
  image("../../assets/screenshots/netlogo_behaviorspace_edit.png"),
  [
    #text("3.") Az *Edit* (_Szerkesztés_) gombra kattintva testreszabhatók a szimulációs
    paraméterek.
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
