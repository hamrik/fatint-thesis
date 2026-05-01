#import "/lib/elteikthesis.typ": *

== Felhasználói dokumentáció (NetLogo) <netlogo-user-manual>

A NetLogo (@Wilensky_NetLogo_1999) egy modellszimulációs fejlesztőrendszer,
mellyel természetes és szociális modellek vizsgálhatók. Kiválóan alkalmas a
FATINT modell (lásd @model-desc) egyedeinek és kapcsolatainak szimulálására.

Ezen implementációval a NetLogo 6.4 keretrendszerben szimulálható a FATINT
modell. Felmérhető lépésenként az egyedek és az általuk alkotott fajok száma,
és ezen adatok, illetve statisztikáik exportálhatóak többféle táblázatos
formátumban.

=== Rendszerkövetelmények <netlogo-sys-req>

A NetLogo és a szimulációk futtatásához az alábbiak a minimális követelmények:

- NetLogo 6.4
- Java 17 vagy újabb (NetLogo tartalmazza)
- Legalább 8GB rendszermemória
- Legalább 500MB térhely a programnak és a végeredményeknek

#warning[
  A modell nem volt tesztelve a NetLogo 7.0 verziójával. A modell viselkedése
  feltehetően változatlan, de a felület a szoftver új arculata miatt széteshet.
  Erősen javasolt a NetLogo 6.4 verziójának használata. A modell NetLogo 6.3
  vagy régebbi verzióban nem nyitható meg.
]

=== Telepítés és indítás

#figure(
  image("../../assets/screenshots/netlogo_menu_open.png", width: 50%),
  caption: [ A NetLogo 6.4.0 fő ablaka, a lenyitott _Fájl_ menüvel ],
) <netlogo-menu-open>

A NetLogo telepítéséhez és a FATINT modell NetLogo implementációjának
megnyitásához kövessük a @netlogo-setup-tutorial lépéseit:

#list(caption: "FATINT és NetLogo telepítése és indítása")[
+ Látogassuk meg #link("https://github.com/hamrik/fatint-thesis/releases/latest")[a projekt GitHub tárhelyét].
+ Töltsük le a legfrissebb verzió bejegyzésének alján linkelt ZIP fájlt.
+ Csomagoljuk ki egy nekünk tetsző helyre.
+ Töltsük le a NetLogo 6.4.0 verziójának telepítőjét a
  #link("https://www.netlogo.org/downloads/archive/6.4.0/")[NetLogo archívumból],
  majd indítsuk el és kövessük a képernyőn megjelenő utasításokat.
+ Nyissuk meg a NetLogo programot.
+ A menüsorban kattintsunk a *#text("File", lang: "en")* (_Fájl_) menüre, majd válasszuk ki az *#text("Open", lang: "en")*
  (_megnyitás_) opciót. Lásd @netlogo-menu-open.
+ Tallózzuk ki a `model.nlogo` nevű fájlt és nyissuk meg.
+ Az ablak megjeleníti a szimuláció paramétereiből és mérhető tulajdonságaiból
  álló kezelőfelületet. Lásd @netlogo-model-ui.
] <netlogo-setup-tutorial>

=== A felület leírása <netlogo-ui-desc>

#figure(
  image("../../assets/screenshots/netlogo_model_ui.png", width: 50%),
  caption: [ A NetLogo 6.4.0 fő ablaka a modell paraméter mezőkkel ],
) <netlogo-model-ui>

Az @netlogo-model-ui ábrán is látható felületen tudjuk állítani a
kezdőparamétereket, elindítani a szimulációt, illetve figyelni a modell
állapotának alakülását.

A modell paramétereit az @model-params fejezet részletezi.

A zöld dobozok beviteli mezők. A fehér mező nélküliek ki/be kapcsolók. A
kapcsoló piros nyelvére kattintva állítható. Ha a kapcsoló piros nyelve felfelé
néz, akkor az opció be van kapcsolva. A fehér mezős zöld dobozokba gépelve
testre szabhatóak a szám típusú paraméterek.

/ #text("Starting population", lang: "en"):
  A szimuláció populációjának kezdő mérete, $M_"init"$.
/ #text("Starting gene count", lang: "en"):
  Az egyedek genotípusának kezdő mérete, $N_"init"$.
/ #text("Use stretch method", lang: "en"):
  Új gének véletlenszerű generálása helyett a @stretch-formula egyenletben
  megfogalmazott _"Stretch"_ módszer használata.

Az alábbi paraméterek nem befolyásolják a szimuláció lefutását, de hatással
lehetnek annak hatékonyságára:

/ #text("Measure every n steps", lang: "en"):
  A fajok megszámlálása sok erőforrást igényel. Ezzel az opcióval megszabható,
  hogy hány szimulációs lépést követően fusson számlálás.
/ #text("Use DS", lang: "en"):
  A Diszjunkt-Halmaz algoritmus használata mélységi bejárás helyett a fajok
  megszámlálásakor. A modell viselkedését nem befolyásolja.

A lila dobozok nyomógombok:

/ #text("Reset", lang: "en"):
  Minden változót visszaállít az alapértelmezett értékekre, lásd
  @model-defaults fejezet.
/ #text("Setup", lang: "en"):
  Kezdőállapotba állítja a szimulációt. Törli a korábbi szimulációkból
  hátramaradt egyedeket, kezdőértékre állítja a gének számát és léthoz egy új
  populációt.
/ #text("1 step", lang: "en"):
  Lefuttat pontosan egy szimulációs kört.
/ #text("500 steps", lang: "en"):
  Lefuttat legfeljebb 500 szimulációs kört. Ha a populáció létszáma
  nullára esik, a szimuláció terminál akkor is, ha még nem futott le 500 kör.
/ #text("Go", lang: "en"):
  Folyamatosan futtatja a szimulációt amíg a populáció létszáma nullára nem
  csökken. Ha idő előtt szeretnénk leállítani a szimulációt, kattintsunk futás
  közben ismét gombra. Ha a program erre nem reagál, akkor a *Tools*
  (_Eszközök_) menü *Halt* (_Megállít_) opciójával kényszeríthetjük ki a
  leállást.
/ `+`:
  Kikényszeríti egy új gén hozzáadását minden egyed genotípusához.

A sárga dobozokban nyomon követhető a szimuláció aktuális állapota.

/ #text("Population", lang: "en"):
  A szimulációs körben részt vevő egyedek száma.
/ #text("Species count", lang: "en"):
  A szimulációs körben résztvevő egyedek által alkotott fajok
  száma.
/ #text("Gene count", lang: "en"):
  Az egyedek genotípusának elemszáma (aktivált gének száma).

==== Szimuláció futtatása

Egy szimuláció előkészítéséhez és futtatásához kövessük az alábbi lépéseket:

+ Kattintsunk a _Reset_ gombra, ezzel minden paramétert visszaállítva
  alapértelmezett értékére.
+ A @netlogo-ui-desc fejezetben részletezett kezelőszervekkel állítsuk be a
  kívánt paramétereket.
+ Kattintsunk a _Setup_ gombra a szimuláció alaphelyzetbe állítására. Ha egy
  paraméter érvénytelen értékre van állítva, erről hibaüzenetet kapunk.
+ Kattintsunk a _Step_, _500 steps_ vagy _Go_ gombra, rendre egy kör
  futtatásához, legfeljebb 500 kör futtatásához, vagy a megszakítás nélküli
  futtatáshoz.
+ A szimuláció automatikusan leáll amikor az utolsó egyed is meghal.
  A _Go_ gombbal indított szimuláció megállítható azzal, hogy újra rákattintunk
  a _Go_ gombra. Továbbá minden szimuláció megszakítható azzal, hogy a *Tools*
  (_Eszközök_) menüből kiválasztjuk a *Halt* (_Megszakít_) opciót.
+ Tanulmányozzuk a _Population_, _Species count_ és _Gene count_ grafikonok
  alakulását. Ezen grafikonok rendre a populáció létszámának, az általuk
  alkotott fajok számának és az aktivált gének számának alakulását rögzítik.

A NetLogo kezelőfelületének egyéb elemeiről, illetve a szoftver használatához
szükséges programozási nyelvről bővebb információt
#link("https://docs.netlogo.org/")[a NetLogo használati utasítása] nyújt.

=== Kísérletek futtatása <netlogo-behaviorspace-tutorial>

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
  align: left + horizon,
  [#figure(
    image("../../assets/screenshots/netlogo_menu_behaviorspace.png"),
    caption: [NetLogo 6.4.0, betöltött modell, _Fájl_ menü nyitva]
  ) <netlogo-bs-tut-step1>],
  [
    #text("1.") A menüsorban kattintsunk a *Tools* (_Eszközök_) menüre, majd
    válasszuk ki a *BehaviorSpace* opciót. Lásd @netlogo-bs-tut-step1.
  ],

  [#figure(
    image("../../assets/screenshots/netlogo_behaviorspace_ui.png"),
    caption: [BehaviorSpace kísérletsor listázó]
  ) <netlogo-bs-tut-step2>],
  [
    #text("2.") Egy felugró ablak felsorolja az előre beállított kísérleteket és
    kísérletsorokat, lásd @netlogo-bs-tut-step2. Válasszuk ki a kívánt kísérletet vagy kísérletsort.
  ],

  [#figure(
    image("../../assets/screenshots/netlogo_behaviorspace_edit.png"),
    caption: [BehaviorSpace kísérletsor szerkesztő]
  ) <netlogo-bs-tut-step3>],
  [
    #text("3.") Az *Edit* (_Szerkesztés_) gombra kattintva testre szabhatjuk a
    szimuláció paramétereit az @netlogo-bs-tut-step3 ábrán látható ablakban.

    A paramétereknek megadható egy vagy több érték
    `["paraméter" érték1 érték2 érték3]` formában, vagy egy intervallum
    `["paraméter" [kezdőérték különbség végérték]]` formában. A paraméter nevét
    úgy kell írni, ahogy a hozzá tartozó zöld dobozba van írva.

    A többi mezőről bővebb leírást a
    #link("https://ccl.northwestern.edu/netlogo/6.4.0/docs/behaviorspace.html")[NetLogo használati utasítása]
    nyújt.
  ],

  [#figure(
    image("../../assets/screenshots/netlogo_behaviorspace_run.png"),
    caption: [BehaviorSpace kísérletsor futtatás opciók]
  ) <netlogo-bs-tut-step4>],
  [
    #text("4.") A *Run* (_Futtatás_) gombra kattintva egy dialógus fog megnyílni,
    lásd @netlogo-bs-tut-step5.
    Az egyes fájl mezőkben tallózza ki az eredmények mentési útvonalát.
    / #text("Spreadsheet", lang: "en"): Nyers adatok exportálása, minden szimuláció külön oszlop,
    / #text("Table", lang: "en"): Nyers adatok exportálása, soronként egy szimuláció lépése
      minden lépés külön sor
    / #text("Stats", lang: "en"): Több futás lépésenkénti statisztikái (például átlag),
      soronként egy közös lépés
    / #text("Lists", lang: "en"): Listás kimenetek esetén minden lista elem egy oszlop.
      A FATINT modell nem alkalmazza.
    Azt is megadhatjuk, hogy a grafikonok a szimuláció alatt folyamatosan
    frissüljenek-e. Ez lassíthatja a kísérlet futását.
  ],

  [#figure(
    image("../../assets/screenshots/netlogo_behaviorspace_running.png"),
    caption: [BehaviorSpace kísérletsor futás közben]
  ) <netlogo-bs-tut-step5>],
  [
    #text("5.") Az *OK* gombra kattintva elindul a szimuláció. Egy ablak fogja mutatni
    annak aktuális állását (lásd @netlogo-bs-tut-step5). A szimuláció végén követően az ablak automatikusan bezárul.

    Ha idő előtt szeretnénk félbeszakítani a szimulációt, az a *Pause*
    (_Felfüggeszt_) vagy *Abort* (_Megszakít_) gombbal tehetjük. A felfüggesztés
    megvárja amíg a már elindított szimulációk lefutnak, de folytatható. A
    megszakítás azonnal leállítja a futó szimulációkat, de az nem folytatható,
    és az exportált adatok pontatlanok lesznek.
  ]
)
