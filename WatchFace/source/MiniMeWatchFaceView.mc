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

    private const BACKGROUND_SIZE = 580;
    private var happyBackgroundBitmap as BitmapResource?;
    private var proudBackgroundBitmap as BitmapResource?;
    private var sleepyBackgroundBitmap as BitmapResource?;
    private var stepsIconBitmap as BitmapResource?;
    private var weatherIconBitmap as BitmapResource?;
    private var weeklyRunningDistanceIconBitmap as BitmapResource?;
    private var weeklyRunningDistanceCacheMinute as Number = -1;
    private var weeklyRunningDistanceText as String = "--";

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        happyBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftHappy) as BitmapResource;
        proudBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftProud) as BitmapResource;
        sleepyBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftSleepy) as BitmapResource;
        stepsIconBitmap = WatchUi.loadResource(Rez.Drawables.IconSteps) as BitmapResource;
        weatherIconBitmap = WatchUi.loadResource(Rez.Drawables.IconWeather) as BitmapResource;
        weeklyRunningDistanceIconBitmap = WatchUi.loadResource(Rez.Drawables.IconWeeklyRunningDistance) as BitmapResource;
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        drawFace(dc);
    }

    function onPartialUpdate(dc as Dc) as Void {
        drawFace(dc);
    }

    function onHide() as Void {
    }

    private function drawFace(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var mood = choosePrototypeMood();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawBackground(dc, width, height, mood);
        drawDateAndTime(dc, centerX, height, mood);
        drawActivityRows(dc, width, height, mood);
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

    private function drawDateAndTime(dc as Dc, centerX as Number, height as Number, mood as Number) as Void {
        var clock = System.getClockTime();
        var timeText = Lang.format(
            "$1$:$2$",
            [ clock.hour.format("%02d"), clock.min.format("%02d") ]
        );

        var timeY = (height * 0.27).toNumber();
        var timeX = (centerX + (height * 0.04)).toNumber();
        var textColor = getTextColor(mood);
        var shadowColor = (mood == MOOD_PROUD) ? 0xFFFFFF : 0x197DC5;

        drawShadowText(dc, timeX, timeY, Graphics.FONT_NUMBER_HOT, timeText, textColor, shadowColor, 4);
    }

    private function drawActivityRows(dc as Dc, width as Number, height as Number, mood as Number) as Void {
        var clusterOffsetX = (width * 0.035).toNumber();
        var clusterOffsetY = (height * 0.05).toNumber();
        var proudOffsetX = (mood == MOOD_PROUD) ? (width * 0.075).toNumber() : 0;
        var iconX = (width * 0.535).toNumber() - clusterOffsetX + proudOffsetX;
        var valueX = (width * 0.585).toNumber() - clusterOffsetX + proudOffsetX;
        var topY = (height * 0.52).toNumber() - clusterOffsetY;
        var rowGap = (height * 0.13).toNumber();
        var textColor = getTextColor(mood);

        drawMetricRow(dc, iconX, valueX, topY, formatSteps(getSteps()), textColor, 0);
        drawMetricRow(dc, iconX, valueX, topY + rowGap, getWeeklyRunningDistanceText(), textColor, 2);
        drawMetricRow(dc, iconX, valueX, topY + (rowGap * 2), getWeatherTemperatureText(), textColor, 1);
    }

    private function drawMetricRow(dc as Dc, iconX as Number, valueX as Number, y as Number, value as String, color as Number, iconType as Number) as Void {
        drawMetricIcon(dc, iconX, y, iconType);

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
            return stepsIconBitmap;
        } else if (iconType == 1) {
            return weatherIconBitmap;
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
        try {
            if (!(Weather has :getCurrentConditions)) {
                return "--\u00B0";
            }

            var conditions = Weather.getCurrentConditions();

            if (
                (conditions != null) &&
                (conditions has :temperature) &&
                (conditions.temperature != null)
            ) {
                return Lang.format("$1$\u00B0", [ (conditions.temperature as Number).format("%.0f") ]);
            }
        } catch (ex) {
        }

        return "--\u00B0";
    }

    private function getBackgroundBitmap(mood as Number) as BitmapResource? {
        if (mood == MOOD_PROUD) {
            return proudBackgroundBitmap;
        } else if (mood == MOOD_SOFT) {
            return sleepyBackgroundBitmap;
        } else if (mood == MOOD_SLEEPY) {
            return sleepyBackgroundBitmap;
        }

        return happyBackgroundBitmap;
    }

    private function getTextColor(mood as Number) as Number {
        if (mood == MOOD_PROUD) {
            return Graphics.COLOR_BLACK;
        }

        return Graphics.COLOR_WHITE;
    }

    private function choosePrototypeMood() as Number {
        var clock = System.getClockTime();

        if (clock.hour < 9) {
            return MOOD_SLEEPY;
        } else if (clock.hour >= 18 && clock.hour < 20) {
            return MOOD_PROUD;
        } else if (clock.hour >= 22 || clock.hour < 6) {
            return MOOD_SOFT;
        }

        return MOOD_NEUTRAL;
    }

    private function getSteps() as Number {
        try {
            var info = ActivityMonitor.getInfo();

            if ((info != null) && (info has :steps) && (info.steps != null)) {
                return info.steps as Number;
            }
        } catch (ex) {
        }

        return 0;
    }
}
