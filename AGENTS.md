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

- Keep active watch-face resources under `WatchFace/resources`.
- Keep large or inactive image assets outside the app bundle under `archived-assets/`.
- Do not restore `580x580` background images into `WatchFace/resources`; they are intentionally archived outside the app for performance.
- Current active backgrounds are `454x454` palette-reduced PNGs.
