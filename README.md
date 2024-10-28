# Evolutionary Technology: Replication of the FATINT System

In the paper [Evolutionary Technology and Phenotype Plasticity: The FATINT System](https://www.researchgate.net/publication/228353897_Evolutionary_Technology_and_Phenotype_Plasticity_The_FATINT_System), George Kampis and László Gulyás have introduced the FATINT system, an evolutionary technology which aims to support open evolution, i.e. an environment in which agents and populations can constantly evolve, growing ever more diverse and complex.

They define three key concepts of the system:
 - `species`, groups of agents which can no longer reproduce with other groups,
 - `niches`, an aspect of the environment a species can interact with, indirectly affecting its own and other species' evolution, and
 - `fat phenotypes`, a genotype which supports phenotype plasticity.

Phenotype plasticity is key in their research, as it allows the genotype to express phenotypes as a function of the environment.
They then ran various experiments to test the following two hypotheses:

 - _"An evolutionary engine with phenotype-based emergent species and without phenotype plasticity remains stable and non-productive of species."_
 - _"The introduction of phenotype changes in the above systems leads to a sustained production of new emergent species."_

In this thesis we will attempt to reimplement the FATINT system on the NetLogo platform, validate the experiments Kampis and Gulyás have conducted and determine if we can reach the same conclusions they have demonstrated.

