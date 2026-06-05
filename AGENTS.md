# AGENTS.md

## Project

Garmin Mini Me is a Garmin Connect IQ watch-face prototype.

- App source: `WatchFace/`
- Built device artifact: `device-binary/WatchFace.prg`
- Target device for current builds: `fr57047mm`
- Archived/reference assets: `archived-assets/`

## Garmin Build

Use the Garmin developer key via the `GARMIN_DEVELOPER_KEY` environment
variable. Do not commit the personal key path to this repo.

Before building, check whether `GARMIN_DEVELOPER_KEY` is already set in the
shell. If it is not set, check local-only notes under `.codex-local/` for the
key location. If the key location is still unknown, ask the user for it before
running `monkeyc`; do not guess, search broad personal directories, or write the
key path into tracked files.

```sh
export GARMIN_DEVELOPER_KEY="/path/to/local/developer_key"
```

Build for device from `WatchFace/` and save the installable binary under
`device-binary/`:

```sh
monkeyc -f monkey.jungle -d fr57047mm -o ../device-binary/WatchFace.prg -y "$GARMIN_DEVELOPER_KEY"
```

Local-only agent notes may live under `.codex-local/`, which is excluded from
git for this workspace.

## Repo Notes

- The repository root is one level above the active app source. Most build and
  source commands should run from `WatchFace/`.
- Update `RELEASE_NOTES.md` after implementation changes, especially when a
  user-visible behavior, visual treatment, build result, or checklist status
  changes.
- Active source files are `WatchFace/source/MiniMeApp.mc` and
  `WatchFace/source/MiniMeWatchFaceView.mc`.
- This is a small companion watch face, not a coaching or punitive fitness app.
  Preserve the positive, consistency-focused product tone in copy and UI text.
- The active watch face currently shows time, date, steps, weekly running
  distance, weather temperature, mood-based backgrounds, and a once-per-day step
  goal celebration.
- Keep active watch-face resources under `WatchFace/resources`.
- Keep large or inactive image assets outside the app bundle under `archived-assets/`.
- Do not restore `580x580` background images into `WatchFace/resources`; they are intentionally archived outside the app for performance.
- Current active backgrounds are `454x454` palette-reduced PNGs.
- Watch for existing user edits before changing files. At the time these notes
  were updated, `WatchFace/resources/drawables/drawables.xml` had local
  modifications.
- `WatchFace/README.md` may lag behind the root build instructions; prefer this
  file for current device builds.
