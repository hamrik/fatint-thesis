#import "../../lib/elteikthesis.typ": definition, todo

== Model description <model-desc>

=== Variables

The simulation consists of a population of genderless entities, each of which has the following properties:

/ Age: The number of simulation cycles the entity went through.
/ Energy: The current energy level of the entity. If not positive, the creature dies.
/ Genotype: A multidimensional vector of real values which is used to determine which entities this entity can mate with. The real values are referred to as _alleles_.

#todo[_Allele_ is the wrong term, replace with _Gene_]

The environment has the following properties:

/ Energy: The current energy supply of the world. If it runs out, the entities cannot replenish their own energy.
/ Allele count: Determines how many alleles every entity has in their genotype.

#definition[
  The most important emergent property of the model is the number of distinct *species* the entities can be grouped into.

  Members of the same species are genetically similar enough to reproduce with each other and no other entity. Every entity is the (possibly sole) member of exactly one species.

  If we imagine a graph where the nodes are entities, and edges are drawn between every genetically compatible pair, then each connected component is a species, and the number of connected components is the number is species.
]

These properties evolve over time. Various aspects of the model can be measured during simulation, such as population size, energy supply, or statistics of the entity ages.

There are also parameters that are set before the simulation starts and do not change while it runs.

=== Energy-related parameters

/ Global energy increase: The amount of energy added to the global supply before each cycle.
/ Energy consumption: The amount of energy each entity loses per cycle.
/ Energy intake: The amount of energy each entity attempts to take from the global energy supply. Note that the entity's own energy level will replenish by a smaller amount, see @energy-gain-formula.
/ Energy discount: The factor of energy waste each entity suffers during consumption, see @energy-gain-formula.

=== Reproduction-related parameters

/ Allele extrema: The minimum and maximum value of any allele of any entity.
/ Maximum dissimilarity: A pair of entities is considered genetically compatible if the euclidean distance of their genotypes is no greater than this amount. Also affects how many offspring they may have. See @offspring-count-formula.
/ Minimum offspring count: The minimum number of offspring produced as a result of a single pair of entities mating. See @offspring-count-formula.
/ Probability to encounter a mate: The chance that an entity will reproduce in the current cycle.

=== Genetic parameters

/ Crossover probability: determines the chance that each allele of an offspring is inherited from one parent or the other.
/ Mutation probability: determines the change that each allele of an offspring undergoes mutation.
/ Mutation amount: determines the maximum absolute difference between the original value of an allele and its mutated value.

=== Cycles

The simulation runs in cycles, where each cycle has the following steps:

+ The world energy supply is replenished in accordance with the global energy increase parameter.
+ Every entity attempts to gather energy from the world supply (in random order for fairness).
+ Every entity loses energy in accordance with the energy consumption parameter.
+ Entities that run out of energy are removed from the simulation.
+ Each of the remaining entities has a chance to mate in accordance with the encounter probability.
+ Each reproducing entity randomly selects a compatible mate an accordance with the maximum dissimilarity.
+ Compatible pairs then produce a number of offspring, the genotypes of which are inherited from the parents via crossover, then potentially mutated. Offsprings with alleles outside the allowed extrema are removed.
+ For each successful reproduction there is a probability of a new allele being introduced to every entity.

=== Formulas

The amount of energy each entity has changes according to the following formula:
$ E_"change" = E_"intake" dot (E_"discount") ^ "age" - E_"consumption" $ <energy-gain-formula>
where $"age"$ is the number is cycles the entity went through.

The amount of offspring a mating pair has is determined by the following formula:
$ "offspring count" = M_"const" + (M_"limit" - d) dot M_"slope" $ <offspring-count-formula>
where $d$ is the dissimilarity of the parent genotypes (their euclidean distance)

If the *Stretch Method* is used for introducing new alleles, those alleles are computed from the previous last allele of each entity according to the following formula:
$ "new allele" = V_"min" dot ( "last allele" dot V_"stretch" ) mod ( V_"max" - V_"min" + 1 ) $ <stretch-formula>
