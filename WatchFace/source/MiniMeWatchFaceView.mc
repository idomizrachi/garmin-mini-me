import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class MiniMeWatchFaceView extends WatchUi.WatchFace {
    private const MOOD_NEUTRAL = 0;
    private const MOOD_PROUD = 1;
    private const MOOD_SOFT = 2;
    private const MOOD_SLEEPY = 3;

    private const MONTHS = [
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        drawFace(dc, false);
    }

    function onPartialUpdate(dc as Dc) as Void {
        drawFace(dc, true);
    }

    function onHide() as Void {
    }

    private function drawFace(dc as Dc, lowPower as Boolean) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawTime(dc, centerX, height);
        drawMiniIdo(dc, centerX, height, choosePrototypeMood(), lowPower);
        drawPeripheralData(dc, width, height);
    }

    private function drawTime(dc as Dc, centerX as Number, height as Number) as Void {
        var clock = System.getClockTime();
        var timeText = Lang.format(
            "$1$:$2$",
            [ clock.hour.format("%02d"), clock.min.format("%02d") ]
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.30).toNumber(),
            Graphics.FONT_NUMBER_HOT,
            timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawPeripheralData(dc as Dc, width as Number, height as Number) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateText = Lang.format("$1$ $2$", [ now.day, MONTHS[now.month - 1] ]);
        var stepsText = Lang.format("$1$ STEPS", [ getSteps().format("%d") ]);

        dc.setColor(0x8FD8FF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            (height * 0.69).toNumber(),
            Graphics.FONT_XTINY,
            dateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            (height * 0.78).toNumber(),
            Graphics.FONT_SMALL,
            stepsText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(0x5E6A78, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            (height * 0.87).toNumber(),
            Graphics.FONT_XTINY,
            "WEEK --.- KM",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawMiniIdo(dc as Dc, centerX as Number, height as Number, mood as Number, lowPower as Boolean) as Void {
        var bodyY = (height * 0.52).toNumber();
        var color = 0x35D06F;
        var accent = 0xFF4FA3;
        var label = "NEUTRAL";

        if (mood == MOOD_PROUD) {
            color = 0xFFD43B;
            accent = 0x35D06F;
            label = "PROUD";
        } else if (mood == MOOD_SOFT) {
            color = 0x7E93A8;
            accent = 0x8FD8FF;
            label = "SOFT";
        } else if (mood == MOOD_SLEEPY) {
            color = 0x8FD8FF;
            accent = 0xC9A7FF;
            label = "SLEEPY";
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, bodyY - 22, 16);
        dc.fillRoundedRectangle(centerX - 17, bodyY - 8, 34, 44, 8);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX - 6, bodyY - 25, 2);
        dc.fillCircle(centerX + 6, bodyY - 25, 2);

        dc.setColor(accent, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(centerX - 20, bodyY + 37, 12, 18);
        dc.fillRectangle(centerX + 8, bodyY + 37, 12, 18);
        dc.drawLine(centerX - 17, bodyY + 4, centerX - 34, bodyY + 20);
        dc.drawLine(centerX + 17, bodyY + 4, centerX + 34, bodyY + 20);

        if (mood == MOOD_PROUD) {
            drawSign(dc, centerX + 50, bodyY - 38, "NICE");
        } else if (mood == MOOD_SLEEPY) {
            drawSign(dc, centerX + 45, bodyY - 42, "Z Z");
        }

        dc.setColor(0x5E6A78, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            bodyY + 68,
            Graphics.FONT_XTINY,
            label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawSign(dc as Dc, x as Number, y as Number, text as String) as Void {
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x - 24, y - 12, 48, 24, 4);
        dc.setColor(0x11151A, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            y,
            Graphics.FONT_XTINY,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
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
            return 10000;
        } catch (ex) {
        }

        return 0;
    }
}
