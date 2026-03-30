#import "../../lib/elteikthesis.typ": todo

== C++ implementation

=== Specification

=== Architecture

=== Building from source

Buliding from source requires the following components:

- *CMake* version 3.11 or newer
- A *C++ compiler* with C++20 support (GCC 9 or newer, Clang Y or newer)
- Optional, highly recommended: Intel Thread Building Blocks

#todo("Check versions")

All other dependencies are vendored in.

To build the project, open a command line in the root of the project and run the following commands:

```bash
$ cmake -S . -B ./build -DCMAKE_BUILD_TYPE=Release
$ cmake --build build --parallel $(nproc)
```

The executable will be built to `./build/fatint`.

=== Running tests
