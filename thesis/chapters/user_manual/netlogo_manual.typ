#import "/lib/elteikthesis.typ": definition, todo

== NetLogo implementáció

#todo("Describe what NetLogo is")

=== Rendszerkövetelmények

- NetLogo 6
- Java 1.4 vagy újabb
- Legalább 256MB rendszermemória
- Legalább 25MB térhely

#todo("Verify system req")

=== Telepítés és indítás

+ Töltsön le a teljes repót, vagy annak `fatint-netlogo` nevű mappáját.
+ Töltse le és indítsa el a NetLogo 6-os verziójának telepítőjét a #link("https://www.netlogo.org") weboldalról.
+ Nyissa meg a NetLogo programot. Egy üres ablak fog megnyílni.
+ A menüsorban kattintson a *File* (_Fájl_) menüre, majd válassza ki az *Open* (_megnyitás_) opciót. Lásd @nl-menu.
+ Tallózza majd válassza ki a `model.nlogo` nevű fájlt.
+ Az ablak megjeleníti a szimuláció paramétereiből és mérhető tulajdonságaiból álló kezelőfelületet. Lásd @nl-controls.

#grid(
  columns: (1fr, 1fr),
  [#figure(
    image("../../assets/screenshots/netlogo_menu_open.png"),
    caption: [ A NetLogo 6 fő ablaka, a lenyitott _Fájl_ menüvel ]
  ) <nl-menu>],
  [#figure(
    image("../../assets/screenshots/netlogo_model_ui.png"),
    caption: [ A NetLogo 6 fő ablaka a modell paraméter mezőkkel ]
  ) <nl-controls>]
)

=== A szimuláció futtatása

A zöld dobozok olyan paraméterek, melyek kívánt értékeit a fehér mezőbe írhatja. Azon zöld dobozok melyek nem tartalmaznak fehér mezőt, egyszerű ki/be kapcsolók. A kapcsoló piros nyelvére kattintva állítható. Ha a kapcsoló piros nyelve felfelé néz, akkor az opció be van kapcsolva.


/ Starting population: A szimuláció első lépése ekkora populációval indul
/ Starting allele count: Ennyi génnel indul minden egyed genotípusa az első körben
/ Use stretch method: Új gént véletlenszám generálás helyett az @stretch-formula egyenletben megfogalmazott _"Stretch"_ módszer határozza meg.

A modell további paramétereinek jelentéséről részletes leírást talál a @model-desc fejezetben.

Az alábbi paraméterek nem befolyásolják a szimuláció lefutását, de hatással lehetnek annak hatékonyságára:

/ Measure every n steps: A fajok megszámlálása erőforrásigényes. Ezzel az opcióval megszabható, hogy hány szimulációs lépésenként fusson számlálás.
/ Use DS: A Diszjunkt-Halmaz algoritmus használata naív mélységi bejárás helyett.

#todo("Compare DS and DFS performance.")

A lila dobozok nyomógombok:

/ Setup: Kezdőállapotba állítja a szimulációt.
/ 1 step: Lefuttat pontosan egy szimulációs kört.
/ 500 steps: Lefuttat legfejlebb 500 szimulációs kört.
/ Go: Folyamatosan futtatja a szimulációt amíg a populáció létszáma nullára nem csökken.
/ `+`: Kikényszeríti egy új gén bevezetését minden egyed genotípusába.

A sárga dobozban nyomon követhető a szimuláció aktuális állapota.

/ Population: A szimulációs körben részt vevő egyedek száma.
/ Species count: A szimulációban fellelhető fajok száma.
/ Allele count: Az egyedek genotípusának elemszáma (gének száma).

#todo[_Allele_ is an incorrect term for this, use _Gene_]

=== Egy kísérlet futtatása

#definition(title: "Kísérlet")[
  A szimuláció többszöri futtatása ugyanazon kezdő paraméterekkel, de különböző véletlen számokkal.
]

#grid(
  columns: (1fr, 1fr),
  gutter: 0.5cm,
  align: horizon,
  image("../../assets/screenshots/netlogo_menu_behaviorspace.png"),
  [
    A menüsorban kattintson a *Tools* (_Eszközök_) menüre és válassza ki a *BehaviorSpace* opciót.
  ],
  image("../../assets/screenshots/netlogo_behaviorspace_ui.png"),
  [
    Egy felugró ablak felsorolja az előre beállított kísérleteket.
    Válassza ki a kívánt kísérletet.
  ],
  image("../../assets/screenshots/netlogo_behaviorspace_edit.png"),
  [
    Az *Edit* (_Szerkesztés_) gombra kattintva testreszabhatók a szimulációs paraméterek.
  ],
  image("../../assets/screenshots/netlogo_behaviorspace_run.png"),
  [
    A *Run* (_Futtatás_) gombra kattintva egy dialógus fog megnyílni. Az egyes fájl mezőkben tallózza ki az eredmények mentési útvonalát. #todo("Describe each output format")
    Ebben a dialógusban megadhatja, hogy a gráfok a szimuláció alatt folyamatosan frissüljenek-e. Ez lassíthatja a kísérlet futását.
  ],
  image("../../assets/screenshots/netlogo_behaviorspace_running.png"),
  [
    Az *OK* gombra kattintva elindul a szimuláció. Egy ablak fogja mutatni annak aktuális állását. A szimuláció végén követően az ablak automatikusan bezárul.
  ],
)

=== Egy kíséletsor futtatása

#definition(title: "Kísérletsor")[
  Olyan kísérletek sorozata, melyek csak egy paraméterben térnek egy egymástól.
]
