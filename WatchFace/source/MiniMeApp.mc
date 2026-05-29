import Toybox.Application;
import Toybox.WatchUi;

class MiniMeApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new MiniMeWatchFaceView() ];
    }
}
