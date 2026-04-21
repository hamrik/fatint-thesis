#import "/lib/elteikthesis.typ": todo

== NetLogo implementáció

=== Specifikáció

#todo("Consider using a common specification with C++ impl right after model spec")

#todo("Specify the UI, create GIVEN-WHEN-THEN tables for common workflows")

#todo("Consider creating a usecase diagram?")

=== Tesztelés

A NetLogo 6 nem tartalmaz beépített tesztelési eszközöket, így ezt az implementációt kézzel kell tesztelni.

A modell fájlba ágyazott kísérletek viszont futtathatóak a felület indítása nélkül is, a NetLogo gyökérmappájában található
`NetLogo_Console` eszköz segítségével.

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
- `no-additional-alleles-sweep-encounter`
- `no-additional-alleles-sweep-mutation`
- `no-additional-alleles-sweep-crossing`
- `random-new-allele-sweep-change`
- `random-new-allele-sweep-mlimit`
- `stretch-new-allele-sweep-stretch`

==== Populáció öregedése

+ Állítsuk $P_"encounter"$ értékét $0$-ra, minden mást hagyjunk alapértelmezett értéken.
+ Kattintsunk a *Setup*, majd a *500 steps* gombra.
+ A populáció létszáma 30 kör alatt nullára kell essen. A szimulációnak 30 körön belül terminálnia kell.

#todo("Add more manual tests")

#todo("Add seed control to the UI")

#todo("Implement helper utilities to aid testing")
