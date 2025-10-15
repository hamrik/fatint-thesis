# Building

## NETLOGO implementation

You will need:
- NetLogo v6.4 or newer

1. Install and open NetLogo
2. In the menubar, click `File` then select `Open`
3. Browse to the repository directory, select `model.nlogo` and click `Open`

## C++ implementation

You will need:
- CMake 3.10 or newer
- A C++17 compatible compiler, such as `icpx`, `gcc`, `clang` or `msvc`
- (Optional, strongly recommended) Intel oneTBB (Threading Building Blocks), available as `libtbb` on most linux distroy or as part of the Intel oneAPI 2025.01 base toolkit.
- (For debug builds) AddressSanitizer

1. If Intel oneAPI is installed, set up the environment by sourcing the `setvars` script in its installation directory:

```
$ source /opt/intel/oneapi/setvars.sh
```

2. Configure project using CMake

```
$ cmake -B build
```

Intel oneAPI will be automatically detected if it has been set up in step 1.

3. Compile the simulation tool

```
$ cmake --build Build --configure Release -j8
```

Ideally you should set `-j` to the number of processor threads available on your system.

The binary will be available in the `build` directory.

Running it without any arguments will run the simulation 10 times with default parameters, then print the result in CSV format to STDOUT.

To see how to configure the parameters, the number of runs or the random number seed, run with `--help`:

```
$ ./build/fatint --help
```

For details, see `README.md`

## Jupyter notebook

You will need:
- Python 3.10 or newer
- Jupyter or JupyterLab

1. Create a virtual environment for the dependencies

```
$ python -m venv .venv
```

2. Activate the environtment

```
$ source .venv/bin/activate
```

3. If using Intel oneTBB, add it to the environment

```
$ source /opt/intel/oneapi/setvars.sh
```

4. Install dependencies

```
$ python -m pip install -r requirements.txt
```

5. Launch `jupyter` or `jupyter-lab` from within the `notebooks` directory

```
$ cd notebooks && jupyter-lab
```

6. Click the link printed to the console. The jupyter interface should open.

7. Open the `fatint.ipynb` file from the side panel.

8. To regenerate the graphs, click the fast-forward (⏩) button in the toolbar and confirm the warning.

9. The notebook will skip running the simulation if an output was previously generated.
   This can be useful if only the graphs need to be adjusted.

10. To force the simulation move or delete the CSV files in the `output` directory.
    Make sure to have a C++ build configured.
