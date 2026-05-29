# Garmin Mini Me Watch Face

Connect IQ watch-face prototype for Mini Ido.

## Target Devices

- Forerunner 570 42mm: `fr57042mm`, 390 x 390, round AMOLED, API level 6.0.
- Forerunner 570 47mm: `fr57047mm`, 454 x 454, round AMOLED, API level 6.0.

## Current Prototype

- Dark AMOLED-friendly background.
- Large digital time.
- Date as day plus month.
- Current steps via `ActivityMonitor.getInfo().steps`.
- Placeholder weekly distance field.
- Placeholder Mini Ido below the time.
- Four placeholder visual states: neutral, proud, soft, sleepy.

## Build

Install the Garmin Connect IQ SDK and make sure `monkeyc` is on `PATH`, then run from this directory:

```sh
monkeyc -f monkey.jungle -o bin/GarminMiniMe.prg -y developer_key.der
```

The local workspace currently does not include the SDK command-line tools or a developer key.
