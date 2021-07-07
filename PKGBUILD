# Maintainer: Arglebargle < arglebargle at arglebargle dot dev>
# Contributor: Joan Figueras <ffigue at gmail dot com>
# Contributor: Torge Matthies <openglfreak at googlemail dot com>
# Contributor: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>
# Contributor: Yoshi2889 <rick.2889 at gmail dot com>
# Contributor: Tobias Powalowski <tpowa@archlinux.org>
# Contributor: Thomas Baechler <thomas@archlinux.org>

# shellcheck disable=SC2034,SC2164

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
xanmod=5.13.1-xanmod1
pkgver=${xanmod//-/.}
#pkgver=5.13.1.xanpre0     # NOTE: start 4th position with 'xan...', we rely on parsing for '.xan...' later
pkgrel=1

pkgdesc='Linux Xanmod'
url="http://www.xanmod.org/"
arch=(x86_64)
license=(GPL2)
makedepends=(
  xmlto kmod inetutils bc libelf cpio
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

# use rog branch; we'll handle suspend patches
_fedora_kernel_commit_id=91f97d88231152006764d3c50cc52ddbb508529f

source=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/linux-${_major}.tar."{xz,sign}
        "https://github.com/xanmod/linux/releases/download/${xanmod}/patch-${xanmod}.xz"
        "choose-gcc-optimization.sh"
        # temporarily (permanently?) disable pulling from asus-linux git
        #"https://gitlab.com/asus-linux/fedora-kernel/-/archive/$_fedora_kernel_commit_id/fedora-kernel-$_fedora_kernel_commit_id.zip"

        # pull this in from Arch;                                     XXX: <-- this is causing build failures, I'm not sure why yet
        #"ZEN-disallow-unprivileged-CLONE_NEWUSER.patch"

        # The Arch Linux git repo has changed URLs, include this temporarily
        # NOTE: we're not even building the documentation, it's probably safe to just drop this entirely
        #"sphinx-workaround.patch"

        # squash our 10 patch s0ix series that's in next; the d3hot quirk is the only thing not going into 5.14
        "backport-from-5.14-s0ix-enablement-no-d3hot.diff"
        "PCI-quirks-Quirk-PCI-d3hot-delay-for-AMD-xhci.patch"
        # recently added 11th patch, also scheduled for 5.14
        "ACPI-PM-Only-mark-EC-GPE-for-wakeup-on-Intel-systems.patch"
        # v5 of the platform-x86 amd-pmc diagnostics patch sequence from lkml patchwork
        "v5-platform-x86-amd-pmc-s0ix+smu-counters.diff"

        # for now let's just pull the 5 asus-linux patches we need directly and skip all of the git filtering
        "0001-asus-wmi-Add-panel-overdrive-functionality.patch"
        "0002-asus-wmi-Add-dgpu-disable-method.patch"
        "0003-asus-wmi-Add-egpu-enable-method.patch"
        "0006-HID-asus-Remove-check-for-same-LED-brightness-on-set.patch"
        "0007-ALSA-hda-realtek-Fix-speakers-not-working-on-Asus-Fl.patch"
        )
validpgpkeys=(
    'ABAF11C65A2970B130ABE3C479BE3E4300411886' # Linux Torvalds
    '647F28654894E3BD457199BE38DBBDC86092693E' # Greg Kroah-Hartman
)

# asus-linux patch management; any patch matching this list is pruned from the patchset during prepare()
# accepts filenames and bash globs, ** important: don't quote globs **
_fedora_kernel_patch_skip_list=(

  # 00{03,05,08}-drm-amdgpu*.patch      # example multi-select
  # 00{01..12}-drm-amdgpu*.patch        # example range select
  "linux-kernel-test.patch"             # test patch, please ignore
  patch-*-redhat.patch                  # wildcard match any redhat patch version

  # upstreamed
  "0001-HID-asus-Filter-keyboard-EC-for-old-ROG-keyboard.patch"
  "0001-ALSA-hda-realtek-GA503-use-same-quirks-as-GA401.patch"
  "0001-Add-jack-toggle-support-for-headphones-on-Asus-ROG-Z.patch"
  "0001-HID-asus-filter-G713-G733-key-event-to-prevent-shutd.patch"
  "0001-ACPI-video-use-native-backlight-for-GA401-GA502-GA50.patch"
  "0002-Revert-platform-x86-asus-nb-wmi-Drop-duplicate-DMI-q.patch"
  "0003-Revert-platform-x86-asus-nb-wmi-add-support-for-ASUS.patch"

  # filter out suspend patches, we'll use upstream directly
  "0001-ACPI-processor-idle-Fix-up-C-state-latency-if-not-ordered.patch"
  "0002-v5-usb-pci-quirks-disable-D3cold-on-xhci-suspend-for-s2idle-on-AMD-Renoir.diff"
  "0003-PCI-quirks-Quirk-PCI-d3hot-delay-for-AMD-xhci.diff"
  "0004-nvme-pci_look_for_StorageD3Enable_on_companion_ACPI_device_instead.patch"
  "0005-v5-1-2-acpi-PM-Move-check-for-_DSD-StorageD3Enable-property-to-acpi.diff"
  "0006-v5-2-2-acpi-PM-Add-quirks-for-AMD-Renoir-Lucienne-CPUs-to-force-the-D3-hint.diff"
  "0007-ACPI_PM_s2idle_Add_missing_LPS0_functions_for_AMD.patch"
  "0008-2-2-V2-platform-x86-force-LPS0-functions-for-AMD.diff"

  # filter suspend patches from 'rog' branch
  "0002-drm-amdgpu-drop-extraneous-hw_status-update.patch"
  "0013-ACPI-idle-override-and-update-c-state-latency-when-n.patch"
  "0014-usb-pci-quirks-disable-D3cold-on-AMD-xhci-suspend-fo.patch"
  "0015-PCI-quirks-Quirk-PCI-d3hot-delay-for-AMD-xhci.patch"
  "0016-nvme-put-some-AMD-PCIE-downstream-NVME-device-to-sim.patch"
  "0017-platform-x86-Add-missing-LPS0-functions-for-AMD.patch"
  "0018-platform-x86-force-LPS0-functions-for-AMD.patch"
)

# TODO: The Arch Linux git repo has moved to GitHub; find this URL at some point
# NOTE: We aren't even building the documentation; do we actually need this?
# Archlinux patches
#_commit="be7d4710850020de55bce930c83fa80347c02fc3"
#_patches=("sphinx-workaround.patch")
#for _patch in "${_patches[@]}"; do
#    source+=("${_patch}::https://git.archlinux.org/svntogit/packages.git/plain/trunk/${_patch}?h=packages/linux&id=${_commit}")
#done

# apply UKSM patch
#
_uksm_patch="https://raw.githubusercontent.com/dolohow/uksm/master/v5.x/uksm-${_major}.patch"
[[ -v no_uksm ]] ||
  source+=("${_uksm_patch##*/}::${_uksm_patch}")

# Monkey patch: support stacking incremental point releases from kernel.org when we're building ahead of Xanmod
#
if [[ ${xanmod%-xanmod?} != "${pkgver%%\.xan*}" ]]; then
  _patch_start=$(echo ${xanmod%-xanmod?} | cut -d'.' -f3)
  _patch_end=$(echo ${pkgver%%\.xan*} | cut -d'.' -f3)
  for (( _i=_patch_start; _i < _patch_end; _i++ )); do
    if (( _i == 0 )); then
      source+=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/patch-${_major}.$((_i +1)).xz")
    else
      source+=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/incr/patch-${_major}.${_i}-$((_i +1)).xz")
    fi
  done
fi

sha256sums=('3f6baa97f37518439f51df2e4f3d65a822ca5ff016aa8e60d2cc53b95a6c89d9'
            'SKIP'
            'b0f14a0ccc290a97457a301c9d2a2d8e4c02ed8d2292333476dbe488b443de35'
            '1ac18cad2578df4a70f9346f7c6fccbb62f042a0ee0594817fdef9f2704904ee'
            'e4cbedbcf939961af425135bb208266c726178c4017309719341f8c37f65c273'
            'dab4db308ede1aa35166f31671572eeccf0e7637b3218ce3ae519c2705934f79'
            '30c3ebf86e6b70ca9e35b5b9bcf39a3b3d14cb9ca18b261016b7d02ed37a0c4b'
            'b108959c4a53d771eb2d860a7d52b4a6701e0af9405bef325905c0e273b4d4fe'
            '09cf9fa947e58aacf25ff5c36854b82d97ad8bda166a7e00d0f3f4df7f60a695'
            '7a685e2e2889af744618a95ef49593463cd7e12ae323f964476ee9564c208b77'
            '663b664f4a138ccca6c4edcefde6a045b79a629d3b721bfa7b9cc115f704456e'
            '034743a640c26deca0a8276fa98634e7eac1328d50798a3454c4662cff97ccc9'
            '32bbcde83406810f41c9ed61206a7596eb43707a912ec9d870fd94f160d247c1'
            'd38e2ee1f43bd6ca18845c80f5e68c0e597db01780004ff47607dd605e9aa086')

export KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-archlinux}
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-makepkg}
export KBUILD_BUILD_TIMESTAMP=${KBUILD_BUILD_TIMESTAMP:-$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})}

_fedora_patch_in_skip_list() {
  for p in "${_fedora_kernel_patch_skip_list[@]}"; do [[ "$1" == "$p" ]] && return 0; done
  return 1
}

# shellcheck disable=SC2154,SC2155
prepare() {
  cd "linux-${_major}"

  # Apply Xanmod patch
  msg2 "Applying Xanmod patch..."
  patch -Np1 -i "../patch-${xanmod}"

  # Monkey patch: apply kernel.org patches when mainline is slightly ahead of Xanmod official
  if [[ ${xanmod%-xanmod?} != "${pkgver%%\.xan*}" ]]; then
    msg2 "Applying kernel.org point-release patches..."
    for (( _i=_patch_start; _i < _patch_end; _i++ )); do
      if (( _i == 0 )); then
        echo "Applying patch ${_major} -> ${_major}.$((_i+1))..."
        patch -Np1 -i "../patch-${_major}.$((_i+1))"
      else
        echo "Applying patch ${_major}.${_i} -> ${_major}.$((_i+1))..."
        patch -Np1 -i "../patch-${_major}.${_i}-$((_i+1))"
      fi
    done
  fi

  msg2 "Setting version..."
  scripts/setlocalversion --save-scmversion
  echo "-$pkgrel" > localversion.99-pkgrel
  echo "${pkgbase#linux-xanmod}" > localversion.20-pkgname

  # Monkey patch: rewrite Xanmod release to $_localversion if we're pre-releasing
  [[ ${xanmod%-xanmod?} != "${pkgver%%\.xan*}" ]] &&
    sed -Ei "s/xanmod[0-9]+/${_localversion}/" localversion

  # Archlinux patches
  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    [[ "$src" =~ .*(patch|diff)$ ]] || continue
    msg2 "Applying patch $src..."
    patch -Np1 < "../$src"
  done

  # XXX: temporarily skip all of this and just apply the 5 patches directly
  ## ASUS-linux patches
  ## --

  ## these patches are a moving target and we're not guaranteed that Luke is building a fedora kernel for our kernel version yet.
  ## we'll make a best effort at patching against our kernel sources and use _fkernel_skip_patches=() list above to filter any
  ## patches that have already been upstreamed or are broken for us

  #local p_err=()
  #local p_meh=()
  #local _fkernel_path="../fedora-kernel-${_fedora_kernel_commit_id}"
  #msg2 "Applying asus-linux patches..."

  ## this will apply all enabled patches from the fedora-linux kernel.spec
  #for src in $(awk -F ' ' '/^ApplyOptionalPatch.*(patch|diff)$/{print $2}' "${_fkernel_path}/kernel.spec"); do

  #  # skip patches in our skip list
  #  _fedora_patch_in_skip_list "$src" && continue

  #  # the redhat patch needs special handling
  #  if [[ "$src" == patch*-redhat.patch ]]; then
  #    src=${src/\%\{stableversion\}/$_major} ## fixup filename first
  #    if [[ ! -v redhat_patch ]]; then
  #      plain "Skipping optional redhat patch $src ..."
  #      continue
  #    fi
  #    if [[ ! -f "${_fkernel_path}/$src" ]]; then
  #      plain "Skipping redhat patch, no patch available for this kernel ..."
  #      continue
  #    fi
  #  fi

  #  echo "Applying patch $src..."
  #  if OUT="$(patch --forward -Np1 < "${_fkernel_path}/$src")"; then
  #    : #plain "Applied patch $src..."
  #  else
  #    # if you want to ignore a specific patch failure for some reason do it right here
  #    # then 'continue'
  #    if { echo "$OUT" | grep -qiE 'hunk(|s) FAILED'; }; then
  #      error "Patch failed $src" && echo "$OUT" && p_err+=("$src") && _throw=y
  #    else
  #      warning "Duplicate patch $src" && p_meh+=("$src")
  #    fi
  #  fi
  #done

  #(( ${#p_err[@]} > 0 )) && error "Failed patches:" && for p in "${p_err[@]}"; do plain "$p"; done
  #(( ${#p_meh[@]} > 0 )) && warning "Duplicate patches:" && for p in "${p_meh[@]}"; do plain "$p"; done
  #[[ -z "$_throw" ]]  # if throw is defined we had a hard patch failure, propagate it and stop so we can address
  ## --

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
