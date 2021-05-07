# Maintainer: Arglebargle < arglebargle at arglebargle dot dev>
#  based on the work of Joan Figueras <ffigue at gmail dot com>
# Contributor: Torge Matthies <openglfreak at googlemail dot com>
# Contributor: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>
# Contributor: Yoshi2889 <rick.2889 at gmail dot com>
# Contributor: Tobias Powalowski <tpowa@archlinux.org>
# Contributor: Thomas Baechler <thomas@archlinux.org>

##
## The following variables can be customized at build time. Use env or export to change at your wish
##
##   Example: env _microarchitecture=99 use_numa=n use_tracers=n use_pds=n makepkg -sc
##
## Look inside 'choose-gcc-optimization.sh' to choose your microarchitecture
## Valid numbers between: 0 to 99
## Default is: 0 => generic
## Good option if your package is for one machine: 99 => native
if [ -z ${_microarchitecture+x} ]; then
  _microarchitecture=0
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
xanmod=5.12.1-xanmod2
pkgrel=0

pkgbase=linux-xanmod-rog
pkgver=${xanmod//-/+}
pkgdesc='Linux Xanmod'
url="http://www.xanmod.org/"
arch=(x86_64)

license=(GPL2)
makedepends=(
  xmlto kmod inetutils bc libelf cpio
)
options=('!strip')
_major=$(echo $xanmod | cut -d'.' -f1,2)
_branch=$(echo $xanmod | cut -d'.' -f1).x
_patch=$(echo ${xanmod%-xanmod?} | cut -d'.' -f3)

source=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/linux-${_major}.tar."{xz,sign}
        "https://github.com/xanmod/linux/releases/download/${xanmod}/patch-${xanmod}.xz"
        "choose-gcc-optimization.sh"
        "https://raw.githubusercontent.com/dolohow/uksm/master/v5.x/uksm-5.12.patch"
        "sys-kernel_arch-sources-g14_files-6010-acpi_unused.patch"::"https://aur.archlinux.org/cgit/aur.git/plain/sys-kernel_arch-sources-g14_files-6010-acpi_unused.patch?h=linux-g14&id=71e5fa9a8459b8e7a49ed5c0b7fc74ba680dfe29"
        )
validpgpkeys=(
    'ABAF11C65A2970B130ABE3C479BE3E4300411886' # Linux Torvalds
    '647F28654894E3BD457199BE38DBBDC86092693E' # Greg Kroah-Hartman
)

# Archlinux patches
_commit="be7d4710850020de55bce930c83fa80347c02fc3"
_patches=("sphinx-workaround.patch")
for _patch in ${_patches[@]}; do
    source+=("${_patch}::https://git.archlinux.org/svntogit/packages.git/plain/trunk/${_patch}?h=packages/linux&id=${_commit}")
done

sha256sums=('7d0df6f2bf2384d68d0bd8e1fe3e071d64364dcdc6002e7b5c87c92d48fac366'
            'SKIP'
            'e304fded229a9f3134fd20a96ae111ca9a68f0a872384511662bb36b83560d86'
            '51742dee57cd15bece152d6527f48af87cb7930f0f6a356d5282f778e7c35b39'
            '8b2e476ae108255ae5dc6da43cda57620021a8e68da0e3c568eb44afd3d3254a'
            'c384049787c8f0008accf9c4d053eb407b76242fe522e1aed1fe8a9c59f9d996'
            '52fc0fcd806f34e774e36570b2a739dbdf337f7ff679b1c1139bee54d03301eb')

export KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-archlinux}
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-makepkg}
export KBUILD_BUILD_TIMESTAMP=${KBUILD_BUILD_TIMESTAMP:-$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})}

prepare() {
  cd linux-${_major}

  # Apply Xanmod patch
  patch -Np1 -i ../patch-${xanmod}

  msg2 "Setting version..."
  scripts/setlocalversion --save-scmversion
  echo "-$pkgrel" > localversion.99-pkgrel
  echo "${pkgbase#linux-xanmod}" > localversion.20-pkgname

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

  # these patches are a moving target and Luke rebases his patch set often so instead of pulling from a commit in the repo
  # during package build (which may be gone by the time someone else builds this package) I pull the repo as a submodule and
  # store asus-linux/{*patch,kernel.spec} in tree under asus-linux-patch/

  # this will apply all enabled patches from the fedora-linux kernel.spec
  for src in $(awk -F ' ' '/^ApplyOptionalPatch.*patch$/{print $2}' ${startdir}/asus-linux-patches/kernel.spec \
    # | grep -Ev '\-(redhat|test)\.patch'
    # ^ this skips both redhat and test patches
    );
  do
    src="${src%%::*}"
    src="${src##*/}"
    # skip non-patch files
    [[ $src = *.patch ]] || continue
    # skip empty test patch
    [[ $src = "linux-kernel-test.patch" ]] && continue
    # fixup redhat patch version
    if [[ $src =~ "%{stableversion}-redhat.patch" ]]; then
      src=${src/\%\{stableversion\}/$_major}
      # skip redhat patch if we're chasing a kernel version asus-linux doesn't build yet
      [[ -f "${startdir}/asus-linux-patches/$src" ]] || continue
    fi
    echo "(asus-linux) Applying patch $src..."
    # TODO: this doesn't handle partially applied patches perfectly;
    # if a portion of the patch succeeds we'll proceed, but dump debug output.
    # this works for the one partially applied patch in this set (the redhat patch)
    # but could cause problems later for other half-applied patches so caveat programmator
    OUT="$(patch --forward -Np1 < "${startdir}/asus-linux-patches/$src")" || \
      ( echo "$OUT"; (echo "${OUT}" | grep "Skipping patch" -q;) || false;)
  done

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
  pkgdesc="The Linux kernel and modules with Xanmod and ASUS ROG laptop patches"
  depends=(coreutils kmod initramfs)
  optdepends=('crda: to set the correct wireless channels of your country'
              'linux-firmware: firmware images needed for some devices')

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
