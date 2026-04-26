#!/bin/sh

# This script will generate all data tables
# used in the thesis document.
#
# Make sure you have NetLogo 6.4.0, fatint
# and the libfatint tests on your PATH.

set -e

run_fatint() {

	echo 'Running libfatint experiments'

	echo '  - Default settings'
	fatint \
		--output thesis/data/default-libfatint.csv

	echo '  - Sweeping P_encounter'
	fatint \
		-e 6 \
		--p_encounter 0.05 \
		--sweep_p_encounter 0.01 \
		--output thesis/data/p_encounter-libfatint.csv

	echo '  - Sweeping P_crossing'
	fatint \
		-e 6 \
		--p_crossing 0.0 \
		--sweep_p_crossing 0.1 \
		--output thesis/data/p_crossing-libfatint.csv

	echo '  - Sweeping P_mutation'
	fatint \
		-e 6 \
		--p_mutation 0.0 \
		--sweep_p_mutation 0.1 \
		--output thesis/data/p_mutation-libfatint.csv

	echo '  - Sweeping P_change'
	fatint \
		-e 11 \
		--p_change 0.0005 \
		--sweep_p_change 0.00005 \
		--output thesis/data/p_change-libfatint.csv

	echo '  - Sweeping M_limit'
	fatint \
		-e 21 \
		--p_change 0.0005 \
		--m_limit 0 \
		--sweep_m_limit 1 \
		--output thesis/data/m_limit-libfatint.csv

	echo '  - Sweeping V_stretch'
	fatint \
		-e 20 \
		--p_change 0.0005 \
		--v_stretch 1 \
		--sweep_v_stretch 1 \
		--output thesis/data/v_stretch-libfatint.csv

}

benchmark_fatint() {

	echo 'Benchmarking libfatint'

	echo '  - DFS, one species'
	TestSpeciesCounterPerformance \
		-q \
		-tc='*DepthFirstSearch one*' \
		> thesis/data/benchmark-species-counter-dfs-one-species-libfatint.csv

	echo '  - DFS, many species'
	TestSpeciesCounterPerformance \
		-q \
		-tc='*DepthFirstSearch many*' \
		> thesis/data/benchmark-species-counter-dfs-many-species-libfatint.csv

	echo '  - Disjoint-Sets, one species'
	TestSpeciesCounterPerformance \
		-q \
		-tc='*DisjointSets one*' \
		> thesis/data/benchmark-species-counter-ds-one-species-libfatint.csv

	echo '  - Disjoint-Sets, many species'
	TestSpeciesCounterPerformance \
		-q \
		-tc='*DisjointSets many*' \
		> thesis/data/benchmark-species-counter-ds-many-species-libfatint.csv

	echo '  - Simulator, without agent churn'
	TestSimulatorPerformance \
		-q \
		-tc='*- No churn*' \
		> thesis/data/benchmark-simulator-nochurn-libfatint.csv

	echo '  - Simulator, normal operation'
	TestSimulatorPerformance \
		-q \
		-tc='*- Churn*' \
		> thesis/data/benchmark-simulator-churn-libfatint.csv

}

run_netlogo() {

	echo 'Running NetLogo experiments'

	echo '  - Default settings'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'default-settings' \
		--table thesis/data/default-NetLogo.raw.csv \
		--stats thesis/data/default-NetLogo.csv

	echo '  - Sweeping P_encounter'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'sweep-p-encounter' \
		--table thesis/data/p_encounter-NetLogo.raw.csv \
		--stats thesis/data/p_encounter-NetLogo.csv

	echo '  - Sweeping P_crossing'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'sweep-p-crossing' \
		--table thesis/data/p_crossing-NetLogo.raw.csv \
		--stats thesis/data/p_crossing-NetLogo.csv

	echo '  - Sweeping P_mutation'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'sweep-p-mutation' \
		--table thesis/data/p_mutation-NetLogo.raw.csv \
		--stats thesis/data/p_mutation-NetLogo.csv

	echo '  - Sweeping P_change'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'sweep-p-change' \
		--table thesis/data/p_change-NetLogo.raw.csv \
		--stats thesis/data/p_change-NetLogo.csv

	echo '  - Sweeping M_limit'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'sweep-m-limit' \
		--table thesis/data/m_limit-NetLogo.raw.csv \
		--stats thesis/data/m_limit-NetLogo.csv

	echo '  - Sweeping V_stretch'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'sweep-v-stretch' \
		--table thesis/data/v_stretch-NetLogo.raw.csv \
		--stats thesis/data/v_stretch-NetLogo.csv

}

benchmark_netlogo() {

	echo 'Benchmarking NetLogo'

	echo '  - DFS, one species'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'benchmark-species-counter-dfs-one-species' \
		--table thesis/data/benchmark-species-counter-dfs-one-species-NetLogo.raw.csv \
		--stats thesis/data/benchmark-species-counter-dfs-one-species-NetLogo.csv \
		--threads 1

	echo '  - DFS, many species'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'benchmark-species-counter-dfs-many-species' \
		--table thesis/data/benchmark-species-counter-dfs-many-species-NetLogo.raw.csv \
		--stats thesis/data/benchmark-species-counter-dfs-many-species-NetLogo.csv \
        --threads 1

	echo '  - Disjoint-Sets, one species'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'benchmark-species-counter-ds-one-species' \
		--table thesis/data/benchmark-species-counter-ds-one-species-NetLogo.raw.csv \
		--stats thesis/data/benchmark-species-counter-ds-one-species-NetLogo.csv \
        --threads 1

	echo '  - Disjoint-Sets, many species'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'benchmark-species-counter-ds-many-species' \
		--table thesis/data/benchmark-species-counter-ds-many-species-NetLogo.raw.csv \
		--stats thesis/data/benchmark-species-counter-ds-many-species-NetLogo.csv \
		--threads 1

	echo '  - Simulator, without agent churn'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'benchmark-simulator-no-churn' \
		--table thesis/data/benchmark-simulator-nochurn-NetLogo.raw.csv \
		--stats thesis/data/benchmark-simulator-nochurn-NetLogo.csv \
		--threads 1

	echo '  - Simulator, normal operation'
	NetLogo_Console \
		--headless \
		--model fatint-netlogo/model.nlogo \
		--experiment 'benchmark-simulator-churn' \
		--table thesis/data/benchmark-simulator-churn-NetLogo.raw.csv \
		--stats thesis/data/benchmark-simulator-churn-NetLogo.csv \
		--threads 1

}

if [ $# -eq 0 -o "$1" = 'fatint' ]
then
    run_fatint
    benchmark_fatint
fi

if [ $# -eq 0 -o "$1" = 'netlogo' ]
then
    run_netlogo
    benchmark_netlogo
fi
