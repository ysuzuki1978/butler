# Echo Show 5 first-generation setup

This is the preparation record for converting a working Amazon Echo Show 5
first generation (2019, model H23K37, codename `checkers`) from stock Fire OS to
LineageOS 18.1. It deliberately separates read-only preparation from the step
that modifies the device.

Do not use packages or procedures labeled Echo Show 5 (2021), second
generation, or `cronos`. They target different hardware. Release numbers are
maintained separately for each device, so `cronos` v0.3 is not an older build
that can be installed on `checkers`.

## Host and cables

Keep the original Echo AC adapter connected for power. Connect the Micro-B data
port to the computer with a data-capable Micro-USB cable. A charging-only cable
will not work. UART hardware, an OTG adapter, and opening the device are not
needed for the normal unlock path on a working unit.

The current amonet v2.0.1 package supports Windows and Linux for the normal
unlock path. Its bundled Linux fastboot programs are x86-64 and i386 ELF
binaries, and its Windows program is an i386 PE executable. It does not contain
a macOS binary. The maintainer also states that Apple Silicon macOS is not a
supported host because the process needs the modified fastboot binary.

Use a physical Intel/AMD Windows or Linux computer when possible. A bootable
x86-64 Linux live USB is sufficient; Linux does not have to be installed on the
computer. An emulated x86-64 VM on Apple Silicon adds USB passthrough and timing
failure points and is a fallback rather than the preferred host.

For the Linux normal path, the package requires Bash, `unzip`, and the standard
`timeout` utility. For the recovery path that opens the device, the upstream
instructions also require Python 3, pyserial, ADB, fastboot, and ModemManager to
be stopped. That recovery path is not planned for this working device.

## Prepared artifacts

The binary files are stored under `.tools/device/`, which is ignored by Git.
Run `scripts/verify-checkers-assets.sh` after copying or downloading them.

| Purpose | File | SHA-256 | Provenance |
| --- | --- | --- | --- |
| Unlock and TWRP | `amonet-checkers-v2.0.1.zip` | `770324a8ed5ab922c0383f8ba072d70fc0190cc2c879f12f67b8d6cfa3ad30ee` | Locally recorded from the current XDA attachment; XDA does not publish a checksum |
| Proven baseline ROM | `lineage-18.1-20260624-UNOFFICIAL-checkers.zip` | `8a0c7f5daffe2b14b8f5e59219d2d8a1c04c534460e87459e2108b8d677db32f` | Published by the `amazon-oss/releases` v0.6 release |
| Evaluation ROM | `lineage-18.1-20260904-UNOFFICIAL-checkers.zip` | `785fa643fd68b2e6f6f02d96a2da58373c6a577b92a27cf6cec69603bb94068e` | Published by the `amazon-oss/releases` v0.7 release |

The LineageOS archive was downloaded from:

<https://github.com/amazon-oss/releases/releases/tag/lineage-18.1-checkers-v0.7>

The unlock archive and current instructions are at:

<https://xdaforums.com/t/unlock-root-twrp-unbrick-amazon-echo-show-5-1st-gen-2019-checkers.4762900/>

The ROM installation instructions are at:

<https://xdaforums.com/t/rom-unofficial-11-checkers-lineageos-18-1-for-the-amazon-echo-show-5-2019.4763475/>

## ROM selection status

Use LineageOS v0.6 for the first controlled boot and hardware baseline. A
detailed Japanese field report records a successful conversion in August 2026
from Fire OS 6.5.6.9 on a first-generation H23K37 `checkers`, using the exact
`lineage-18.1-20260624-UNOFFICIAL-checkers.zip` image. Other Japanese reports
from the same period describe smooth operation on first-generation hardware.
GitHub reports 3,031 downloads for the v0.6 image as of 2026-09-12.

The detailed report used amonet v1.1.6 and TWRP 3.2.3. Those are evidence for
the ROM, not the unlock package we should now use. The current unlock thread
requires users of this ROM to move to the latest exploit, so this procedure
keeps amonet v2.0.1 and its TWRP 3.7.0_9-0.

LineageOS v0.7 remains staged as the follow-up evaluation build. As of
2026-09-12 it has been public for seven days. GitHub reports 412 asset
downloads, and the XDA thread contains one explicit report of a successful
installation with the camera working. Those signals establish installability,
but they do not establish long-term stability.

The v0.7 changes are valuable for this project: camera support, a fix for audio
breaking after several days, and improved microphone quality and detection.
After v0.6 proves the unlock, display, touch, Wi-Fi, speaker, microphone, and
Butler installation path, update to v0.7 through TWRP and repeat the same tests.
This separates device bring-up from regressions introduced by the newer ROM.

There are unresolved concerns that must be tested on the physical device:

- The upstream ROM thread still labels the build experimental, uses permissive
  SELinux, disables deep sleep, and warns that microphones may be quiet.
- The `mt8163-common` audio effects configuration inherited by `checkers` still
  leaves AEC, noise suppression, and automatic gain control commented out. An
  open upstream report demonstrates the resulting lack of Android audio capture
  preprocessing on `cronos`. The same configuration is present for `checkers`,
  but the effect on Butler must be measured because Butler also uses WebRTC's
  audio pipeline.
- Community reports made before v0.7 mention intermittent touchscreen freezes,
  Wi-Fi disconnections, and boot trouble with an AUX cable connected. The v0.7
  changelog does not claim fixes for these cases, and there has not yet been
  enough post-release time to assess them.

Recheck the release thread and open audio issues immediately before flashing.
After installation, require repeated cold boots, stable Wi-Fi, an overnight
audio run, and near-field/far-field voice tests while the speaker is playing
before treating this ROM as the fork's supported device base.

## Read-only preflight

Do these checks on the Windows or x86-64 Linux host before authorizing any
write. On a working stock device, power it off, keep the AC adapter connected,
hold Volume Down + Volume Up + Mute until the fastboot screen appears, and only
then connect the Micro-USB data cable to the computer.

Extract `amonet-checkers-v2.0.1.zip`, open its `amonet` directory, and use the
bundled modified fastboot binary to record these values:

```sh
./bin/fastboot getvar product
./bin/fastboot getvar lk_build_desc
./bin/fastboot getvar unlock_status
```

Stop unless `product` is exactly `CHECKERS`. Record `lk_build_desc` in the local
work log but do not commit a serial number or other device identifier. The
v2.0.1 package currently contains a special payload for
`44072a3-20240709_170103` and a default payload for other builds; the script
selects between them after reading `lk_build_desc`.

The next action, running `fastbrick.bat` on Windows or `./fastbrick.sh` on
Linux and entering `YES`, starts the write operation. Do not enter `YES` during
preflight.

## Conversion sequence

1. Verify `CHECKERS`, the LK build, cable stability, AC power, and both archive
   hashes.
2. Run the current amonet normal path and enter `YES` only when ready for the
   uninterrupted unlock. The upstream guide warns that interruption after its
   ten-second grace period can permanently brick the device.
3. Confirm that the device reboots into the current TWRP 3.7.0_9-0 supplied by
   amonet v2.0.1.
4. Before wiping, preserve any needed Fire OS data. A raw storage backup from
   TWRP is useful for investigation, but its restoration is not considered a
   tested recovery procedure. Official stock Fire OS packages linked from the
   ROM thread are the documented rollback route.
5. Recheck the ROM selection status. Wipe data, system, and cache in TWRP, then
   flash the proven baseline
   `lineage-18.1-20260624-UNOFFICIAL-checkers.zip`.
6. Do not install MindTheGapps or another Google Apps package. This project is
   intentionally Google-free.
7. Reboot, complete the local Android setup, enable Developer options and USB
   debugging, then verify the target properties listed in `docs/FORK_PLAN.md`.
8. Install the debug APK with `adb install -r` and run the baseline device tests.
9. If the baseline passes, update to
   `lineage-18.1-20260904-UNOFFICIAL-checkers.zip` through TWRP without adding
   GApps, then repeat the device and voice tests before accepting v0.7.

Do not modify LK, Preloader, TEE, or other critical partitions outside the
published amonet updater. The current LineageOS build is experimental, runs
SELinux in permissive mode, disables deep sleep, and may have quieter microphone
input. Do not store sensitive data on it; microphone calibration must be part of
the Butler acceptance test.
