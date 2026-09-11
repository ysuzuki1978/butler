# Fork foundation

This fork is being prepared for a repurposed Echo Show running LineageOS 18.1
(Android 11). It is installed directly over ADB and must not depend on Google
Play or Google Play services.

## Confirmed scope

- Keep the on-device wake phrase, Realtime voice conversation, web search,
  citations, clock, weather, and landscape UI as the initial base.
- Remove Home Assistant settings, tools, prompts, and client code before adding
  new tools. This device will not control home appliances.
- Prefer local Android APIs, ordinary HTTPS APIs, and an optional service on a
  computer on the home LAN. Avoid Firebase and Play Services dependencies.
- Keep user-controlled data inspectable and exportable. Markdown is the
  preferred interchange format for project notes.
- Require an on-screen review before any future tool writes files or changes an
  external service.

## Candidate first feature

The leading differentiated use case is a voice and screen interface for the
owner's projects and research: search project documents, inspect GitHub status,
show citations, and draft Markdown artifacts. The precise first integration is
still to be selected before implementation.

## Development connection

For Echo Show 5 first- or second-generation hardware, use a data-capable
Micro-USB cable between the Echo's Micro-B port and the development computer.
Keep the Echo powered by its normal AC adapter; the Micro-USB connection is for
data and is not the device's main power source. A USB-C-to-Micro-B data cable is
the simplest option for a USB-C Mac. A USB-A-to-Micro-B data cable plus a USB-C
adapter or hub also works.

After LineageOS USB debugging is enabled and the cable is connected:

```sh
adb devices -l
adb shell getprop ro.product.device
adb shell getprop ro.build.version.release
adb shell getprop ro.product.cpu.abi
adb shell wm size
```

Expected values are Android 11, `armeabi-v7a`, and a 960x480 display. The
product codename is expected to be `checkers` for Echo Show 5 (2019) or `cronos`
for Echo Show 5 (2021); verify it rather than assuming it.

Build and install the debug APK with:

```sh
./gradlew assembleDebug testDebugUnitTest
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

This application workflow does not require fastboot, TWRP, an OTG cable, or a
UART adapter. ROM installation and bootloader work are outside this fork's app
development procedure.
