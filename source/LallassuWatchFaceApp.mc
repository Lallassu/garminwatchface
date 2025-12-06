using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Application.Properties;

class LallassuWatchFaceApp extends App.AppBase {

    private var view;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        view = new LallassuWatchFaceView();
        return [ view ];
    }

    function onSettingsChanged() {
        if (view != null) {
            view.onSettingsChanged();
        }
    }

    function getSettingsView() {
        return [new SettingsMenu(), new SettingsMenuDelegate()];
    }

}
