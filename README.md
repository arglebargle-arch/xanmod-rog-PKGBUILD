
Notes:

  - Added Flow x13 audio patch in 5.12.8
  - Added support for new GCC-11 microarchitecture feature targets, see [`choose-gcc-optimization.sh`](choose-gcc-optimization.sh) or [`PKGBUILD`](PKGBUILD) for details.
  - Builds now default to the `x86-64-v3` target; this builds for Haswell era and newer CPUs and should be ~10% more performant than a generic `x86_64` while maintaining wide compatibility.
  - Package now requires GCC >= 11 to support the new default build target. You can edit this out of the PKGBUILD if you're building for some other architecture target, this is really just to prevent confusion if someone tries to build with GCC 10.
  - Consider adding `cpufreq.default_governor=schedutil` to your boot command line for this kernel, by default Xanmod builds with the performance governor as the default. This is great for performance but doesn't clock down as readily. I suggest making a couple of bash aliases to make switching modes/governors easier and boost performance or save battery power as needed.

    * `alias goboost='set -x; asusctl profile boost; sudo cpupower frequency-set -g performance; set +x'`
    * `alias gonormal='set -x; asusctl profile normal; sudo cpupower frequency-set -g schedutil; set +x'`
    * `alias gosilent='set -x; asusctl profile silent; sudo cpupower frequency-set -g schedutil; set +x'`

  - Suggested architecture build targets:

    * `_microarchitecture=14 makepkg ...` Zen2 optimization
    * `_microarchitecture=15 makepkg ...` Zen3 optimization
    * `_microarchitecture=38 makepkg ...` Skylake optimization
    * `_microarchitecture=92 makepkg ...` x86-64-v2 for compatibility with older (2008 era) machines
    * `_microarchitecture=93 makepkg ...` x86-64-v3 (this is the default)
    * `_microarchitecture=98 makepkg ...` Intel -march=native
    * `_microarchitecture=99 makepkg ...` AMD -march=native 

    * NOTE: I'm not sure what Comet Lake laptops should target, Gentoo says [Skylake](https://wiki.gentoo.org/wiki/Safe_CFLAGS#Skylake.2C_Kaby_Lake.2C_Kaby_Lake_R.2C_Coffee_Lake.2C_Comet_Lake)

  - UKSM can be disabled by building with `no_uksm=y makepkg ...` to reduce CPU usage by a small amount. I suggest leaving it enabled, when it works well it does a great job of deduping in-use memory.
