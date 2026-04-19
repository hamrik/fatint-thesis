#import "/lib/elteikthesis.typ": todo

== NetLogo implementáció

=== Specifikáció

#todo("Consider using a common specification with C++ impl right after model spec")

#todo("Specify the UI, create GIVEN-WHEN-THEN tables for common workflows")

#todo("Consider creating a usecase diagram?")

=== Tesztelés

A NetLogo 6 nem tartalmaz beépített tesztelési eszközözet, így ezt az implementációt kézzel kell tesztelni.

==== Populáció öregedése

+ Állítsuk $P_"encounter"$ értékét $0$-ra, minden mást hagyjunk alapértelmezett értéken.
+ Kattintsunk a *Setup*, majd a *500 steps* gombra.
+ A populáció létszáma 30 kör alatt nullára kell essen. A szimulációnak 30 körön belül terminálnia kell.

#todo("Add more manual tests")

#todo("Add seed control to the UI")

#todo("Implement helper utilities to aid testing")

#todo("Embed NetLogo BehaviorSpace results and compare to paper")
