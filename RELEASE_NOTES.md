# Garmin Mini Me Release Notes

This document records user-visible behavior, visual changes, and verification
notes as the watch-face prototype evolves. Update it after each implementation
change, alongside `NEXT_STEPS.md` when checklist items move.

## Unreleased

### Good Morning Mood

- Added a Good Morning mood background with Mini Ido holding coffee in a soft
  sunrise trail scene.
- Added the active palette-reduced `454x454` Good Morning background to the
  watch-face resource bundle.
- Reduced the active Good Morning background from 64 colors to 32 colors to
  trim the resource payload while keeping the artwork readable.
- Updated the mood schedule:
  - `06:00` through `10:29`: Good Morning, including days with a detected
    workout.
  - `10:30` through `20:59`: Happy by default, Proud after a workout is
    detected for the current local day.
  - `21:00` through `05:59`: Sleepy.
- Kept the Step Celebration proud reaction for daytime after the morning window.
- Added a cached same-day recorded-workout check using Garmin activity history,
  so workout detection does not scan history on every partial update.
- Uses black text with a white shadow on the pale Good Morning background for
  readability.
- Draws the first startup frame with the lightweight mood fallback background
  before loading the large mood bitmap, reducing black-screen time after reloads.
- Caches the active mood bitmap resource but repaints the bitmap on full face
  draws, so physical watches do not show text over a missing retained
  background.
- Invalidates only the drawn-background marker on wake, so the cached bitmap can
  redraw after sleep without showing the lightweight fallback frame.

### Step Goal Mark

Implemented the Step Goal Mark replacement for the old step-goal sign:

- Removed the separate `STEP GOAL` sign treatment from the watch face.
- Kept the short proud Mini Ido reaction when the step goal is reached.
- Added a sticky Step Goal Mark as a tiny static `24x24` gold PNG star attached
  immediately after the steps value in the metric rail.
- Keeps the star visible until the next local day once today's step target has
  been reached.
- Shows the star whenever today's current steps are at or above Garmin's daily
  step goal, even if the watch face missed the exact crossing moment.
- Uses `10,000` steps only as the fallback target when Garmin's daily step goal
  is unavailable.
- Shows no step-goal text in v1.
- Keeps the mark visually secondary to the steps value and smaller than the
  current `36x36` metric icons.
- Keeps the mark attached to the steps value in all mood layouts, including the
  proud-mode metric row shift.
- Defers animated goal-achieved gestures until the static mark works well on the
  watch.

### Verification

- 2026-06-07: Built the device artifact for `fr57047mm` with `monkeyc`;
  result: `BUILD SUCCESSFUL`.
- 2026-06-06: Built the device artifact for `fr57047mm` with `monkeyc`;
  result: `BUILD SUCCESSFUL`.
- 2026-06-04: Built the device artifact for `fr57047mm` with `monkeyc`;
  result: `BUILD SUCCESSFUL`.

### Notes

- The Step Goal Mark is intentionally a small companion signal, not a badge,
  score screen, or achievement system.
- The star asset lives under `WatchFace/resources` as a lightweight active
  resource; large or inactive source assets should stay outside the app bundle.

## Current Prototype Baseline

### Watch Face Foundation

- Scaffolded a Garmin Connect IQ watch-face app under `WatchFace/`.
- Targets the Forerunner 570 `fr57047mm` device profile for current builds.
- Uses a dark, AMOLED-friendly digital watch-face layout.
- Shows large `HH:MM` time with `DD/MM` date above it.
- Keeps Mini Ido visually central while moving supporting data into a compact
  right-side metric rail.

### Mini Ido Mood Presentation

- Added mood-based Mini Ido background artwork for the active prototype states.
- Uses a happy/neutral background for ordinary state, a proud background for
  proud moments and same-day workout state, a good-morning coffee background
  for the morning window, and a sleepy background for night or soft moments.
- Uses palette-reduced `454x454` PNG backgrounds in the active watch-face
  resource bundle.
- Avoids restoring older `580x580` backgrounds into the active app bundle.
- Keeps text readable across mood backgrounds by switching text color and shadow
  treatment.

### Visible Data

- Shows current steps from Garmin activity-monitor data.
- Formats large step counts into compact `K` values for the small metric rail.
- Shows weekly running distance when available.
- Uses recorded running history for weekly running distance when available, with
  activity-monitor distance as a fallback.
- Shows current weather temperature when Garmin current-conditions data is
  available.
- Uses small PNG metric icons for steps, weekly running distance, and weather.

### Step Celebration

- Reads Garmin's daily step goal from activity-monitor data.
- Starts a once-per-local-day Step Celebration when current steps reach the
  Garmin daily step goal.
- Stores the local date of the Step Celebration so it does not repeat after a
  watch-face reload on the same day.
- Temporarily switches Mini Ido into the proud mood during the active
  celebration window.
- Shows a sticky gold Step Goal Mark immediately after the steps value for the
  rest of the local day.
- Uses `10,000` steps as the fallback target only when Garmin's daily step goal
  is unavailable.

### Performance And Rendering

- Defers slower resource-backed metric lookups until after the first full watch
  face draw, so the initial render appears faster.
- Caches activity-monitor info within the current minute.
- Caches weather temperature and weekly running distance for longer windows
  rather than fetching them on every draw.
- Caches the active mood background bitmap to avoid reloading the same resource
  repeatedly.
- Supports partial update rendering for date/time and metric row changes instead
  of redrawing everything when only small regions change.
- Tracks the last drawn mood, celebration type, time, date, and metric values so
  unchanged partial updates can be skipped.

### Resource And Repo Hygiene

- Cleaned active watch-face resources down to the currently used backgrounds and
  metric icons.
- Keeps large or inactive image assets outside the app bundle under
  `archived-assets/`.
- Stops tracking generated device binary artifacts in git while still building
  the installable binary to `device-binary/WatchFace.prg` locally.
- Added project documentation for product language, build instructions, next
  steps, and release notes.
