import Toybox.Application.Storage;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.WatchUi;
import Toybox.Weather;

class MiniMeWatchFaceView extends WatchUi.WatchFace {
    private const MOOD_NEUTRAL = 0;
    private const MOOD_PROUD = 1;
    private const MOOD_SOFT = 2;
    private const MOOD_SLEEPY = 3;
    private const CELEBRATION_NONE = 0;
    private const CELEBRATION_STEPS = 1;

    private const BACKGROUND_SIZE = 454;
    private const CELEBRATION_WINDOW_SECONDS = 1800;
    private const STEP_GOAL_FALLBACK_STEPS = 10000;
    private const STEP_GOAL_MARK_SIZE = 24;
    private const STEP_GOAL_MARK_GAP = 5;
    private const WEEKLY_RUNNING_DISTANCE_CACHE_MINUTES = 60;
    private const WEATHER_CACHE_MINUTES = 15;
    private const STEP_CELEBRATION_STORAGE_KEY = "miniMe.stepCelebratedDate";
    private var activeBackgroundBitmap as BitmapResource?;
    private var activeBackgroundMood as Number = -1;
    private var activeCelebrationType as Number = CELEBRATION_NONE;
    private var celebrationStartedAt as Time.Moment?;
    private var stepsIconBitmap as BitmapResource?;
    private var stepGoalStarBitmap as BitmapResource?;
    private var weatherIconBitmap as BitmapResource?;
    private var weeklyRunningDistanceIconBitmap as BitmapResource?;
    private var activityInfoCacheMinute as Number = -1;
    private var activityInfoCache = null;
    private var weeklyRunningDistanceCacheMinute as Number = -1;
    private var weeklyRunningDistanceText as String = "--";
    private var hasWeeklyRunningDistanceText as Boolean = false;
    private var weatherCacheMinute as Number = -1;
    private var weatherTemperatureText as String = "--\u00B0";
    private var hasWeatherTemperatureText as Boolean = false;
    private var stepsText as String = "--";
    private var cachedSteps as Number = 0;
    private var hasCachedSteps as Boolean = false;
    private var cachedStepsDay as Number = -1;
    private var cachedStepsMonth as Number = -1;
    private var stepGoal as Number = 0;
    private var hasStepGoal as Boolean = false;
    private var firstFullFaceDrawn as Boolean = false;
    private var lastDrawnMinute as Number = -1;
    private var lastDrawnDay as Number = -1;
    private var lastDrawnMonth as Number = -1;
    private var lastDrawnMood as Number = -1;
    private var lastDrawnCelebrationType as Number = CELEBRATION_NONE;
    private var lastDrawnStepsText as String = "";
    private var lastDrawnWeeklyText as String = "";
    private var lastDrawnWeatherText as String = "";
    private var lastDrawnResourceMetrics as Boolean = false;
    private var lastDrawnStepGoalMark as Boolean = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        drawFace(dc);
    }

    function onPartialUpdate(dc as Dc) as Void {
        if (!firstFullFaceDrawn) {
            drawFace(dc);
            return;
        }

        drawPartialFace(dc);
    }

    function onHide() as Void {
    }

    private function drawFace(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var steps = getSteps();
        var mood = choosePrototypeMood(steps);
        var clock = System.getClockTime();
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var shouldDrawResourceMetrics = firstFullFaceDrawn;
        var stepCountText = getStepsText(steps);
        var showStepGoalMark = hasReachedStepTarget(steps);
        var weeklyText = shouldDrawResourceMetrics ? getWeeklyRunningDistanceText() : weeklyRunningDistanceText;
        var weatherText = shouldDrawResourceMetrics ? getWeatherTemperatureText() : weatherTemperatureText;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawBackground(dc, width, height, mood);
        drawDateAndTime(dc, centerX, height, mood, clock, dateInfo);
        drawActivityRows(
            dc,
            width,
            height,
            mood,
            stepCountText,
            showStepGoalMark,
            weeklyText,
            weatherText,
            shouldDrawResourceMetrics
        );
        rememberDrawnState(clock, dateInfo, mood);
        rememberDrawnMetrics(stepCountText, weeklyText, weatherText, shouldDrawResourceMetrics, showStepGoalMark);

        if (!firstFullFaceDrawn) {
            WatchUi.requestUpdate();
        }

        firstFullFaceDrawn = true;
    }

    private function fillFallbackBackground(dc as Dc, width as Number, height as Number, mood as Number) as Void {
        var backgroundColor = 0x244B5A;

        if (mood == MOOD_PROUD) {
            backgroundColor = 0xF1C85F;
        } else if (mood == MOOD_NEUTRAL) {
            backgroundColor = 0xB8D7C4;
        }

        dc.setColor(backgroundColor, backgroundColor);
        dc.clear();
    }

    private function drawPartialFace(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var steps = getSteps();
        var mood = choosePrototypeMood(steps);
        var clock = System.getClockTime();
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var stepCountText = getStepsText(steps);
        var showStepGoalMark = hasReachedStepTarget(steps);
        var weeklyText = getWeeklyRunningDistanceText();
        var weatherText = getWeatherTemperatureText();
        var metricsChanged = haveMetricRowsChanged(stepCountText, weeklyText, weatherText, true, showStepGoalMark);

        if ((mood != lastDrawnMood) || (activeCelebrationType != lastDrawnCelebrationType)) {
            drawFace(dc);
            return;
        }

        if (
            (clock.min == lastDrawnMinute) &&
            ((dateInfo.day as Number) == lastDrawnDay) &&
            ((dateInfo.month as Number) == lastDrawnMonth) &&
            !metricsChanged
        ) {
            return;
        }

        if (
            (clock.min != lastDrawnMinute) ||
            ((dateInfo.day as Number) != lastDrawnDay) ||
            ((dateInfo.month as Number) != lastDrawnMonth)
        ) {
            drawDateAndTimeRegion(dc, width, height, centerX, mood, clock, dateInfo);
        }

        if (metricsChanged) {
            drawActivityRowsRegion(dc, width, height, mood, stepCountText, showStepGoalMark, weeklyText, weatherText, true);
            rememberDrawnMetrics(stepCountText, weeklyText, weatherText, true, showStepGoalMark);
        }

        rememberDrawnState(clock, dateInfo, mood);
    }

    private function drawBackground(dc as Dc, width as Number, height as Number, mood as Number) as Void {
        var bitmap = getBackgroundBitmap(mood);

        if (bitmap != null) {
            dc.drawBitmap(
                ((width - BACKGROUND_SIZE) / 2).toNumber(),
                ((height - BACKGROUND_SIZE) / 2).toNumber(),
                bitmap
            );
        }
    }

    private function drawDateAndTimeRegion(dc as Dc, width as Number, height as Number, centerX as Number, mood as Number, clock, dateInfo) as Void {
        var regionX = (width * 0.30).toNumber();
        var regionY = (height * 0.04).toNumber();
        var regionWidth = (width * 0.62).toNumber();
        var regionHeight = (height * 0.34).toNumber();

        dc.setClip(regionX, regionY, regionWidth, regionHeight);
        drawBackground(dc, width, height, mood);
        drawDateAndTime(dc, centerX, height, mood, clock, dateInfo);
        dc.clearClip();
    }

    private function drawActivityRowsRegion(dc as Dc, width as Number, height as Number, mood as Number, stepsText as String, showStepGoalMark as Boolean, weeklyText as String, weatherText as String, shouldDrawIcons as Boolean) as Void {
        var regionX = (width * 0.46).toNumber();
        var regionY = (height * 0.40).toNumber();
        var regionWidth = (width * 0.48).toNumber();
        var regionHeight = (height * 0.39).toNumber();

        dc.setClip(regionX, regionY, regionWidth, regionHeight);
        drawBackground(dc, width, height, mood);
        drawActivityRows(dc, width, height, mood, stepsText, showStepGoalMark, weeklyText, weatherText, shouldDrawIcons);
        dc.clearClip();
    }

    private function drawDateAndTime(dc as Dc, centerX as Number, height as Number, mood as Number, clock, dateInfo) as Void {
        var timeText = Lang.format(
            "$1$:$2$",
            [ clock.hour.format("%02d"), clock.min.format("%02d") ]
        );
        var dateText = Lang.format(
            "$1$/$2$",
            [
                (dateInfo.day as Number).format("%02d"),
                (dateInfo.month as Number).format("%02d")
            ]
        );

        var timeY = (height * 0.27).toNumber();
        var timeX = (centerX + (height * 0.04)).toNumber();
        var dateY = (timeY - (height * 0.17)).toNumber();
        var textColor = getTextColor(mood);
        var shadowColor = (mood == MOOD_PROUD) ? 0xFFFFFF : 0x197DC5;

        drawShadowText(dc, timeX, dateY, Graphics.FONT_SMALL, dateText, textColor, shadowColor, 2);
        drawShadowText(dc, timeX, timeY, Graphics.FONT_NUMBER_HOT, timeText, textColor, shadowColor, 4);
    }

    private function drawActivityRows(dc as Dc, width as Number, height as Number, mood as Number, stepsText as String, showStepGoalMark as Boolean, weeklyText as String, weatherText as String, shouldDrawIcons as Boolean) as Void {
        var clusterOffsetX = (width * 0.035).toNumber();
        var clusterOffsetY = (height * 0.05).toNumber();
        var proudOffsetX = (mood == MOOD_PROUD) ? (width * 0.075).toNumber() : 0;
        var iconX = (width * 0.535).toNumber() - clusterOffsetX + proudOffsetX;
        var valueX = (width * 0.585).toNumber() - clusterOffsetX + proudOffsetX;
        var topY = (height * 0.52).toNumber() - clusterOffsetY;
        var rowGap = (height * 0.13).toNumber();
        var textColor = getTextColor(mood);

        drawMetricRow(dc, iconX, valueX, topY, stepsText, textColor, 0, shouldDrawIcons, showStepGoalMark);
        drawMetricRow(dc, iconX, valueX, topY + rowGap, weeklyText, textColor, 2, shouldDrawIcons, false);
        drawMetricRow(dc, iconX, valueX, topY + (rowGap * 2), weatherText, textColor, 1, shouldDrawIcons, false);
    }

    private function drawMetricRow(dc as Dc, iconX as Number, valueX as Number, y as Number, value as String, color as Number, iconType as Number, shouldDrawIcon as Boolean, showStepGoalMark as Boolean) as Void {
        if (shouldDrawIcon) {
            drawMetricIcon(dc, iconX, y, iconType);
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        drawBoldText(dc, valueX, y, Graphics.FONT_TINY, value, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        if (showStepGoalMark && shouldDrawIcon) {
            drawStepGoalMark(dc, valueX, y, value);
        }
    }

    private function drawMetricIcon(dc as Dc, x as Number, y as Number, iconType as Number) as Void {
        var bitmap = getMetricIconBitmap(iconType);

        if (bitmap != null) {
            dc.drawBitmap(x - 18, y - 18, bitmap);
        }
    }

    private function getMetricIconBitmap(iconType as Number) as BitmapResource? {
        if (iconType == 0) {
            if (stepsIconBitmap == null) {
                stepsIconBitmap = WatchUi.loadResource(Rez.Drawables.IconSteps) as BitmapResource;
            }

            return stepsIconBitmap;
        } else if (iconType == 1) {
            if (weatherIconBitmap == null) {
                weatherIconBitmap = WatchUi.loadResource(Rez.Drawables.IconWeather) as BitmapResource;
            }

            return weatherIconBitmap;
        }

        if (weeklyRunningDistanceIconBitmap == null) {
            weeklyRunningDistanceIconBitmap = WatchUi.loadResource(Rez.Drawables.IconWeeklyRunningDistance) as BitmapResource;
        }

        return weeklyRunningDistanceIconBitmap;
    }

    private function drawStepGoalMark(dc as Dc, valueX as Number, y as Number, value as String) as Void {
        var bitmap = getStepGoalStarBitmap();

        if (bitmap == null) {
            return;
        }

        var textWidth = dc.getTextWidthInPixels(value, Graphics.FONT_TINY);
        var markX = valueX + textWidth + STEP_GOAL_MARK_GAP;
        var markY = y - (STEP_GOAL_MARK_SIZE / 2);

        dc.drawBitmap(markX, markY, bitmap);
    }

    private function getStepGoalStarBitmap() as BitmapResource? {
        if (stepGoalStarBitmap == null) {
            stepGoalStarBitmap = WatchUi.loadResource(Rez.Drawables.IconStepGoalStar) as BitmapResource;
        }

        return stepGoalStarBitmap;
    }

    private function drawShadowText(dc as Dc, x as Number, y as Number, font as Graphics.FontType, text as String, color as Number, shadowColor as Number, offset as Number) as Void {
        dc.setColor(shadowColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x + offset,
            y + offset,
            font,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            y,
            font,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawBoldText(dc as Dc, x as Number, y as Number, font as Graphics.FontType, text as String, justification as Number) as Void {
        dc.drawText(x, y, font, text, justification);
        dc.drawText(x + 1, y, font, text, justification);
    }

    private function getWeeklyRunningDistanceText() as String {
        var cacheMinute = (Time.now().value() / 60).toNumber();

        if (
            hasWeeklyRunningDistanceText &&
            (weeklyRunningDistanceCacheMinute >= 0) &&
            ((cacheMinute - weeklyRunningDistanceCacheMinute) < WEEKLY_RUNNING_DISTANCE_CACHE_MINUTES)
        ) {
            return weeklyRunningDistanceText;
        }

        weeklyRunningDistanceCacheMinute = cacheMinute;
        var meters = getWeeklyRunningDistanceMeters();

        if (meters != null) {
            weeklyRunningDistanceText = formatDistance(meters as Number);
            hasWeeklyRunningDistanceText = true;
        }

        return weeklyRunningDistanceText;
    }

    private function getWeeklyRunningDistanceMeters() as Number? {
        var recordedRunTotal = getWeeklyRecordedRunningDistanceMeters();

        if ((recordedRunTotal != null) && ((recordedRunTotal as Number) > 0)) {
            return recordedRunTotal as Number;
        }

        return getWeeklyActivityMonitorDistanceMeters();
    }

    private function getWeeklyRecordedRunningDistanceMeters() as Number? {
        var total = 0;

        try {
            if (!(UserProfile has :getUserActivityHistory)) {
                return null;
            }

            var activityIterator = UserProfile.getUserActivityHistory();
            var weekStart = getStartOfWeek();
            var activity = activityIterator.next();

            while (activity != null) {
                if (
                    (activity has :startTime) &&
                    (activity.startTime != null) &&
                    (activity.startTime.compare(weekStart) >= 0) &&
                    (activity has :type) &&
                    (activity.type == Activity.SPORT_RUNNING) &&
                    (activity has :distance) &&
                    (activity.distance != null)
                ) {
                    total += activity.distance as Number;
                }

                activity = activityIterator.next();
            }
        } catch (ex) {
            return null;
        }

        return total;
    }

    private function getWeeklyActivityMonitorDistanceMeters() as Number? {
        var total = 0;

        try {
            var history = ActivityMonitor.getHistory();
            var weekStart = getStartOfWeek();
            var i = 0;

            if (history == null) {
                return null;
            }

            while (i < history.size()) {
                var day = history[i];

                if (
                    (day != null) &&
                    (day has :startOfDay) &&
                    (day.startOfDay != null) &&
                    (day.startOfDay.compare(weekStart) >= 0) &&
                    (day has :distance) &&
                    (day.distance != null)
                ) {
                    total += ((day.distance as Number) / 100).toNumber();
                }

                i++;
            }
        } catch (ex) {
            return null;
        }

        return total;
    }

    private function getStartOfWeek() as Time.Moment {
        var today = new Time.Moment(Time.today().value());
        var info = Gregorian.info(today, Time.FORMAT_SHORT);
        var firstDayOfWeek = 1;

        try {
            var settings = System.getDeviceSettings();

            if ((settings != null) && (settings has :firstDayOfWeek) && (settings.firstDayOfWeek != null)) {
                firstDayOfWeek = settings.firstDayOfWeek as Number;
            }
        } catch (ex) {
        }

        var daysSinceWeekStart = (info.day_of_week as Number) - firstDayOfWeek;

        if (daysSinceWeekStart < 0) {
            daysSinceWeekStart += 7;
        }

        return today.add(new Time.Duration(daysSinceWeekStart * Gregorian.SECONDS_PER_DAY * -1)) as Time.Moment;
    }

    private function formatDistance(meters as Number) as String {
        var value = meters / 1000.0;

        if (value >= 100) {
            return Lang.format("$1$km", [ value.toNumber().format("%d") ]);
        }

        return Lang.format("$1$km", [ value.format("%.1f") ]);
    }

    private function formatSteps(steps as Number) as String {
        if (steps >= 10000) {
            return Lang.format("$1$K", [ (steps / 1000).toNumber().format("%d") ]);
        } else if (steps >= 1000) {
            var thousands = (steps / 1000).toNumber();
            var hundreds = ((steps % 1000) / 100).toNumber();

            return Lang.format("$1$.$2$K", [ thousands.format("%d"), hundreds.format("%d") ]);
        }

        return steps.format("%d");
    }

    private function getWeatherTemperatureText() as String {
        var cacheMinute = (Time.now().value() / 60).toNumber();

        if (
            hasWeatherTemperatureText &&
            (weatherCacheMinute >= 0) &&
            ((cacheMinute - weatherCacheMinute) < WEATHER_CACHE_MINUTES)
        ) {
            return weatherTemperatureText;
        }

        weatherCacheMinute = cacheMinute;

        try {
            if (!(Weather has :getCurrentConditions)) {
                return weatherTemperatureText;
            }

            var conditions = Weather.getCurrentConditions();

            if (
                (conditions != null) &&
                (conditions has :temperature) &&
                (conditions.temperature != null)
            ) {
                weatherTemperatureText = Lang.format("$1$\u00B0", [ (conditions.temperature as Number).format("%.0f") ]);
                hasWeatherTemperatureText = true;
                return weatherTemperatureText;
            }
        } catch (ex) {
        }

        return weatherTemperatureText;
    }

    private function getBackgroundBitmap(mood as Number) as BitmapResource? {
        if ((activeBackgroundBitmap != null) && (activeBackgroundMood == mood)) {
            return activeBackgroundBitmap;
        }

        if (mood == MOOD_PROUD) {
            activeBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftProud) as BitmapResource;
        } else if ((mood == MOOD_SOFT) || (mood == MOOD_SLEEPY)) {
            activeBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftSleepy) as BitmapResource;
        } else {
            activeBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftHappy) as BitmapResource;
        }

        activeBackgroundMood = mood;
        return activeBackgroundBitmap;
    }

    private function rememberDrawnState(clock, dateInfo, mood as Number) as Void {
        lastDrawnMinute = clock.min;
        lastDrawnDay = dateInfo.day as Number;
        lastDrawnMonth = dateInfo.month as Number;
        lastDrawnMood = mood;
        lastDrawnCelebrationType = activeCelebrationType;
    }

    private function haveMetricRowsChanged(stepsText as String, weeklyText as String, weatherText as String, resourceMetricsDrawn as Boolean, showStepGoalMark as Boolean) as Boolean {
        return (
            (stepsText != lastDrawnStepsText) ||
            (weeklyText != lastDrawnWeeklyText) ||
            (weatherText != lastDrawnWeatherText) ||
            (resourceMetricsDrawn != lastDrawnResourceMetrics) ||
            (showStepGoalMark != lastDrawnStepGoalMark)
        );
    }

    private function rememberDrawnMetrics(stepsText as String, weeklyText as String, weatherText as String, resourceMetricsDrawn as Boolean, showStepGoalMark as Boolean) as Void {
        lastDrawnStepsText = stepsText;
        lastDrawnWeeklyText = weeklyText;
        lastDrawnWeatherText = weatherText;
        lastDrawnResourceMetrics = resourceMetricsDrawn;
        lastDrawnStepGoalMark = showStepGoalMark;
    }

    private function getTextColor(mood as Number) as Number {
        if ((mood == MOOD_PROUD) || (mood == MOOD_NEUTRAL)) {
            return Graphics.COLOR_BLACK;
        }

        return Graphics.COLOR_WHITE;
    }

    private function choosePrototypeMood(steps as Number) as Number {
        updateStepCelebration(steps);

        if (isCelebrationActive()) {
            return MOOD_PROUD;
        }

        var clock = System.getClockTime();

        if (clock.hour < 9) {
            return MOOD_SLEEPY;
        } else if (clock.hour >= 18 && clock.hour < 20) {
            return MOOD_PROUD;
        } else if ((clock.hour > 21) || ((clock.hour == 21) && (clock.min >= 30))) {
            return MOOD_SLEEPY;
        }

        return MOOD_NEUTRAL;
    }

    private function updateStepCelebration(steps as Number) as Void {
        if (isCelebrationActive()) {
            return;
        }

        var stepGoal = getStepTarget();

        if ((stepGoal <= 0) || (steps < stepGoal) || hasStepCelebrationShownToday()) {
            return;
        }

        activeCelebrationType = CELEBRATION_STEPS;
        celebrationStartedAt = Time.now();
        markStepCelebrationShownToday();
    }

    private function isCelebrationActive() as Boolean {
        if ((activeCelebrationType == CELEBRATION_NONE) || (celebrationStartedAt == null)) {
            return false;
        }

        var elapsed = Time.now().subtract(celebrationStartedAt as Time.Moment).value();

        if (elapsed < CELEBRATION_WINDOW_SECONDS) {
            return true;
        }

        activeCelebrationType = CELEBRATION_NONE;
        celebrationStartedAt = null;
        return false;
    }

    private function hasStepCelebrationShownToday() as Boolean {
        try {
            return Storage.getValue(STEP_CELEBRATION_STORAGE_KEY) == getTodayStorageDate();
        } catch (ex) {
        }

        return false;
    }

    private function markStepCelebrationShownToday() as Void {
        try {
            Storage.setValue(STEP_CELEBRATION_STORAGE_KEY, getTodayStorageDate());
        } catch (ex) {
        }
    }

    private function getTodayStorageDate() as String {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        return Lang.format(
            "$1$-$2$-$3$",
            [
                (info.year as Number).format("%04d"),
                (info.month as Number).format("%02d"),
                (info.day as Number).format("%02d")
            ]
        );
    }

    private function getSteps() as Number {
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var todayDay = today.day as Number;
        var todayMonth = today.month as Number;

        try {
            var info = getActivityInfo();

            if ((info != null) && (info has :steps) && (info.steps != null)) {
                cachedSteps = info.steps as Number;
                cachedStepsDay = todayDay;
                cachedStepsMonth = todayMonth;
                hasCachedSteps = true;
                return cachedSteps;
            }
        } catch (ex) {
        }

        if (hasCachedSteps && (cachedStepsDay == todayDay) && (cachedStepsMonth == todayMonth)) {
            return cachedSteps;
        }

        return 0;
    }

    private function getStepsText(steps as Number) as String {
        stepsText = formatSteps(steps);

        return stepsText;
    }

    private function getStepGoal() as Number {
        try {
            var info = getActivityInfo();

            if ((info != null) && (info has :stepGoal) && (info.stepGoal != null)) {
                stepGoal = info.stepGoal as Number;
                hasStepGoal = true;
                return stepGoal;
            }
        } catch (ex) {
        }

        if (hasStepGoal) {
            return stepGoal;
        }

        return 0;
    }

    private function getStepTarget() as Number {
        var currentStepGoal = getStepGoal();

        if (currentStepGoal > 0) {
            return currentStepGoal;
        }

        return STEP_GOAL_FALLBACK_STEPS;
    }

    private function hasReachedStepTarget(steps as Number) as Boolean {
        return steps >= getStepTarget();
    }

    private function getActivityInfo() {
        var cacheMinute = (Time.now().value() / 60).toNumber();

        if ((activityInfoCacheMinute == cacheMinute) && (activityInfoCache != null)) {
            return activityInfoCache;
        }

        activityInfoCacheMinute = cacheMinute;
        activityInfoCache = ActivityMonitor.getInfo();

        return activityInfoCache;
    }
}
