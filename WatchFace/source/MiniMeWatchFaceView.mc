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

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        happyBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftHappy) as BitmapResource;
        proudBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftProud) as BitmapResource;
        sleepyBackgroundBitmap = WatchUi.loadResource(Rez.Drawables.BgAvatarBottomLeftSleepy) as BitmapResource;
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

        var timeY = (height * 0.26).toNumber();
        var timeX = (centerX + (height * 0.14)).toNumber();

        drawShadowText(dc, timeX, timeY, Graphics.FONT_NUMBER_HOT, timeText, 0xFFFFFF, 0x197DC5, 4);
    }

    private function drawActivityRows(dc as Dc, width as Number, height as Number) as Void {
        var iconX = (width * 0.52).toNumber();
        var labelX = (width * 0.61).toNumber();
        var valueX = (width * 0.90).toNumber();
        var topY = (height * 0.45).toNumber();
        var rowGap = (height * 0.118).toNumber();
        var lineLeft = (width * 0.60).toNumber();
        var lineRight = (width * 0.94).toNumber();

        drawMetricRow(dc, iconX, labelX, valueX, topY, "HR", "72", 0xFF4E4A, 0);
        drawDivider(dc, lineLeft, lineRight, topY + (rowGap / 2));
        drawMetricRow(dc, iconX, labelX, valueX, topY + rowGap, "STEPS", formatSteps(getSteps()), 0x36B94C, 1);
        drawDivider(dc, lineLeft, lineRight, topY + rowGap + (rowGap / 2));
        drawMetricRow(dc, iconX, labelX, valueX, topY + (rowGap * 2), "WEATHER", "18\u00B0", 0x178FDD, 2);
        drawDivider(dc, lineLeft, lineRight, topY + (rowGap * 2) + (rowGap / 2));
        drawMetricRow(dc, iconX, labelX, valueX, topY + (rowGap * 3), "BAT", getBatteryText(), 0xF7B927, 3);
    }

    private function drawMetricRow(dc as Dc, iconX as Number, labelX as Number, valueX as Number, y as Number, label as String, value as String, color as Number, iconType as Number) as Void {
        dc.setColor(0xFFFFFF, 0xFFFFFF);
        dc.fillCircle(iconX, y, 22);
        dc.setColor(color, color);
        dc.fillCircle(iconX, y, 18);
        drawMetricIcon(dc, iconX, y, iconType);

        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            labelX,
            y,
            Graphics.FONT_SYSTEM_MEDIUM,
            label,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            valueX,
            y,
            Graphics.FONT_NUMBER_MEDIUM,
            value,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawDivider(dc as Dc, x1 as Number, x2 as Number, y as Number) as Void {
        dc.setColor(0x65D7F4, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(x1, y, x2, y);
        dc.setPenWidth(1);
    }

    private function drawMetricIcon(dc as Dc, x as Number, y as Number, iconType as Number) as Void {
        if (iconType == 0) {
            dc.setColor(0xFFFFFF, 0xFFFFFF);
            dc.fillCircle(x - 6, y - 4, 7);
            dc.fillCircle(x + 6, y - 4, 7);
            dc.fillPolygon([
                [ x - 13, y - 2 ],
                [ x + 13, y - 2 ],
                [ x, y + 13 ]
            ]);
        } else if (iconType == 1) {
            dc.setColor(0xFFFFFF, 0xFFFFFF);
            dc.fillEllipse(x - 8, y - 12, 7, 14);
            dc.fillEllipse(x + 3, y - 11, 7, 14);
            dc.fillEllipse(x - 2, y + 4, 7, 11);
            dc.fillEllipse(x + 10, y + 2, 7, 11);
        } else if (iconType == 2) {
            dc.setColor(0xFFD84E, 0xFFD84E);
            dc.fillCircle(x + 5, y - 6, 8);
            dc.setColor(0xFFFFFF, 0xFFFFFF);
            dc.fillCircle(x - 6, y + 2, 8);
            dc.fillCircle(x + 4, y + 1, 10);
            dc.fillRectangle(x - 11, y + 1, 24, 8);
        } else {
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(3);
            dc.drawRectangle(x - 12, y - 7, 21, 14);
            dc.fillRectangle(x - 8, y - 3, 14, 7);
            dc.fillRectangle(x + 11, y - 3, 4, 6);
            dc.setPenWidth(1);
        }
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
        if (steps >= 1000) {
            var thousands = (steps / 1000).toNumber();
            var remainder = (steps % 1000).toNumber();

            return Lang.format("$1$,$2$", [ thousands.format("%d"), remainder.format("%03d") ]);
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
