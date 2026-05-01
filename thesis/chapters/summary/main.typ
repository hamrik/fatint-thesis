= Összegzés

Ebben a dokumentumban bemutattuk két implementációját a FATINT modellnek.
A NetLogo implementáció egy intuitív grafikus felületen nyújt lehetőséget
a modell viselkedésének interaktív elemzéséhez, a C++ implementáció pedig
hatékonyan, rövid idő alatt képes kísérletsorokat szimulálni, ezzel
elősegítve a gyors iterálást a paraméterek elemzése során.

Grafikonokkal szemléltettük a modell viselkedését különböző paraméterek
mellett, és összehasonlítva a @fatint cikkben tapasztalt viselkedéssel
meggyőződtünk róla, hogy a modell tükrözi az eredetileg tapasztalt, elvárt
működést, sikeresen reprodukálja az eredményeket és demonstrálja a
nyitott evolúciót.

== Limitációk

Az elért eredmények ellenére mindkét implementációnak vannak fájó pontjai.
A NetLogo kiválóan alkalmas prototípusok gyors fejlesztésre, megvalósíthatósági
felmérésre és modellek demonstrálására a beépített felülettervezőnek és a gyors
fejlesztői iterációnak köszönhetően, azonban komolyabb fejlesztésre és nagy
adatmennyiségű szimulációkra nem alkalmas. A programozási nyelve limitált,
sok objektumelvű koncepciót nem támogat, nehezítve a modell későbbi bővítését.
Emellett nagy objektumszám mellett jelentősen lelassul, egy-egy kísérletsornak
futtatása több, mint fél órát is igénybe vehet.

A C++ implementáció ezzel szemben gyors, de primitív. Nincs felhasználói
felület, a felhasználó a szimuláció futása közben semmilyen visszajelzést nem
kap. A parancssori eszköz egyszerre csak egy paramétert tud végigsöpörni. A
kódja az objektumelvű tervezésnek köszönhetően sokkal könnyebben bővíthető,
mint a NetLogo implementáció, azonban szükség van egy fordítóra, és minden
módosítás után le kell fordítani a kódot, ami miatt a visszajelzés és
fejlesztési iteráció lassú.

== Lehetséges továbbfejlesztések

A C++ implementáció magja egy könyvtár, így a meglévő parancssori eszköz
mellé lehetőség van egy grafikus felület fejlesztésére is.

A könyvtárban jelenleg több interfésznek csak egy implementációja van. Lehetséges kutatási irány például különböző távolságmetrikák implementálása
és összehasonlítása, új kimeneti formátumok implementálása is hasznos lehet.

== Mesterséges intelligencia

A szakdolgozat a #link("https://typst.app")[Typst szövegformázó rendszerrel]
készült. Az ELTE szakdolgozat formai követelményeit Cserép Máté egy #link("https://github.com/mcserep/elteikthesis")[LaTex rendszerhez készített sablonban] implementálta. Ezt a vázlatot a szerző #text("Claude Sonnet 4.6", lang: "en") modellel Typst nyelvre fordította, majd kézi felülvizsgálat után
jelentősen átalakította.

A NetLogo implementáció létrehozásában semmilyen formában nem vett
részt mesterséges intelligencia.

A mesterségeges intelligencia szerepét a C++ implementáció
létrehozása során a @cpp-ai fejezet részletezi.
