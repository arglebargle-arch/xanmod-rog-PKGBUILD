# Maintainer: Arglebargle < arglebargle at arglebargle dot dev>
# Contributor: Joan Figueras <ffigue at gmail dot com>
# Contributor: Torge Matthies <openglfreak at googlemail dot com>
# Contributor: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>
# Contributor: Yoshi2889 <rick.2889 at gmail dot com>
# Contributor: Tobias Powalowski <tpowa@archlinux.org>
# Contributor: Thomas Baechler <thomas@archlinux.org>

##
## Ultra Kernel Samepage Merging, disabling this will increase memory consumption
## See: https://github.com/dolohow/uksm
##
##  build with 'env no_uksm=foo makepkg ...' to skip UKSM patch
##
if [[ -v no_uksm ]]; then
  no_uksm=y
fi

## Apply Redhat kernel patch
##
## Enable this to apply redhat/fedora kernel patch from asus-linux fedora kernel sources
## This is completely optional but mostly plays nicely in my experience.
##
#if [[ -v redhat_patch ]]; then
#  redhat_patch=y
#fi

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

# Compile ONLY used modules to VASTLY reduce the number of modules built
# and the build time.
#
# To keep track of which modules are needed for your specific system/hardware,
# give module_db script a try: https://aur.archlinux.org/packages/modprobed-db
# This PKGBUILD read the database kept if it exists
#
# More at this wiki page ---> https://wiki.archlinux.org/index.php/Modprobed-db
if [ -z ${_localmodcfg} ]; then
  _localmodcfg=n
fi

# Tweak kernel options prior to a build via nconfig
_makenconfig=

### IMPORTANT: Do no edit below this line unless you know what you're doing

#_major="5.11"
# curl -s "https://api.github.com/repos/xanmod/linux/releases" | jq -r '[.[] | select(.target_commitish == "$_major")][].tag_name' | sort -V | tail -n1

pkgbase=linux-xanmod-rog
xanmod=5.12.4-xanmod1
pkgver=${xanmod//-/+}
#pkgver=5.12.4+pre0
pkgrel=2

pkgdesc='Linux Xanmod'
url="http://www.xanmod.org/"
arch=(x86_64)
license=(GPL2)
makedepends=(
  xmlto kmod inetutils bc libelf cpio
  "gcc>=11.0"
)
options=('!strip')
_major=$(echo $xanmod | cut -d'.' -f1,2)
_patch=$(echo ${xanmod%-xanmod?} | cut -d'.' -f3)
_branch="$(echo $xanmod | cut -d'.' -f1).x"

_fedora_kernel_commit_id=29f433a6b9ba268b0202ac8200cf2ce38d6071b7
source=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/linux-${_major}.tar."{xz,sign}
        "https://github.com/xanmod/linux/releases/download/${xanmod}/patch-${xanmod}.xz"
        "choose-gcc-optimization.sh"
        "https://gitlab.com/asus-linux/fedora-kernel/-/archive/$_fedora_kernel_commit_id/fedora-kernel-$_fedora_kernel_commit_id.zip"
        "5.12-acpi-1of2-turn-off-unused.patch"::"https://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm.git/patch/?id=4b9ee772eaa82188b0eb8e05bdd1707c2a992004"
        "5.12-acpi-2of2-turn-off-unconditionally.patch"::"https://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm.git/patch/?id=7e4fdeafa61f2b653fcf9678f09935e55756aed2"
        "5.12.4--Add-jack-toggle-support-for-headphones-on-Asus-ROG-Z.patch"
        )
validpgpkeys=(
    'ABAF11C65A2970B130ABE3C479BE3E4300411886' # Linux Torvalds
    '647F28654894E3BD457199BE38DBBDC86092693E' # Greg Kroah-Hartman
)

# asus-linux patch management; any patch matching this list is pruned from the patchset during prepare()
# accepts filenames and bash globs, ** important: don't quote globs **
_fedora_kernel_patch_skip_list=(

  #00{03,05,08}-drm-amdgpu*.patch      # example multi-select
  #00{01..12}-drm-amdgpu*.patch        # example range select
  #patch-*-redhat.patch                # example wildcard match
  
  "linux-kernel-test.patch"           # test patch, please ignore
  patch-*-redhat.patch                # wildcard match any redhat patch version
  00{01..12}-drm-amdgpu*.patch        # upstreamed in 5.12

  # upstreamed
  "0001-HID-asus-Filter-keyboard-EC-for-old-ROG-keyboard.patch"
  "0001-ALSA-hda-realtek-GA503-use-same-quirks-as-GA401.patch"

  # patch broken in 5.12.4, updated patch included in package sources
  "0001-Add-jack-toggle-support-for-headphones-on-Asus-ROG-Z.patch"
)

# Archlinux patches
_commit="be7d4710850020de55bce930c83fa80347c02fc3"
_patches=("sphinx-workaround.patch")
for _patch in ${_patches[@]}; do
    source+=("${_patch}::https://git.archlinux.org/svntogit/packages.git/plain/trunk/${_patch}?h=packages/linux&id=${_commit}")
done

# apply UKSM patch
#
_uksm_patch="https://raw.githubusercontent.com/dolohow/uksm/master/v5.x/uksm-${_major}.patch"
#_uksm_patch="https://raw.githubusercontent.com/dolohow/uksm/master/v5.x/uksm-5.12.patch"
if [[ ! -v no_uksm ]]; then
  source+=("${_uksm_patch##*/}::${_uksm_patch}")
fi

# Support stacking incremental point releases from kernel.org when we're building ahead of Xanmod
#
if [[ ${xanmod%-xanmod?} != ${pkgver%+xanmod?} ]]; then
  _patch_start=$(echo ${xanmod%-xanmod?} | cut -d'.' -f3)
  _patch_end=$(echo ${pkgver%+xanmod?} | cut -d'.' -f3)
  for (( _i=_patch_start; _i < _patch_end; _i++ )); do
    source+=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/incr/patch-${_major}.${_i}-$((_i +1)).xz")
  done
fi

sha256sums=('7d0df6f2bf2384d68d0bd8e1fe3e071d64364dcdc6002e7b5c87c92d48fac366'
            'SKIP'
            '550c0791ec823628b94dd9220942510faef33f2e0912a3cc0d0833f3f16561a1'
            '1ac18cad2578df4a70f9346f7c6fccbb62f042a0ee0594817fdef9f2704904ee'
            'ce2a5e79ed29c701529f0aa2d854bab79d9f5cbdd173e13774f6e1f4e8ae585f'
            '5af4796400245fec2e84d6e3f847b8896600558aa85f5e9c4706dd50994a9802'
            '9cf7519ee1a0544f431c9fe57735aae7b9d150e62abed318837befc3b6af7c5f'
            '495dc8131b98f4c165107b8f6c1324022b27c9b4442aa1018f78c446f4221d28'
            '52fc0fcd806f34e774e36570b2a739dbdf337f7ff679b1c1139bee54d03301eb'
            '8b2e476ae108255ae5dc6da43cda57620021a8e68da0e3c568eb44afd3d3254a')

export KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-archlinux}
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-makepkg}
export KBUILD_BUILD_TIMESTAMP=${KBUILD_BUILD_TIMESTAMP:-$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})}

_fedora_patch_in_skip_list() {
  for p in "${_fedora_kernel_patch_skip_list[@]}"; do [[ "$1" == $p ]] && return 0; done
  return 1
}

prepare() {
  cd linux-${_major}

  # Apply Xanmod patch
  msg2 "Applying Xanmod patch..."
  patch -Np1 -i ../patch-${xanmod}

  # Apply kernel.org patches when mainline is slightly ahead of Xanmod
  if [[ ${xanmod%-xanmod?} != ${pkgver%+xanmod?} ]]; then
      msg2 "Applying kernel.org point-release patches..."
      for (( _i=_patch_start; _i < _patch_end; _i++ )); do
        echo "Applying patch ${_major}.${_i} -> ${_major}.$((_i+1))..."
        patch -Np1 -i ../patch-${_major}.${_i}-$((_i+1))
      done
  fi

  msg2 "Setting version..."
  scripts/setlocalversion --save-scmversion
  echo "-$pkgrel" > localversion.99-pkgrel
  echo "${pkgbase#linux-xanmod}" > localversion.20-pkgname

  # Rewrute xanmod release to 0 if we're pre-releasing
  [[ ${xanmod%-xanmod?} != ${pkgver%+xanmod?} ]] &&
    sed -Ei 's/xanmod[0-9]+/xanmod0/' localversion

  # Archlinux patches
  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    [[ $src = *.patch ]] || continue
    msg2 "Applying patch $src..."
    patch -Np1 < "../$src"
  done

  # ASUS-linux patches
  # --

  # these patches are a moving target and we're not guaranteed that Luke is building a fedora kernel for our kernel version yet.
  # we'll make a best effort at patching against our kernel sources and use _fkernel_skip_patches=() list above to filter any
  # patches that have already been upstreamed or are broken for us

  local p_err=()
  local p_meh=()
  local _fkernel_path="../fedora-kernel-${_fedora_kernel_commit_id}"
  msg2 "Applying asus-linux patches..."

  # this will apply all enabled patches from the fedora-linux kernel.spec
  for src in $(awk -F ' ' '/^ApplyOptionalPatch.*patch$/{print $2}' "${_fkernel_path}/kernel.spec"); do

    # skip patches in our skip list
    _fedora_patch_in_skip_list "$src" && continue

    # the redhat patch needs special handling
    if [[ "$src" == patch*-redhat.patch ]]; then
      src=${src/\%\{stableversion\}/$_major} ## fixup filename first
      if [[ ! -v redhat_patch ]]; then
        plain "Skipping optional redhat patch $src ..."
        continue
      fi
      if [[ ! -f "${_fkernel_path}/$src" ]]; then
        plain "Skipping redhat patch, no patch available for this kernel ..."
        continue
      fi
    fi

    echo "Applying patch $src..."
    if OUT="$(patch --forward -Np1 < "${_fkernel_path}/$src")"; then
      : #plain "Applied patch $src..."
    else
      # if you want to ignore a specific patch failure for some reason do it right here
      # then 'continue'
      if { echo "$OUT" | grep -qiE 'hunk(|s) FAILED'; }; then
        error "Patch failed $src" && echo "$OUT" && p_err+=("$src") && _throw=y
      else
        warning "Duplicate patch $src" && p_meh+=("$src")
      fi
    fi
  done

  (( ${#p_err[@]} > 0 )) && error "Failed patches:" && for p in ${p_err[@]}; do plain "$p"; done
  (( ${#p_meh[@]} > 0 )) && warning "Duplicate patches:" && for p in ${p_meh[@]}; do plain "$p"; done
  [[ -z "$_throw" ]]  # if throw is defined we had a hard patch failure, propagate it and stop so we can address
  # --

  # CONFIG_STACK_VALIDATION gives better stack traces. Also is enabled in all official kernel packages by Archlinux team
  scripts/config --enable CONFIG_STACK_VALIDATION

  # Enable IKCONFIG following Arch's philosophy
  scripts/config --enable CONFIG_IKCONFIG \
                 --enable CONFIG_IKCONFIG_PROC

  # User set. See at the top of this file
  if [ "$use_tracers" = "n" ]; then
    msg2 "Disabling FUNCTION_TRACER/GRAPH_TRACER..."
    scripts/config --disable CONFIG_FUNCTION_TRACER \
                   --disable CONFIG_STACK_TRACER
  fi

  if [ "$use_numa" = "n" ]; then
    msg2 "Disabling NUMA..."
    scripts/config --disable CONFIG_NUMA
  fi

  # Let's user choose microarchitecture optimization in GCC
  sh ${srcdir}/choose-gcc-optimization.sh $_microarchitecture

  # This is intended for the people that want to build this package with their own config
  # Put the file "myconfig" at the package folder (this will take preference) or "${XDG_CONFIG_HOME}/linux-xanmod/myconfig"
  # If we detect partial file with scripts/config commands, we execute as a script
  # If not, it's a full config, will be replaced
  for _myconfig in "${startdir}/myconfig" "${XDG_CONFIG_HOME}/linux-xanmod/myconfig" ; do
    if [ -f "${_myconfig}" ]; then
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
    fi
  done

  make olddefconfig

  ### Optionally load needed modules for the make localmodconfig
  # See https://aur.archlinux.org/packages/modprobed-db
  if [ "$_localmodcfg" = "y" ]; then
    if [ -f $HOME/.config/modprobed.db ]; then
      msg2 "Running Steven Rostedt's make localmodconfig now"
      make LSMOD=$HOME/.config/modprobed.db localmodconfig
    else
      msg2 "No modprobed.db data found"
      exit
    fi
  fi

  make -s kernelrelease > version
  msg2 "Prepared %s version %s" "$pkgbase" "$(<version)"

  [[ -z "$_makenconfig" ]] || make nconfig

  # save configuration for later reuse
  cat .config > "${SRCDEST}/config.last"
}

build() {
  cd linux-${_major}
  make all
}

_package() {
  pkgdesc="The Linux kernel and modules with Xanmod and ASUS ROG laptop patches (Zephyrus G14, G15, etc)"
  depends=(coreutils kmod initramfs)
  optdepends=('crda: to set the correct wireless channels of your country'
              'linux-firmware: firmware images needed for some devices')
  provides+=(linux-xanmod-g14)
  conflicts+=(linux-xanmod-g14)

  cd linux-${_major}
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

_package-headers() {
  pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
  depends=(pahole)
  provides+=(linux-xanmod-g14-headers)
  conflicts+=(linux-xanmod-g14-headers)

  cd linux-${_major}
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
        strip -v $STRIP_SHARED "$file" ;;
      application/x-archive\;*)        # Libraries (.a)
        strip -v $STRIP_STATIC "$file" ;;
      application/x-executable\;*)     # Binaries
        strip -v $STRIP_BINARIES "$file" ;;
      application/x-pie-executable\;*) # Relocatable binaries
        strip -v $STRIP_SHARED "$file" ;;
    esac
  done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

  msg2 "Stripping vmlinux..."
  strip -v $STRIP_STATIC "$builddir/vmlinux"
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
