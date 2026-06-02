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
    private const STARTUP_FAST_FRAMES = 2;
    private const CELEBRATION_WINDOW_SECONDS = 1800;
    private const STEP_CELEBRATION_STORAGE_KEY = "miniMe.stepCelebratedDate";
    private var activeBackgroundBitmap as BitmapResource?;
    private var activeBackgroundMood as Number = -1;
    private var activeCelebrationType as Number = CELEBRATION_NONE;
    private var celebrationStartedAt as Time.Moment?;
    private var stepsIconBitmap as BitmapResource?;
    private var weatherIconBitmap as BitmapResource?;
    private var weeklyRunningDistanceIconBitmap as BitmapResource?;
    private var activityInfoCacheMinute as Number = -1;
    private var activityInfoCache = null;
    private var weeklyRunningDistanceCacheMinute as Number = -1;
    private var weeklyRunningDistanceText as String = "--";
    private var weatherCacheMinute as Number = -1;
    private var weatherTemperatureText as String = "--\u00B0";
    private var firstFullFaceDrawn as Boolean = false;
    private var startupFastFrameCount as Number = 0;
    private var lastDrawnMinute as Number = -1;
    private var lastDrawnDay as Number = -1;
    private var lastDrawnMonth as Number = -1;
    private var lastDrawnMood as Number = -1;
    private var lastDrawnCelebrationType as Number = CELEBRATION_NONE;
    private var lastDrawnStepsText as String = "";
    private var lastDrawnWeeklyText as String = "";
    private var lastDrawnWeatherText as String = "";
    private var lastDrawnResourceMetrics as Boolean = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        if (startupFastFrameCount < STARTUP_FAST_FRAMES) {
            drawFastFirstPaint(dc);
            startupFastFrameCount++;
            WatchUi.requestUpdate();
            return;
        }

        drawFace(dc);
    }

    function onPartialUpdate(dc as Dc) as Void {
        if (startupFastFrameCount < STARTUP_FAST_FRAMES) {
            drawFastFirstPaint(dc);
            startupFastFrameCount++;
            WatchUi.requestUpdate();
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
        var stepsText = formatSteps(steps);
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
            stepsText,
            weeklyText,
            weatherText,
            shouldDrawResourceMetrics
        );
        drawCelebrationTreatment(dc, width, height, mood);
        rememberDrawnState(clock, dateInfo, mood);
        rememberDrawnMetrics(stepsText, weeklyText, weatherText, shouldDrawResourceMetrics);

        if (!firstFullFaceDrawn) {
            WatchUi.requestUpdate();
        }

        firstFullFaceDrawn = true;
    }

    private function drawFastFirstPaint(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var clock = System.getClockTime();
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        fillFallbackBackground(dc, width, height, MOOD_SLEEPY);
        drawDateAndTime(dc, centerX, height, MOOD_SLEEPY, clock, dateInfo);

        if (startupFastFrameCount > 0) {
            var stepsText = formatSteps(getSteps());

            drawActivityRows(
                dc,
                width,
                height,
                MOOD_SLEEPY,
                stepsText,
                weeklyRunningDistanceText,
                weatherTemperatureText,
                false
            );
            rememberDrawnMetrics(stepsText, weeklyRunningDistanceText, weatherTemperatureText, false);
        }

        rememberDrawnState(clock, dateInfo, MOOD_SLEEPY);
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
        var mood = choosePrototypeMood(getSteps());
        var clock = System.getClockTime();
        var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var stepsText = formatSteps(getSteps());
        var weeklyText = getWeeklyRunningDistanceText();
        var weatherText = getWeatherTemperatureText();
        var metricsChanged = haveMetricRowsChanged(stepsText, weeklyText, weatherText, true);

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
            drawActivityRowsRegion(dc, width, height, mood, stepsText, weeklyText, weatherText, true);
            rememberDrawnMetrics(stepsText, weeklyText, weatherText, true);
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

    private function drawActivityRowsRegion(dc as Dc, width as Number, height as Number, mood as Number, stepsText as String, weeklyText as String, weatherText as String, shouldDrawIcons as Boolean) as Void {
        var regionX = (width * 0.46).toNumber();
        var regionY = (height * 0.40).toNumber();
        var regionWidth = (width * 0.48).toNumber();
        var regionHeight = (height * 0.39).toNumber();

        dc.setClip(regionX, regionY, regionWidth, regionHeight);
        drawBackground(dc, width, height, mood);
        drawActivityRows(dc, width, height, mood, stepsText, weeklyText, weatherText, shouldDrawIcons);
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

    private function drawActivityRows(dc as Dc, width as Number, height as Number, mood as Number, stepsText as String, weeklyText as String, weatherText as String, shouldDrawIcons as Boolean) as Void {
        var clusterOffsetX = (width * 0.035).toNumber();
        var clusterOffsetY = (height * 0.05).toNumber();
        var proudOffsetX = (mood == MOOD_PROUD) ? (width * 0.075).toNumber() : 0;
        var iconX = (width * 0.535).toNumber() - clusterOffsetX + proudOffsetX;
        var valueX = (width * 0.585).toNumber() - clusterOffsetX + proudOffsetX;
        var topY = (height * 0.52).toNumber() - clusterOffsetY;
        var rowGap = (height * 0.13).toNumber();
        var textColor = getTextColor(mood);

        drawMetricRow(dc, iconX, valueX, topY, stepsText, textColor, 0, shouldDrawIcons);
        drawMetricRow(dc, iconX, valueX, topY + rowGap, weeklyText, textColor, 2, shouldDrawIcons);
        drawMetricRow(dc, iconX, valueX, topY + (rowGap * 2), weatherText, textColor, 1, shouldDrawIcons);
    }

    private function drawCelebrationTreatment(dc as Dc, width as Number, height as Number, mood as Number) as Void {
        if ((activeCelebrationType != CELEBRATION_STEPS) || (mood != MOOD_PROUD)) {
            return;
        }

        var signX = (width * 0.10).toNumber();
        var signY = (height * 0.57).toNumber();
        var signWidth = (width * 0.30).toNumber();
        var signHeight = (height * 0.10).toNumber();
        var textX = signX + (signWidth / 2);
        var textY = signY + (signHeight / 2);

        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(signX, signY, signWidth, signHeight);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(signX, signY, signWidth, signHeight);
        drawBoldText(dc, textX, textY, Graphics.FONT_TINY, "STEP GOAL", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawMetricRow(dc as Dc, iconX as Number, valueX as Number, y as Number, value as String, color as Number, iconType as Number, shouldDrawIcon as Boolean) as Void {
        if (shouldDrawIcon) {
            drawMetricIcon(dc, iconX, y, iconType);
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        drawBoldText(dc, valueX, y, Graphics.FONT_TINY, value, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
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

        if (weeklyRunningDistanceCacheMinute == cacheMinute) {
            return weeklyRunningDistanceText;
        }

        weeklyRunningDistanceCacheMinute = cacheMinute;
        weeklyRunningDistanceText = formatDistance(getWeeklyRunningDistanceMeters());

        return weeklyRunningDistanceText;
    }

    private function getWeeklyRunningDistanceMeters() as Number {
        var recordedRunTotal = getWeeklyRecordedRunningDistanceMeters();

        if (recordedRunTotal > 0) {
            return recordedRunTotal;
        }

        return getWeeklyActivityMonitorDistanceMeters();
    }

    private function getWeeklyRecordedRunningDistanceMeters() as Number {
        var total = 0;

        try {
            if (!(UserProfile has :getUserActivityHistory)) {
                return total;
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
        }

        return total;
    }

    private function getWeeklyActivityMonitorDistanceMeters() as Number {
        var total = 0;

        try {
            var history = ActivityMonitor.getHistory();
            var weekStart = getStartOfWeek();
            var i = 0;

            while ((history != null) && (i < history.size())) {
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

        if ((weatherCacheMinute >= 0) && ((cacheMinute - weatherCacheMinute) < 15)) {
            return weatherTemperatureText;
        }

        weatherCacheMinute = cacheMinute;

        try {
            if (!(Weather has :getCurrentConditions)) {
                weatherTemperatureText = "--\u00B0";
                return weatherTemperatureText;
            }

            var conditions = Weather.getCurrentConditions();

            if (
                (conditions != null) &&
                (conditions has :temperature) &&
                (conditions.temperature != null)
            ) {
                weatherTemperatureText = Lang.format("$1$\u00B0", [ (conditions.temperature as Number).format("%.0f") ]);
                return weatherTemperatureText;
            }
        } catch (ex) {
        }

        weatherTemperatureText = "--\u00B0";
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

    private function haveMetricRowsChanged(stepsText as String, weeklyText as String, weatherText as String, resourceMetricsDrawn as Boolean) as Boolean {
        return (
            (stepsText != lastDrawnStepsText) ||
            (weeklyText != lastDrawnWeeklyText) ||
            (weatherText != lastDrawnWeatherText) ||
            (resourceMetricsDrawn != lastDrawnResourceMetrics)
        );
    }

    private function rememberDrawnMetrics(stepsText as String, weeklyText as String, weatherText as String, resourceMetricsDrawn as Boolean) as Void {
        lastDrawnStepsText = stepsText;
        lastDrawnWeeklyText = weeklyText;
        lastDrawnWeatherText = weatherText;
        lastDrawnResourceMetrics = resourceMetricsDrawn;
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

        var stepGoal = getStepGoal();

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
        try {
            var info = getActivityInfo();

            if ((info != null) && (info has :steps) && (info.steps != null)) {
                return info.steps as Number;
            }
        } catch (ex) {
        }

        return 0;
    }

    private function getStepGoal() as Number {
        try {
            var info = getActivityInfo();

            if ((info != null) && (info has :stepGoal) && (info.stepGoal != null)) {
                return info.stepGoal as Number;
            }
        } catch (ex) {
        }

        return 0;
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
