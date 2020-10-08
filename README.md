[![Build Status](https://travis-ci.com/piggypiggy/fp256.svg?branch=master)](https://travis-ci.com/piggypiggy/fp256)

# introduction
fp256 is a simple and efficient library implemented in C and assembly for 256 bit integer arithmetic.  

It supports Windows, Linux and Macosx on x86_64 processor and can be compiled with MSVC, mingw-w64, gcc and clang.  
More platform and processor support will be added soon.

# implementation
* Use 4×64bit to represent 256 bit integer.

* Leveled api :  
low level api operates directly on integer array, most low level api are specific for 256 bit integer, there are also a few api for arbitrary length array.  
high level api operates on 256 bit integer.

* Most low level arithmetic are implemented in x64 assembly, including  `add`, `mul`, `u256 mul`, `div`, `shift`, `fmod`, `exgcd`, etc, they are very efficient and (maybe)well commented, see src/ll/x64.

* 

# compilation
    $ mkdir build
    $ cd build
    $ cmake ..
    $ make
    $ make test

### configuration
`-DCMAKE_BUILD_TYPE` : possible values are empty, Debug, Release, RelWithDebInfo and MinSizeRel, default is `Release`.  
`-DCMAKE_INSTALL_PREFIX` : where to install fp256 library, default is `/usr/local`.  
`-DBUILD_STATIC` : build static library, default is `ON`.   
`-DBUILD_SHARED` : build shared library, default is `ON`.   
`-DUSE_DEV_RANDOM` : use /dev/random to get random number, default is `OFF`(use /dev/urandom).  
`-DUSE_ASM` : use assembly code, default is `ON`. it can not be turned off since there is no C implementation to fall back yet.  

# TODO
* Division can be much more faster by replacing division with multiplication.
* Add prime test, modular exponential, square root related, etc.
* Add C implementation for low level arithmetic, fall back to C if assembly is not prefered.
* Add assembly implementation for other processors : arm64, mips64, etc.
* more tests.

# benchmark
Some of benchmark results are listed below. Run build/bench/bench to get more.
### AMD Ryzen 5 4600U, Ubuntu 20.04 LTS, gcc-9.3.0
arithmetic(256 bit)     |      cycles / op      |      op / s      |
------------------------|-----------------------|------------------|
naive div               |           428         |     4890000      |
gcd                     |          3784         |      554000      |
mod add                 |           330         |     6340000      |
mod sqr                 |           491         |     4260000      |
mod mul                 |           509         |     4110000      |
mod inv                 |          4628         |      453000      |

# license
Apache 2.0