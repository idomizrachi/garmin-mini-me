import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MiniMeWatchFaceView extends WatchUi.WatchFace {
    private const MOOD_NEUTRAL = 0;
    private const MOOD_PROUD = 1;
    private const MOOD_SOFT = 2;
    private const MOOD_SLEEPY = 3;

    private const BACKGROUND_SIZE = 580;
    private const EDGE_RING_INSET = 18;

    private var happyBackgroundBitmap as BitmapResource?;
    private var proudBackgroundBitmap as BitmapResource?;
    private var sleepyBackgroundBitmap as BitmapResource?;
    private var stepsIconBitmap as BitmapResource?;
    private var weatherIconBitmap as BitmapResource?;
    private var batteryIconBitmap as BitmapResource?;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        happyBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftHappy) as BitmapResource;
        proudBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftProud) as BitmapResource;
        sleepyBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftSleepy) as BitmapResource;
        stepsIconBitmap = WatchUi.loadResource(Rez.Drawables.IconSteps) as BitmapResource;
        weatherIconBitmap = WatchUi.loadResource(Rez.Drawables.IconWeather) as BitmapResource;
        batteryIconBitmap = WatchUi.loadResource(Rez.Drawables.IconBattery) as BitmapResource;
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
        drawDateAndTime(dc, centerX, height);
        drawActivityRows(dc, width, height);
        drawEdgeProgress(dc, width, height, centerX);
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

    private function drawDateAndTime(dc as Dc, centerX as Number, height as Number) as Void {
        var clock = System.getClockTime();
        var timeText = Lang.format(
            "$1$:$2$",
            [ clock.hour.format("%02d"), clock.min.format("%02d") ]
        );

        var timeY = (height * 0.27).toNumber();
        var timeX = (centerX + (height * 0.04)).toNumber();

        drawShadowText(dc, timeX, timeY, Graphics.FONT_NUMBER_HOT, timeText, 0xFFFFFF, 0x197DC5, 4);
    }

    private function drawActivityRows(dc as Dc, width as Number, height as Number) as Void {
        var clusterOffsetX = (width * 0.035).toNumber();
        var clusterOffsetY = (height * 0.05).toNumber();
        var iconX = (width * 0.535).toNumber() - clusterOffsetX;
        var labelX = (width * 0.585).toNumber() - clusterOffsetX;
        var valueX = (width * 0.79).toNumber() - clusterOffsetX;
        var topY = (height * 0.52).toNumber() - clusterOffsetY;
        var rowGap = (height * 0.13).toNumber();

        drawMetricRow(dc, iconX, labelX, valueX, topY, "Step", formatSteps(getSteps()), 0x36B94C, 0);
        drawMetricRow(dc, iconX, labelX, valueX, topY + rowGap, "Temp", "18\u00B0", 0x178FDD, 1);
        drawMetricRow(dc, iconX, labelX, valueX, topY + (rowGap * 2), "Bat", getBatteryText(), 0xF7B927, 2);
    }

    private function drawMetricRow(dc as Dc, iconX as Number, labelX as Number, valueX as Number, y as Number, label as String, value as String, color as Number, iconType as Number) as Void {
        drawMetricIcon(dc, iconX, y, iconType);

        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        drawBoldText(dc, labelX, y, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        drawBoldText(dc, valueX, y, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
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

        return batteryIconBitmap;
    }

    private function drawEdgeProgress(dc as Dc, width as Number, height as Number, centerX as Number) as Void {
        var centerY = height / 2;
        var radius = (width / 2) - EDGE_RING_INSET;

        dc.setPenWidth(13);
        dc.setColor(0xCDEB56, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, radius, Graphics.ARC_COUNTER_CLOCKWISE, 188, 318);
        dc.setColor(0x48CDEB, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, radius, Graphics.ARC_COUNTER_CLOCKWISE, 318, 354);

        dc.setPenWidth(1);
        dc.setColor(0xF4FBFF, 0xF4FBFF);
        dc.fillCircle((width * 0.74).toNumber(), (height * 0.12).toNumber(), 8);
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

    private function getBatteryText() as String {
        try {
            var stats = System.getSystemStats();

            if ((stats != null) && (stats has :battery) && (stats.battery != null)) {
                return Lang.format("$1$%", [ (stats.battery + 0.5).toNumber().format("%d") ]);
            }
        } catch (ex) {
        }

        return "--%";
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
