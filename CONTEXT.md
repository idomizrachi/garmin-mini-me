# Garmin Mini Me

Garmin Mini Me is a watch-face companion concept where the user's physiological and activity state is expressed through a small personal avatar. The context exists to keep the product language focused on a companion experience rather than a generic virtual pet game.

## Language

**Mini Ido**:
A small avatar of Ido that reacts to Ido's body state, activity, and recovery. Mini Ido is a companion with light coaching behavior, not a separate pet to maintain.
_Avoid_: Pet, character, creature

**Companion**:
The emotional role of Mini Ido: a watch-face presence that reflects, celebrates, and gently nudges Ido based on current state. A companion is pleased by effort and avoids strict training demands.
_Avoid_: Game character, mascot, coach

**Gentle Nudge**:
A low-pressure suggestion or reaction from Mini Ido that encourages care, movement, or recovery without creating obligation.
_Avoid_: Command, training instruction, demand

**Effort Signal**:
A body or activity signal that Mini Ido treats as evidence that Ido did something worth noticing. Effort signals include workouts, steps, sleep, and recovery.
_Avoid_: Achievement, task, chore

**Workout**:
A recorded activity session such as a run, strength session, walk, ride, swim, or similar exercise. A workout is a stronger effort signal than ordinary steps.
_Avoid_: Exercise, training session

**Recorded Workout**:
A workout that Garmin has actually recorded or recognized as an activity. Workout Celebration should be based on Recorded Workouts rather than inferred from ordinary movement when the platform makes that practical.
_Avoid_: Inferred workout, movement spike

**Workout Celebration**:
The Celebration caused by a Recorded Workout. In the first version, all Recorded Workout types should trigger the same Celebration Window rather than being weighted or filtered by activity type. Workout Celebration should appear at most once per local day, after the first Recorded Workout of that day.
_Avoid_: Workout ranking, type-based judgment

**Workout Flavor**:
Light variation based on workout type, limited in the first version to Support Phrases when workout type is available. Workout-specific props and animations are future enhancements.
_Avoid_: Type-specific v1 asset set, workout hierarchy

**Recovery**:
The current readiness or depletion state that affects how energetic Mini Ido appears and how ambitious his nudges should be.
_Avoid_: Laziness, weakness

**Recovery Signal**:
The Garmin-provided signal used to decide whether Mini Ido enters Soft Mode, such as Body Battery, time to recovery, or another available recovery-oriented metric. The concept is low recovery, not a commitment to one specific Garmin field.
_Avoid_: Single-metric dependency, body-battery-only rule

**Mood**:
The primary visible state of Mini Ido, synthesized from workouts, steps, sleep, and recovery. Mood expresses a human-like combination such as proud, tired, cozy, restless, focused, sleepy, or energized.
_Avoid_: Score, status, metric

**Growth**:
A subtle long-term layer that reflects consistent effort over weeks or months. Growth can make Mini Ido appear more capable or confident, but it should not dominate the current mood or punish busy periods; it is deferred from the first version.
_Avoid_: Level, rank, degradation

**Likeness**:
The recognizable "tiny Ido" identity of Mini Ido, expressed through compact visual cues such as runner gear, cap, sunglasses, bright shirt, hydration vest, bib, black shorts, or pink socks. Likeness should remain readable at watch-face size and may use an 8-bit style when that improves clarity.
_Avoid_: Generic avatar, realistic portrait

**Supporter Ido**:
A temporary tiny version of Mini Ido that appears during celebratory or rewarding moments. Supporter Idos can cheer, hold signs, take photos, or run alongside the main Mini Ido, but the default watch face should center one main Mini Ido.
_Avoid_: Crowd, permanent clones

**Message**:
A short phrase, sign, or speech bubble near Mini Ido or a Supporter Ido. Messages translate data into feeling, should be brief and warm, and may use whichever sign or bubble treatment is simpler to implement cleanly.
_Avoid_: Metric readout, notification, instruction

**Celebration Message**:
A Message used only during a positive reward moment, such as Workout Celebration or Step Celebration. The first version should avoid everyday chatter outside celebration moments.
_Avoid_: Ambient message, constant chatter

**Support Phrase**:
A short Celebration Message with a sign-like supportive tone, such as "Nice one!", "You got this!", "Keep going!", or "Strong!". Support Phrases should rotate to avoid repetition and may be linked to workout type when that information is available.
_Avoid_: Long copy, coaching advice

**Shared Stage**:
The default watch-face composition where the time and Mini Ido share visual priority. Mini Ido may interact with the time, such as exercising around the hours-and-minutes display, while keeping the time easy to read.
_Avoid_: Dashboard, toy-only layout

**Digital Time Stage**:
The v1 time layout: a readable digital hours-and-minutes display that Mini Ido can visually interact with. Analog hands and decorative arcs are out of scope for the first version.
_Avoid_: Analog face, arc-first layout

**Home Position**:
Mini Ido's normal placement relative to the Digital Time Stage. In the first version, his Home Position is below the digital time, while mood-specific poses and idle loops may move him above, below, beside, or attached to the time.
_Avoid_: Fixed-only placement, random placement

**Idle Loop**:
A short, battery-conscious animation that gives Mini Ido life without requiring constant rich motion. Each idle loop should still read clearly as a still pose if animation is limited.
_Avoid_: Cutscene, continuous animation

**Soft Mode**:
A low-energy companion mode used when recovery is low. In Soft Mode, Mini Ido looks tired, cozy, or slowed down through pose and idle loop, without messages in the first version, and can still be proud of completed effort.
_Avoid_: Failure state, shame state

**Recovery State**:
The first-version recovery interpretation with only two levels: normal and soft. The exact threshold belongs to implementation tuning after checking available Garmin data, and more nuanced recovery intensity can be added later if the prototype needs it.
_Avoid_: Multi-level fatigue scale, recovery score display

**Celebration**:
A temporary rewarding reaction after a workout or meaningful effort signal. Celebration can include cheering, Supporter Idos, a short message, and a short-lived proud or energized mood, and should remain positive even when recovery is low.
_Avoid_: Badge, metric summary, score screen

**Ambient Movement**:
Ordinary daily movement reflected by steps and similar low-intensity activity. Ambient Movement quietly shapes Mini Ido's mood and can trigger small rewards at meaningful milestones, but it is less dramatic than a workout.
_Avoid_: Workout, chore, step grind

**Step Celebration**:
A once-per-day small reward when Ido reaches a meaningful step milestone, preferably Garmin's daily step goal. It should not repeat after a watch-face reload on the same day, and it does not override Morning Mood like a workout does.
_Avoid_: Step ladder, repeated milestone spam

**Celebration Treatment**:
The small visual layer that makes a Celebration feel special without requiring a separate full-state image. In the first version, Celebration Treatment should reuse the happy or proud Mini Ido state and add a light sign, phrase, or similar accent.
_Avoid_: Separate celebration-only full image, permanent decoration

**Morning Mood**:
A time-bounded mood influenced by the previous night's sleep. Morning Mood is visible early in the day for up to about two hours and can be overridden sooner by a workout.
_Avoid_: Sleep score display, all-day sleep label

**Sleep Quality**:
The simple first-version interpretation of the previous night's sleep as good or poor. Good sleep creates a brighter Morning Mood, while poor sleep creates a sleepy Morning Mood without warning text, using whatever Garmin sleep signal is practical during implementation.
_Avoid_: Detailed sleep analysis, sleep score display

**Quiet Mood Input**:
A signal that changes Mini Ido's pose or mood without creating a message. Sleep Quality and Recovery State are Quiet Mood Inputs in the first version.
_Avoid_: Message trigger, alert

**Soft Negative**:
A non-accusatory low mood that makes Mini Ido feel alive, such as sleepy, tired, restless, bored, or overwhelmed. Soft Negative moods describe the current state without implying Ido failed.
_Avoid_: Disappointed, angry, judgmental

**Positive Bias**:
The companion rule that Mini Ido should emphasize effort, recovery, and encouraging reactions rather than calling attention to inactivity or missed movement. Busy days should not be treated as failure.
_Avoid_: Inactivity warning, guilt prompt

**Visible Data**:
The non-companion information shown directly on the watch face. Visible Data should prioritize time, date, and steps; weekly distance may be included only if the layout remains clean, while other body and recovery signals should usually be expressed through Mini Ido instead of raw fields.
_Avoid_: Data-rich dashboard, metric grid

**Peripheral Fields**:
Small date, steps, and optional weekly-distance fields placed around the lower edge or corners so the center remains available for the Digital Time Stage and Mini Ido.
_Avoid_: Stacked metric block, crowded center

**Opinionated Prototype**:
The first version of the watch face with hardcoded behavior and no user-facing settings. Settings should be added only after using the prototype reveals which choices need to be configurable.
_Avoid_: Settings-first design, configuration surface

**Charm Test**:
The first-version success test: the watch face should work functionally, but its real proof is whether Mini Ido feels alive enough that Ido smiles and wants to keep wearing it.
_Avoid_: Metric-only success, feature checklist success

**Modern Pixel Style**:
The visual style for Mini Ido: nostalgic and sprite-like, but crisp and readable on a modern AMOLED Garmin display. It should preserve the virtual-pet feeling without being limited to strict 8-bit detail.
_Avoid_: Pure 8-bit, realistic cartoon, generic illustration

**Dark Stage**:
The default visual environment for the watch face: an AMOLED-friendly dark background that keeps time readable and lets Mini Ido's bright runner palette stand out.
_Avoid_: Bright full-screen background, retro LCD default

**Contextual Outfit**:
Mini Ido's outfit can change with mood, activity, or time of day while preserving recognizable Ido cues. The Runner Look is an important outfit for activity and celebration moments, but it is not the permanent default.
_Avoid_: Fixed runner default, generic costume swap

**Idea Reference**:
A visual or conceptual reference used to communicate the feeling of Mini Ido without becoming production source material. Idea references can inspire recognizable cues and scenarios, but final assets should be designed separately.
_Avoid_: Source asset, final likeness input

**Base Avatar**:
The minimal recognizable form of Mini Ido used across ordinary states. The Base Avatar carries Ido's identity, while props and contextual outfits add workout, recovery, sleep, or celebration meaning.
_Avoid_: Default outfit, blank character

**Essential Mood Set**:
The first set of Mini Ido moods: neutral, happy or proud, tired or soft, and sleepy morning. This set is intentionally small so the companion can be proven before expanding the emotional range.
_Avoid_: Full mood library, exhaustive emotion set

**Mood Priority**:
The rule for choosing Mini Ido's visible mood when several signals are available. Recent rewarding events such as workout celebration take priority temporarily, Morning Mood applies early in the day, recovery shapes the state after temporary moments fade, and neutral is the fallback.
_Avoid_: Weighted score, blended metric

**Celebration Window**:
The short period after a workout or meaningful effort signal when Mini Ido stays visibly proud or happy. The intended range is roughly 15 to 30 minutes, with 30 minutes as the upper limit.
_Avoid_: All-day celebration, instant-only reward

## Example Dialogue

Designer: "Mini Ido looks drained after a low-recovery day. Should he ask for exercise?"

Domain expert: "No. As a companion, he should respect recovery first. He can suggest rest or a gentle walk, not push a hard workout."

Designer: "Mini Ido noticed a workout. Should he tell Ido the next workout target?"

Domain expert: "No. He should mainly look pleased and reward the effort. The training program is intentionally not strict."

Designer: "Should Mini Ido infer workouts from distance or intensity changes?"

Domain expert: "Prefer no. Workout Celebration should come from a Recorded Workout when Garmin exposes that information well enough."

Designer: "Should a walk celebrate less than a run in the first version?"

Domain expert: "No. In v1, all Recorded Workout types should trigger the same Workout Celebration."

Designer: "Should v1 include swim, bike, run, and strength props?"

Domain expert: "No. Workout Flavor in v1 should be limited to messages; visual props can improve later."

Designer: "Ido slept well but did not record a workout. Is that still worth a positive Mini Ido reaction?"

Domain expert: "Yes. Sleep and recovery are effort signals too, though workouts should feel more significant."

Designer: "Must Soft Mode depend specifically on Body Battery?"

Domain expert: "No. Use the best available Recovery Signal, such as Body Battery or time to recovery."

Designer: "Should Mini Ido have several levels of tiredness in v1?"

Domain expert: "No. Use a two-level Recovery State: normal or soft."

Designer: "Body Battery is low but Ido just finished a run. Is Mini Ido happy or tired?"

Domain expert: "Both. Mood can express a combination like proud but tired instead of reducing the day to a single score."

Designer: "If Ido misses workouts for a week, should Mini Ido shrink or lose progress?"

Domain expert: "No. Growth should be subtle and encouraging. Current mood can look tired or restless, but long-term growth should not become a punishment."

Designer: "Should Mini Ido look like a generic pixel person?"

Domain expert: "No. He should be recognizably Ido when the watch size allows it, using iconic visual cues rather than a detailed portrait."

Designer: "Can the watch face show many tiny Idos at once?"

Domain expert: "Usually no. One main Mini Ido should anchor the face, with Supporter Idos appearing briefly as rewards."

Designer: "After a workout, should Mini Ido show exact distance and pace?"

Domain expert: "Not as the reward. He should show a brief warm message or sign, while Garmin can handle exact metrics elsewhere."

Designer: "Should Mini Ido talk throughout the day?"

Domain expert: "No. In v1, messages should be reserved for Celebration moments."

Designer: "Should celebration text explain the workout or give advice?"

Domain expert: "No. Use short Support Phrases that feel like tiny signs."

Designer: "Can Mini Ido climb on or exercise around the time display?"

Domain expert: "Yes, when the device supports it. The time and Mini Ido should feel like they share a stage, not like separate widgets."

Designer: "Should the first watch face use analog hands or circular progress arcs?"

Domain expert: "No. Use a Digital Time Stage so Mini Ido can interact with the hours-and-minutes display."

Designer: "Should Mini Ido always stand in one spot?"

Domain expert: "No. He should have a Home Position for readability, but can move around the time for mood and animation."

Designer: "Does Mini Ido need rich animation to work?"

Domain expert: "No. Light idle loops are ideal, but every mood should remain readable as a still pose."

Designer: "If recovery is low, should Mini Ido look disappointed?"

Domain expert: "No. Low recovery should trigger Soft Mode: tired or cozy, less nudging, and still proud when Ido does something."

Designer: "Should every workout type need a distinct animation before the concept works?"

Domain expert: "No. Shared Celebration behavior matters first; workout-specific flavor can come later."

Designer: "If recovery is low, should Mini Ido dampen the post-workout celebration?"

Domain expert: "No. Celebration should stay positive because it is temporary; low-energy recovery states can return afterward."

Designer: "Should steps create the same celebration as a workout?"

Domain expert: "No. Steps should influence mood throughout the day and create smaller rewards at meaningful milestones."

Designer: "Should Mini Ido react at many step percentages in the first version?"

Domain expert: "No. Start with one small Step Celebration; multiple step milestones can come later."

Designer: "Should the first Step Celebration use a fixed number like 10,000 steps?"

Domain expert: "Use Garmin's daily step goal when available; fall back to a fixed threshold only if the goal is unavailable."

Designer: "Should last night's sleep define Mini Ido for the entire day?"

Domain expert: "No. Sleep should shape a Morning Mood for up to about two hours, and a workout can override it sooner."

Designer: "Should Morning Mood distinguish many sleep levels?"

Domain expert: "No. Use simple Sleep Quality: good or poor."

Designer: "Should good or poor sleep create text on the watch face?"

Domain expert: "No. Sleep Quality is a Quiet Mood Input: it changes Morning Mood without messages."

Designer: "Can Mini Ido look bored or tired?"

Domain expert: "Yes, soft negative moods help him feel alive, but he should never look disappointed in Ido."

Designer: "Should Mini Ido react when Ido has been inactive for a while?"

Domain expert: "Not at first. The companion should keep a positive bias and avoid framing busy days as a problem."

Designer: "Should body battery and sleep score appear as numbers on the face?"

Domain expert: "Usually no. Time, date, steps, and maybe weekly distance can be direct Visible Data; other signals should mostly shape Mini Ido."

Designer: "Should date and steps sit directly in the center under Mini Ido?"

Domain expert: "No. Use Peripheral Fields so Mini Ido and the time keep the central stage."

Designer: "Should v1 expose settings for celebration length, fields, or mood sensitivity?"

Domain expert: "No. Keep v1 as an Opinionated Prototype and add settings only after prototype use reveals real needs."

Designer: "How do we know v1 is successful?"

Domain expert: "It must function, but the Charm Test matters most: Mini Ido should feel alive and worth wearing."

Designer: "Should Mini Ido be pure 8-bit?"

Domain expert: "No. The style should be modern pixel: nostalgic and sprite-like, but polished enough for a modern AMOLED watch."

Designer: "Should the default face mimic a bright old handheld toy screen?"

Domain expert: "No. The default should be a Dark Stage for AMOLED, with the retro feeling coming from Mini Ido and the interaction style."

Designer: "Should Mini Ido always wear running gear?"

Domain expert: "No. He can wear the Runner Look sometimes, especially around workouts, but outfits should change with context while still feeling like Ido."

Designer: "Should the running photo be used as final source material for the watch-face assets?"

Domain expert: "No. It is an Idea Reference only; final assets will be designed later."

Designer: "Does Mini Ido need a full default outfit for normal time?"

Domain expert: "No. He should have a recognizable Base Avatar, with props or contextual outfits layered on when needed."

Designer: "Should the first version include many Tamagotchi-like emotions?"

Domain expert: "No. Start with the Essential Mood Set and expand only after the core companion feeling works."

Designer: "If workout, sleep, and recovery all suggest different moods, should they be blended?"

Domain expert: "Not for the first version. Use Mood Priority: temporary rewarding events first, Morning Mood early, recovery afterward, neutral as fallback."

Designer: "Should a workout celebration last all day?"

Domain expert: "No. It should use a Celebration Window of about 15 to 30 minutes, then let newer or baseline moods return."
