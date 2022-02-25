#!/bin/bash

if (( EUID != 0 )); then
  echo "This script must be run as root and is intended for use by systemd during suspend/resume."
  echo "To use place this script in /usr/lib/systemd/system-sleep/ and make it executable."
  echo "STB logs will be captured to /root/amd-stb-captures/ during suspend and resume."
  exit 1
  # TODO: put a note here about fedora and fixing selinux contexts so this script works
fi

if ! [[ -e /sys/kernel/debug/amd_pmc/stb_read ]]; then
  echo "${0##*/}: Can't find /sys/kernel/debug/amd_pmc/stb_read!"
  echo "${0##*/}: Verify that your kernel boot arguments include 'amd_pmc.enable_stb=1'"
  # I'm not sure if calling 'exit 1' here will cause problems during suspend
  exit
fi

capturedir="/root/amd-stb-captures"
timestamp="$(/usr/bin/date +%s)"
smustats=( $(find /sys/kernel/debug/amd_pmc/ -name stb_read -prune -o -type f -print) )

#echo "${0##*/}: event args are '$1' '$2'"

# bail out if we're going into any low-power mode other than "suspend"
#[[ "$2" != "suspend" ]] &&
#  exit 0

mkdir -p "$capturedir"

case "$1" in
  "pre")
    #echo "taking STB capture pre suspend at $(date)..." >/root/amd-stb-captures/capture.log
    cat /sys/kernel/debug/amd_pmc/stb_read >"${capturedir}/${timestamp}-pre.stb"
    /usr/bin/sync ${capturedir}/*
    ;;
  "post")
    #echo "taking STB capture post suspend at $(date)..." >>/root/amd-stb-captures/capture.log
    cat /sys/kernel/debug/amd_pmc/stb_read >"${capturedir}/${timestamp}-post.stb"
    tail -n+0 "${smustats[@]}" >"${capturedir}/${timestamp}-stats"
    /usr/bin/sync ${capturedir}/*
    ;;
esac

