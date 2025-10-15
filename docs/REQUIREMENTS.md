# Functional and non-functional requirements

## Functional requirements

The primary aim of this project is to reimplement the FATINT model and verify its findings by performing simulations with the same parameters as the original paper.

### The model

The model simulates genderless entities which consume resources from a shared pool, reproduce with other entities, and exhibit aging. Each entity has an energy level, an age to limit energy intake, and a genotype which is used to determine whether two entites are biologically compatible. The allele count of these genotypes may change during the course of the simulation. Offspring inherit genetic information from their parents. The parameters of the model govern how the shared resource pool and the entities behave, how genotypes are combined during reproduction as well as when and how alleles are added to the genotypes of entities.

A gene is represented as a vector of integers. The length of the vector is the allele count.

The parameters of the model are the following:
- The initial population size
- The initial allele count
- $p_{encounter}$ The probability that an entity attempts to reproduce per time step
- $p_{change}$ The probability that a successful reproduction attempt increases the allele count
- $p_{crossing}$ The probability of gene crossover during reproduction
- $p_{mutation}$ The probability of gene mutation during reproduction
- $v_{min}$, $v_{max}$ The range of allowed gene values (inclusive)
- $v_{mutation}$ The range of possible allele value shifts (in any direction) during mutation
- $v_{stretch}$ The stretch factor when introducing a new allele
- $m_{const}$, $m_{limit}$ The minimum and maximum number of offspring resulting from any given reproduction
- $m_{slope}$ Determines how genetic similarity affects offspring count
- $e_{increase}$ The amount of resources added to the resource pool after every time step
- $e_{consumption}$ The amount of energy each entity loses per time step
- $e_{intake}$ The amount of energy each entity removes from the resource pool per time step
- $e_{discount}$ Determines how aging affects energy gain of the entity

At each time step, every entity attempts to increase its energy level according to the following formula:

$$e_{gained} = e_{intake} - e_{discount} ^ age$$

If the shared resource pool is depleted the entity gains no energy. Every entity loses a fixed amount of energy at every time step. Entities that run out of energy are removed from the simulation.

The remaining entities have a probability to find a mate and reproduce. Each pair of entities that reproduce have a number of offspring determined by the following formula:

$$offspring_count = m_{const} - ( m_{limit} - d ) \cdot m_{slope}$$

where $d$ is the genetic similarity expressed as the eucledian distance of the parents' genotype vectors. $d$ must be less than $m_{limit}$ for two entites to be considered biologically compatible.

After every successful reproduction there is a probability that a new allele must be introduced. There are two possible methods to do so:

1. Append a random gene between $v_{min}$ and $v_{max}$ to every genotype
2. Use the following _"stretch method"_ formula:
   $$v_{new} = v_{min} + (v_{last} \cdot v_{stretch}) mod (v_{max} - v_{min} + 1)$$
   where $v_{last}$ is the value of the last allele of the current genotype.

The simulation continues until either no entities remain or a set number of maximum steps is reached.

### Measurement

The primary measurement of every experiment is the number of _"species"_ the entities make up at any given time step, and the trend of this count as the simulation progresses. Each species is a connected component of graph $G$ where the nodes are the entites and the edges connect biologically compatible entities.

### Outputs

Given a set of starting parameters the system must run the simulation multiple times and measure the number of species at every time step. Then it must output a file and optionally a chart showing how the number of species evolved as the simulation progressed. Most experiments run multiple simulations with the same parameters, in which case the minimum, maximum and average measurements must be recoreded.

### Model characteristics

**TODO**
Some high level characteristics of the model:

| GIVEN | WHEN | THEN |
|-------|------|------|
| Default starting parameters | $p_{encounter}$ increases | The rate of species count decline slows |
| Default starting parameters | $p_{crossing}$ increases | The number of species spikes more often |
| Default starting parameters | $v_{stretch} increases | The number of species maintains a higher average |

### The interface

The interface must be easy to use to allow to user to perform experiments and verify properties of the model.

The produced results must be easy to read and to draw conclusions from.

## Non-functional requirements

The model must precisely match the one described in the FATINT paper and the source code must make the model easily verifiable.

The simulation must be efficient enough to complete in a timely manner when performing multiple runs comprising of many steps.

The documentation must be thorough enough to allow users to perform experiments and interpret the results.
