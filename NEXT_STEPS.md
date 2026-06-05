# Garmin Mini Me Next Steps

## Completed Concept Decisions

- [x] Define Mini Ido as a gentle companion, not a strict coach or generic virtual pet.
- [x] Choose mood-first behavior as the main expression model.
- [x] Keep v1 positive and non-judgmental, with no inactivity nudges.
- [x] Use an opinionated prototype with hardcoded behavior and no settings.
- [x] Choose a dark AMOLED-friendly digital watch face.
- [x] Place Mini Ido below the digital time by default.
- [x] Keep date, steps, and optional weekly distance as peripheral fields.
- [x] Choose the right data rail layout direction: keep the center cleaner by moving steps and optional secondary data to compact right-edge fields.
- [x] Limit v1 moods to neutral, happy/proud, tired/soft, and sleepy morning.
- [x] Use Mood Priority for v1: workout celebration, morning mood, recovery soft mode, neutral fallback.
- [x] Set Workout Celebration to about 15-30 minutes, with 30 minutes as the upper limit.
- [x] Set Morning Mood to last up to about 2 hours unless a workout overrides it.
- [x] Use one once-per-day Step Celebration when Garmin's daily step goal is reached.
- [ ] Use one once-per-day Workout Celebration after the first Recorded Workout of the day.
- [x] Defer long-term Growth from v1.
- [x] Treat the attached running photo as idea reference only, not production source material.

## Immediate Next Steps

- [x] Create or scaffold a Garmin Connect IQ watch-face project.
- [x] Target the Garmin Forerunner 570.
- [x] Confirm the exact Forerunner 570 screen dimensions and simulator profile.
- [x] Render a dark background.
- [x] Render large digital time.
- [x] Render date as `DD/MM`.
- [x] Add date above time.
- [x] Render current steps.
- [x] Add an optional placeholder area for weekly distance if the layout stays clean.
- [x] Add a placeholder Mini Ido below the digital time.
- [x] Add placeholder visual states for neutral, happy/proud, tired/soft, and sleepy morning.

## Garmin Feasibility Checks

- [ ] Confirm `ActivityMonitor.Info.steps` works in the watch face.
- [x] Confirm `ActivityMonitor.Info.stepGoal` works in the watch face.
- [x] Confirm persistent storage can remember whether Step Celebration already appeared today.
- [ ] Verify whether a watch face can access latest Recorded Workout information.
- [ ] Verify whether workout type is available for Support Phrase selection.
- [ ] Verify whether sleep quality data is available from a watch face.
- [ ] Verify which Recovery Signal is available: Body Battery, time to recovery, or another recovery-oriented metric.
- [ ] Verify animation/update frequency constraints for a battery-conscious Idle Loop.
- [ ] Verify any always-on-display limitations relevant to animation or color.

## V1 Behavior Implementation

- [ ] Implement Mood Priority.
- [ ] Implement Workout Celebration as the highest-priority temporary state.
- [ ] Implement Celebration Window timing with a 15-30 minute duration.
- [ ] Ensure Workout Celebration appears once per day after the first Recorded Workout.
- [ ] Implement workout-type-linked Support Phrases when workout type is available.
- [ ] Implement Morning Mood for up to 2 hours.
- [ ] Implement good-vs-poor Sleep Quality if sleep data is available.
- [ ] Implement Recovery State as normal or soft.
- [ ] Tune the Soft Mode threshold after checking available Garmin recovery data.
- [x] Implement Step Celebration once per day when daily step goal is reached.
- [x] Ensure Step Celebration does not repeat after watch-face reload on the same day.
- [x] Keep the proud Mini Ido reaction temporary while allowing the Step Goal Mark to remain visible for the rest of the local day.
- [ ] Ensure v1 messages appear only during Celebration moments.

## Visual Prototype And Assets

- [x] Create a simple static layout mock with placeholder Mini Ido.
- [x] Update the watch face toward the right data rail mock: smaller time, centered Mini Ido, and compact right-edge steps/secondary data.
- [x] Shift Mini Ido slightly left so the avatar feels better balanced against the right data rail.
- [x] Adjust date and time placement so they never overlap at large time values.
- [x] Reduce the font size for steps, goal, and weekly distance labels/values.
- [ ] Test whether the time remains readable with Mini Ido below it.
- [ ] Test whether peripheral date and step fields remain readable.
- [ ] Decide whether weekly distance fits cleanly.
- [ ] Design first-pass placeholder Mini Ido sprites.
- [ ] Replace placeholders with v1 assets only after behavior and layout feel right.
- [x] Remove the separate `STEP GOAL` sign treatment.
- [x] Do not show text for Step Celebration in v1; use proud Mini Ido plus the Step Goal Mark.
- [x] For Step Celebration, show a tiny star Step Goal Mark immediately after the steps count until the end of the local day.
- [x] Use a tiny static gold PNG star asset for the Step Goal Mark, not emoji text or generated SVG.
- [x] Size the Step Goal Mark like the existing metric icons or slightly smaller, without changing the metric row height or spacing.
- [x] Keep the Step Goal Mark attached to the steps value in all mood layouts, including proud-mode row shifts.
- [x] Show the Step Goal Mark whenever today's current steps are at or above the daily step goal, or 10,000 steps when the Garmin goal is unavailable, even if the watch face missed the exact crossing moment.
- [x] Clear the Step Goal Mark on the next local day.
- [x] Defer an animated goal-achieved gesture until the simple Step Goal Mark works.
- [x] Do not create a separate full celebration image for v1; reuse the happy/proud state with a small celebration treatment.
- [ ] Create neutral Mini Ido asset.
- [ ] Create happy/proud Mini Ido asset.
- [ ] Create tired/soft Mini Ido asset.
- [ ] Create sleepy morning Mini Ido asset.
- [x] Create a simple Support Phrase treatment, using either a sign or speech bubble.

## Future V2/V3 Ideas

- [ ] Add multiple step milestones.
- [ ] Add workout-specific props or animations.
- [ ] Add long-term Growth.
- [ ] Add configurable settings after prototype use reveals which settings matter.
- [ ] Add richer mood blending if Mood Priority feels too simple.
- [ ] Add additional contextual outfits.
- [ ] Consider a softer hardcoded step target if Garmin's daily goal makes Mini Ido feel insufficiently encouraging.
