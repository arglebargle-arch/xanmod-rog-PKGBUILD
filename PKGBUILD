# Maintainer: Arglebargle < arglebargle at arglebargle dot dev>
# Contributor: Joan Figueras <ffigue at gmail dot com>
# Contributor: Torge Matthies <openglfreak at googlemail dot com>
# Contributor: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>
# Contributor: Yoshi2889 <rick.2889 at gmail dot com>
# Contributor: Tobias Powalowski <tpowa@archlinux.org>
# Contributor: Thomas Baechler <thomas@archlinux.org>

# shellcheck disable=SC2034,SC2164

##
## Xanmod-ROG options:
##
## Ultra Kernel Samepage Merging, enable this to perform fast in-use memory deduplication
## See: https://github.com/dolohow/uksm
##
##  build with 'env use_uksm=foo makepkg ...' to include UKSM patch
##
if [[ -v use_uksm ]]; then
  use_uksm=y
fi

##
## The following variables can be customized at build time. Use env or export to change at your wish
##
##   Example: env _microarchitecture=99 use_numa=n use_tracers=n use_pds=n makepkg -sc
##
## Look inside 'choose-gcc-optimization.sh' to choose your microarchitecture
## Valid numbers between: 0 to 99
## Default is: 0 => generic
## Good option if your package is for one machine: 98 (Intel native) or 99 (AMD native)
if [ -z ${_microarchitecture+x} ]; then
  _microarchitecture=93
fi

## Disable NUMA since most users do not have multiple processors. Breaks CUDA/NvEnc.
## Archlinux and Xanmod enable it by default.
## Set variable "use_numa" to: n to disable (possibly increase performance)
##                             y to enable  (stock default)
if [ -z ${use_numa+x} ]; then
  use_numa=y
fi

## For performance you can disable FUNCTION_TRACER/GRAPH_TRACER. Limits debugging and analyzing of the kernel.
## Stock Archlinux and Xanmod have this enabled.
## Set variable "use_tracers" to: n to disable (possibly increase performance)
##                                y to enable  (stock default)
if [ -z ${use_tracers+x} ]; then
  use_tracers=y
fi

## Choose between GCC and CLANG config (default is GCC)
if [ -z ${_compiler+x} ]; then
  _compiler=gcc
fi

# Compile ONLY used modules to VASTLY reduce the number of modules built
# and the build time.
#
# To keep track of which modules are needed for your specific system/hardware,
# give module_db script a try: https://aur.archlinux.org/packages/modprobed-db
# This PKGBUILD read the database kept if it exists
#
# More at this wiki page ---> https://wiki.archlinux.org/index.php/Modprobed-db
if [ -z "${_localmodcfg}" ]; then
  _localmodcfg=n
fi

# Tweak kernel options prior to a build via nconfig
_makenconfig=

### IMPORTANT: Do no edit below this line unless you know what you're doing

pkgbase=linux-xanmod-rog
xanmod=5.13.9-xanmod1
pkgver=${xanmod//-/.}
#pkgver=5.13.9rc1.xanpre0     # NOTE: start 4th position with 'xan...', we rely on parsing for '.xan...' later
pkgrel=1

pkgdesc='Linux Xanmod'
url="http://www.xanmod.org/"
arch=(x86_64)
license=(GPL2)
makedepends=(
  bc kmod libelf pahole cpio perl tar xz zstd
  "gcc>=11.0"
)
if [ "${_compiler}" = "clang" ]; then
  makedepends+=(clang llvm lld python)
fi
options=('!strip')
_major=$(echo $xanmod | cut -d'.' -f1,2)
_patchver=$(echo $pkgver | cut -d'.' -f3)
_branch="$(echo $xanmod | cut -d'.' -f1).x"
_localversion=$(echo $pkgver | cut -d'.' -f4)

source=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/linux-${_major}.tar."{xz,sign}
        "https://github.com/xanmod/linux/releases/download/${xanmod}/patch-${xanmod}.xz"
        "choose-gcc-optimization.sh"
        # The Arch Linux git repo has changed URLs, include this temporarily
        #"sphinx-workaround.patch"

        # ASUS ROG enablement
        "0101-asus-wmi-Add-panel-overdrive-functionality.patch"
        "0102-asus-wmi-Add-dgpu-disable-method.patch"
        "0103-asus-wmi-Add-egpu-enable-method.patch"
        "0006-HID-asus-Remove-check-for-same-LED-brightness-on-set.patch"
        "0007-ALSA-hda-realtek-Fix-speakers-not-working-on-Asus-Fl.patch"

        # ASUS Claymore II keyboard suspend fix
        "0001-HID-asus-prevent-Claymore-sending-suspend-event.patch"

        # fix Tiger Lake GPIO mapping so the touchpad works
        "0001-pinctrl-tigerlake-Fix-GPIO-mapping-for-newer-version-of-software.patch"

        # k10temp support for Zen3 APUs
        "8001-x86-amd_nb-Add-AMD-family-19h-model-50h-PCI-ids.patch"
        "8002-hwmon-k10temp-support-Zen3-APUs.patch"

        # mediatek mt7921 bt/wifi patches
        #"8010-Bluetooth-btusb-Fixed-too-many-in-token-issue-for-Me.patch"
        "8011-Bluetooth-btusb-Add-support-for-Lite-On-Mediatek-Chi.patch"
        #"8012-mt76-mt7921-continue-to-probe-driver-when-fw-already.patch"
        "8013-mt76-mt7921-Fix-out-of-order-process-by-invalid-even.patch"
        "8014-mt76-mt7921-Add-mt7922-support.patch"

        # squashed s0ix enablement through 2021-08-05
        "9001-v5.13.8-s0ix-patch-2021-08-05.patch"
        # a small amd_pmc SMU debugging patch per Mario Limonciello @AMD
        "9100-amd-pmc-smu-register-dump-for-diagnostics.patch"
        )
validpgpkeys=(
    'ABAF11C65A2970B130ABE3C479BE3E4300411886' # Linux Torvalds
    '647F28654894E3BD457199BE38DBBDC86092693E' # Greg Kroah-Hartman
)

# TODO: The Arch Linux git repo has moved to GitHub; find this URL at some point
# Archlinux patches
#_commit="be7d4710850020de55bce930c83fa80347c02fc3"
#_patches=("sphinx-workaround.patch")
#for _patch in "${_patches[@]}"; do
#    source+=("${_patch}::https://git.archlinux.org/svntogit/packages.git/plain/trunk/${_patch}?h=packages/linux&id=${_commit}")
#done

# apply UKSM patch
#
_uksm_patch="https://raw.githubusercontent.com/dolohow/uksm/master/v5.x/uksm-${_major}.patch"
[[ -v use_uksm ]] &&
  source+=("${_uksm_patch##*/}::${_uksm_patch}")

## Monkey patch: support stacking incremental point releases from kernel.org when we're building ahead of Xanmod
##
#if [[ ${xanmod%-xanmod?} != "${pkgver%%\.xan*}" ]]; then
#  _patch_start=$(echo ${xanmod%-xanmod?} | cut -d'.' -f3)
#  _patch_end=$(echo ${pkgver%%\.xan*} | cut -d'.' -f3)
#  for (( _i=_patch_start; _i < _patch_end; _i++ )); do
#    if (( _i == 0 )); then
#      source+=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/patch-${_major}.$((_i +1)).xz")
#    else
#      source+=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/incr/patch-${_major}.${_i}-$((_i +1)).xz")
#    fi
#  done
#fi

sha256sums=('3f6baa97f37518439f51df2e4f3d65a822ca5ff016aa8e60d2cc53b95a6c89d9'
            'SKIP'
            '20d15260a099a17ba389f6167daf77f4c29a2bef870654ae251b90eede02f89c'
            '1ac18cad2578df4a70f9346f7c6fccbb62f042a0ee0594817fdef9f2704904ee'
            '5f3c1c9e4efde73c78fd62314a9a566fbe1dc90b08f4451640e368ea3f37fe9c'
            '1ab75535772c63567384eb2ac74753e4d5db2f3317cb265aedf6151b9f18c6c2'
            '8cc771f37ee08ad5796e6db64f180c1415a5f6e03eb3045272dade30ca754b53'
            'f3461e7cc759fd4cef2ec5c4fa15b80fa6d37e16008db223f77ed88a65aa938e'
            '034743a640c26deca0a8276fa98634e7eac1328d50798a3454c4662cff97ccc9'
            '32bbcde83406810f41c9ed61206a7596eb43707a912ec9d870fd94f160d247c1'
            '3f9f81b77d0e856e52ce490be2fa2079730e8205f96a7d2d7c8b27b3b4f71a8a'
            'ea341c7914837b6672386bb54579672caf4b6c1ed1d07320e4fbb977f20ee033'
            'ed28a8051514f8c228717a5cdd13191b1c58181e0228d972fbe2af5ee1d013d7'
            'de8c9747637768c4356c06aa65c3f157c526aa420f21fdd5edd0ed06f720a62e'
            '67ebf477b2ecbf367ea3fee1568eeb3de59de7185ef5ed66b81ae73108f6693c'
            '2163cb2e394a013042a40cd3b00dae788603284b20d71e262995366c5534e480'
            'a01cf700d79b983807e2285be1b30df6e02db6adfd9c9027fe2dfa8ca5a74bc9'
            'd049328ee725216f904cbf21cbb3c1c34c2b1daadbb1dbc399cfab8db54a756b'
            '6e629d4a032165f39202a702ad518a050c9305f911595a43bc34ce0c1d45d36b')

export KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-archlinux}
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-"$pkgbase"}
export KBUILD_BUILD_TIMESTAMP=${KBUILD_BUILD_TIMESTAMP:-$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})}

# shellcheck disable=SC2154,SC2155
prepare() {
  cd "linux-${_major}"

  # Apply Xanmod patch
  msg2 "Applying Xanmod patch..."
  patch -Np1 -i "../patch-${xanmod}"

  # XXX: mangle Makefile versions here if needed so patches apply cleanly

  ## Monkey patch: apply kernel.org patches when mainline is slightly ahead of Xanmod official
  #if [[ ${xanmod%-xanmod?} != "${pkgver%%\.xan*}" ]]; then
  #  msg2 "Applying kernel.org point-release patches..."
  #  for (( _i=_patch_start; _i < _patch_end; _i++ )); do
  #    if (( _i == 0 )); then
  #      echo "Applying patch ${_major} -> ${_major}.$((_i+1))..."
  #      patch -Np1 -i "../patch-${_major}.$((_i+1))"
  #    else
  #      echo "Applying patch ${_major}.${_i} -> ${_major}.$((_i+1))..."
  #      patch -Np1 -i "../patch-${_major}.${_i}-$((_i+1))"
  #    fi
  #  done
  #fi

  # Archlinux patches
  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    [[ "$src" =~ .*(patch|diff)$ ]] || continue
    msg2 "Applying patch $src..."
    patch -Np1 < "../$src"
  done

  # XXX: mangle Makefile versions if needed before calling setlocalversion

  msg2 "Setting version..."
  scripts/setlocalversion --save-scmversion
  echo "-$pkgrel" > localversion.99-pkgrel
  echo "${pkgbase#linux-xanmod}" > localversion.20-pkgname

  # Monkey patch: rewrite Xanmod release to $_localversion (eg: xanpre0) if we're applying a point release on top of Xanmod
  [[ ${xanmod%-xanmod?} != "${pkgver%%\.xan*}" ]] &&
    sed -Ei "s/xanmod[0-9]+/${_localversion}/" localversion

  # Applying configuration
  cp -vf CONFIGS/xanmod/${_compiler}/config .config
  # enable LTO_CLANG_THIN
  if [ "${_compiler}" = "clang" ]; then
    scripts/config --disable LTO_CLANG_FULL
    scripts/config --enable LTO_CLANG_THIN
    _LLVM=1
  fi

  # User set. See at the top of this file
  if [ "$use_tracers" = "n" ]; then
    msg2 "Disabling FUNCTION_TRACER/GRAPH_TRACER only if we are not compiling with clang..."
    if [ "${_compiler}" = "gcc" ]; then
      scripts/config --disable CONFIG_FUNCTION_TRACER \
                     --disable CONFIG_STACK_TRACER
    fi
  fi

  if [ "$use_numa" = "n" ]; then
    msg2 "Disabling NUMA..."
    scripts/config --disable CONFIG_NUMA
  fi

  # This is intended for the people that want to build this package with their own config
  # Put the file "myconfig" at the package folder (this will take preference) or "${XDG_CONFIG_HOME}/linux-xanmod/myconfig"
  # If we detect partial file with scripts/config commands, we execute as a script
  # If not, it's a full config, will be replaced
  for _myconfig in "${startdir}/myconfig" "${HOME}/.config/linux-xanmod/myconfig" "${XDG_CONFIG_HOME}/linux-xanmod/myconfig" ; do
    # if file exists and size > 0 bytes
    if [ -s "${_myconfig}" ]; then
      if grep -q 'scripts/config' "${_myconfig}"; then
        # myconfig is a partial file. Executing as a script
        msg2 "Applying myconfig..."
        bash -x "${_myconfig}"
      else
        # myconfig is a full config file. Replacing default .config
        msg2 "Using user CUSTOM config..."
        cp -f "${_myconfig}" .config
      fi
      echo
      break
    fi
  done

  ### Optionally load needed modules for the make localmodconfig
  # See https://aur.archlinux.org/packages/modprobed-db
  if [ "$_localmodcfg" = "y" ]; then
    if [ -f "$HOME/.config/modprobed.db" ]; then
      msg2 "Running Steven Rostedt's make localmodconfig now"
      make LLVM=$_LLVM LLVM_IAS=$_LLVM LSMOD="$HOME/.config/modprobed.db" localmodconfig
    else
      msg2 "No modprobed.db data found"
      exit
    fi
  fi

  make LLVM=$_LLVM LLVM_IAS=$_LLVM olddefconfig

  # let user choose microarchitecture optimization in GCC;        NOTE: run *after* make olddefconfig so any new uarch macros exist
  sh "${srcdir}/choose-gcc-optimization.sh" $_microarchitecture

  make -s kernelrelease > version
  msg2 "Prepared %s version %s" "$pkgbase" "$(<version)"

  [[ -z "$_makenconfig" ]] || make LLVM=$_LLVM LLVM_IAS=$_LLVM nconfig

  # save configuration for later reuse or inspection
  cat .config > "${SRCDEST}/config.last"
}

build() {
  cd "linux-${_major}"
  make LLVM=$_LLVM LLVM_IAS=$_LLVM all
}

# shellcheck disable=SC2154,SC2155
_package() {
  pkgdesc="The Linux kernel and modules with Xanmod and ASUS ROG laptop patches (Zephyrus G14, G15, etc)"
  depends=(coreutils kmod initramfs)
  optdepends=('crda: to set the correct wireless channels of your country'
              'linux-firmware: firmware images needed for some devices')
  provides+=(linux-xanmod-g14)
  conflicts+=(linux-xanmod-g14)

  cd "linux-${_major}"
  local kernver="$(<version)"
  local modulesdir="$pkgdir/usr/lib/modules/$kernver"

  msg2 "Installing boot image..."
  # systemd expects to find the kernel here to allow hibernation
  # https://github.com/systemd/systemd/commit/edda44605f06a41fb86b7ab8128dcf99161d2344
  install -Dm644 "$(make -s image_name)" "$modulesdir/vmlinuz"

  # Used by mkinitcpio to name the kernel
  echo "$pkgbase" | install -Dm644 /dev/stdin "$modulesdir/pkgbase"

  msg2 "Installing modules..."
  make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 modules_install

  # remove build and source links
  rm "$modulesdir"/{source,build}
}

# shellcheck disable=SC2154,SC2155
_package-headers() {
  pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
  depends=(pahole)
  provides+=(linux-xanmod-g14-headers)
  conflicts+=(linux-xanmod-g14-headers)

  cd "linux-${_major}"
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  msg2 "Installing build files..."
  install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map \
    localversion.* version vmlinux
  install -Dt "$builddir/kernel" -m644 kernel/Makefile
  install -Dt "$builddir/arch/x86" -m644 arch/x86/Makefile
  cp -t "$builddir" -a scripts

  # add objtool for external module building and enabled VALIDATION_STACK option
  install -Dt "$builddir/tools/objtool" tools/objtool/objtool

  # add xfs and shmem for aufs building
  mkdir -p "$builddir"/{fs/xfs,mm}

  msg2 "Installing headers..."
  cp -t "$builddir" -a include
  cp -t "$builddir/arch/x86" -a arch/x86/include
  install -Dt "$builddir/arch/x86/kernel" -m644 arch/x86/kernel/asm-offsets.s

  install -Dt "$builddir/drivers/md" -m644 drivers/md/*.h
  install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h

  # http://bugs.archlinux.org/task/13146
  install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

  # http://bugs.archlinux.org/task/20402
  install -Dt "$builddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
  install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
  install -Dt "$builddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h

  msg2 "Installing KConfig files..."
  find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

  msg2 "Removing unneeded architectures..."
  local arch
  for arch in "$builddir"/arch/*/; do
    [[ $arch = */x86/ ]] && continue
    echo "Removing $(basename "$arch")"
    rm -r "$arch"
  done

  msg2 "Removing documentation..."
  rm -r "$builddir/Documentation"

  msg2 "Removing broken symlinks..."
  find -L "$builddir" -type l -printf 'Removing %P\n' -delete

  msg2 "Removing loose objects..."
  find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete

  msg2 "Stripping build tools..."
  local file
  while read -rd '' file; do
    case "$(file -bi "$file")" in
      application/x-sharedlib\;*)      # Libraries (.so)
        strip -v "$STRIP_SHARED" "$file" ;;
      application/x-archive\;*)        # Libraries (.a)
        strip -v "$STRIP_STATIC" "$file" ;;
      application/x-executable\;*)     # Binaries
        strip -v "$STRIP_BINARIES" "$file" ;;
      application/x-pie-executable\;*) # Relocatable binaries
        strip -v "$STRIP_SHARED" "$file" ;;
    esac
  done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

  msg2 "Stripping vmlinux..."
  strip -v "$STRIP_STATIC" "$builddir/vmlinux"
  msg2 "Adding symlink..."
  mkdir -p "$pkgdir/usr/src"
  ln -sr "$builddir" "$pkgdir/usr/src/$pkgbase"
}

pkgname=("${pkgbase}" "${pkgbase}-headers")
for _p in "${pkgname[@]}"; do
  eval "package_$_p() {
    $(declare -f "_package${_p#$pkgbase}")
    _package${_p#$pkgbase}
  }"
done

# vim:set ts=8 sts=2 sw=2 et:
