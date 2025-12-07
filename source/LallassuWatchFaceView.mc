using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Math;
using Toybox.Time.Gregorian as Calendar;
using Toybox.ActivityMonitor as Act;
using Toybox.Activity as Activity;
using Toybox.Weather as Weather;
using Toybox.SensorHistory as SensorHistory;
using Toybox.Application as App; 
using Toybox.Lang;
using Toybox.Application;
using Toybox.Application.Properties;
using Toybox.Application.Storage;

class LallassuWatchFaceView extends Ui.WatchFace {
    private const timeColor = 0xFFFFFF;
    private const WEATHER_INFO = {} as Lang.Dictionary;

    private var width = 0;
    private var height = 0;
    private var centerX = 0; 
    private var centerY = 0;
    private var scale = 1.0; // Scale factor for layout (1.0 for 260x260, ~0.838 for 218x218)
    private var isFr255sm = false; // Track if we're on the smaller screen
    private var batteryIcon;
    private var caloriesIcon;
    private var heartIcon;
    private var kmIcon;
    private var recoveryIcon;
    private var stepsIcon;
    private var stressIcon;
    private var msgIcon;
    private var iconScale = 0.5;
    private var ui;

    // Configurable colors - can be set individually or via theme presets
    private var backgroundColor = Gfx.COLOR_BLACK;
    private var iconTintColor = Gfx.COLOR_WHITE;
    private var uiTintColor = Gfx.COLOR_WHITE;
    private var textDefaultColor = Gfx.COLOR_WHITE;
    private var currentTheme = 0; // Current theme index (0-9)

    // These are only fetched periodically, to reduce load
    private var batteryTxt = "";
    private var dateTxt = "";
    private var weatherTxt = "";
    private var stressTxt = "";
    private var sunTxt = "";
    private var tempTxt = "";
    private var stepsTxt = "";
    private var distTxt = "";
    private var calsTxt = "";
    private var recoveryTxt = "";
    private var windTxt = "";
    private var bodyBatteryTxt = "";
    private var heartTxt = "";
    private var hasNotification = false;

    private var stressColor = Gfx.COLOR_WHITE;
    private var recoveryColor = Gfx.COLOR_WHITE;
    private var tempColor = Gfx.COLOR_WHITE;
    private var windColor = Gfx.COLOR_WHITE;
    private var bodyBatteryColor = Gfx.COLOR_WHITE;
    private var weatherColor = Gfx.COLOR_WHITE;
    private var stepsColor = Gfx.COLOR_WHITE;
    private var heartColor = Gfx.COLOR_WHITE;
    private var distColor = Gfx.COLOR_WHITE;
    private var dateColor = Gfx.COLOR_WHITE;
    private var sunColor = Gfx.COLOR_WHITE;

    function initialize() {
        WEATHER_INFO[0] = ["Clear", 0x87CEEB];
        WEATHER_INFO[1] = ["Partly cloudy", 0xB0C4DE];
        WEATHER_INFO[2] = ["Mostly cloudy", 0xA9A9A9];
        WEATHER_INFO[3] = ["Rain", 0x1E90FF];
        WEATHER_INFO[4] = ["Snow", 0xFFFFFF];
        WEATHER_INFO[5] = ["Windy", 0xADD8E6];
        WEATHER_INFO[6] = ["Thunder", 0x4B0082];
        WEATHER_INFO[7] = ["Wintry mix", 0xAFEEEE];
        WEATHER_INFO[8] = ["Fog", 0xC0C0C0];
        WEATHER_INFO[9] = ["Hazy", 0xD3D3D3];
        WEATHER_INFO[10] = ["Hail", 0xE0FFFF];
        WEATHER_INFO[11] = ["Showers", 0x5F9EA0];
        WEATHER_INFO[12] = ["Thunder", 0x483D8B];
        WEATHER_INFO[13] = ["precipitation", 0x808080];
        WEATHER_INFO[14] = ["Light rain", 0x87CEFA];
        WEATHER_INFO[15] = ["Heavy rain", 0x00008B];
        WEATHER_INFO[16] = ["Light snow", 0xF0FFFF];
        WEATHER_INFO[17] = ["Heavy snow", 0xF8F8FF];
        WEATHER_INFO[18] = ["Light rain/snow", 0xB0E0E6];
        WEATHER_INFO[19] = ["Heavy rain/snow", 0x87AFC7];
        WEATHER_INFO[20] = ["Cloudy", 0x696969];
        WEATHER_INFO[21] = ["Rain snow", 0xAFC7C7];
        WEATHER_INFO[22] = ["Partly clear", 0xADD8E6];
        WEATHER_INFO[23] = ["Mostly clear", 0x87CEEB];
        WEATHER_INFO[24] = ["Light showers", 0x7EC0EE];
        WEATHER_INFO[25] = ["Showers", 0x4682B4];
        WEATHER_INFO[26] = ["Heavy showers", 0x27408B];
        WEATHER_INFO[27] = ["Chance of showers", 0x5F9EA0];
        WEATHER_INFO[28] = ["Chance of thunder", 0x6A5ACD];
        WEATHER_INFO[29] = ["Mist", 0xE8E8E8];
        WEATHER_INFO[30] = ["Dust", 0xDEB887];
        WEATHER_INFO[31] = ["Drizzle", 0xB0C4DE];
        WEATHER_INFO[32] = ["Tornado", 0x8B0000];
        WEATHER_INFO[33] = ["Smoke", 0x708090];
        WEATHER_INFO[34] = ["Ice", 0xAFEEEE];
        WEATHER_INFO[35] = ["Sand", 0xF4A460];
        WEATHER_INFO[36] = ["Squall", 0x2F4F4F];
        WEATHER_INFO[37] = ["Sandstorm", 0xD2B48C];
        WEATHER_INFO[38] = ["Volcanic ash", 0x4A4A4A];
        WEATHER_INFO[39] = ["Haze", 0xBEBEBE];
        WEATHER_INFO[40] = ["Fair", 0xFFEFD5];
        WEATHER_INFO[41] = ["Hurricane", 0x800000];
        WEATHER_INFO[42] = ["Tropical storm", 0xCD5C5C];
        WEATHER_INFO[43] = ["Chance of snow", 0xF5F5F5];
        WEATHER_INFO[44] = ["Chance of rain/snow", 0xC1CDCD];
        WEATHER_INFO[45] = ["Cloudy chance of rain", 0x708090];
        WEATHER_INFO[46] = ["Cloudy chance of snow", 0xDCDCDC];
        WEATHER_INFO[47] = ["Cloudy chance of rain/snow", 0xB0B0B0];
        WEATHER_INFO[48] = ["Flurries", 0xFFFAFA];
        WEATHER_INFO[49] = ["Freezing rain", 0xB0E0E6];
        WEATHER_INFO[50] = ["Sleet", 0xE0FFFF];
        WEATHER_INFO[51] = ["Ice snow", 0xF0F8FF];
        WEATHER_INFO[52] = ["Thin clouds", 0xCCCCCC];
        WEATHER_INFO[53] = ["Unknown", 0x333333];

        // First update
        setDateTxt();
        setStressTxt();
        setSunTxt();
        setTempTxt();
        setStepsTxt();
        setDistTxt();
        setCalsTxt();
        setRecoveryTxt();
        setWindTxt();
        setBodyBatteryTxt();
        setWeatherTxt();
        setNotification();

        WatchFace.initialize();
        loadSettings();
        loadResources();
    }

    // Load theme settings from storage
    private function loadSettings() as Void {
        // Read from Storage (runtime changes) with fallback to default
        var themeValue = Storage.getValue("Theme");
        if (themeValue == null) {
            // Don't read from Properties, just use default
            themeValue = 0;
        }
        
        // Apply theme preset (sets all colors)
        currentTheme = themeValue;
        applyTheme(themeValue);
        
        // Check for individual color overrides (these override theme settings)
        var bgColorValue = Storage.getValue("BackgroundColor");
        if (bgColorValue != null) {
            backgroundColor = getColorFromIndex(bgColorValue);
        }
        
        var iconColorValue = Storage.getValue("IconColor");
        if (iconColorValue != null) {
            iconTintColor = getColorFromIndex(iconColorValue);
        }
        
        var uiColorValue = Storage.getValue("UIColor");
        if (uiColorValue != null) {
            uiTintColor = getColorFromIndex(uiColorValue);
        }
        
        var textColorValue = Storage.getValue("TextColor");
        if (textColorValue != null) {
            textDefaultColor = getColorFromIndex(textColorValue);
        }
    }
    
    // Apply complete theme with background, icon tint, UI tint, and text colors
    // Themes are presets that set all 4 color settings at once
    // Individual colors can be overridden after theme is applied
    private function applyTheme(index) as Void {
        if (index == null) { index = 0; }
        
        switch (index) {
            case 1: // Arctic Neon - Bright cyan theme
                backgroundColor = 0x001F3F;  // Deep navy
                uiTintColor = 0x0074D9;      // Bright blue
                iconTintColor = 0x00FFFF;    // Cyan
                textDefaultColor = 0xFFFFFF; // White
                break;
                
            case 2: // Solar Flare - Bright orange/yellow theme
                backgroundColor = 0x4A2511;  // Dark brown
                uiTintColor = 0xFF851B;      // Bright orange
                iconTintColor = 0xFFDC00;    // Bright yellow
                textDefaultColor = 0xFFFFFF; // White
                break;
                
            case 3: // Ocean Wave - Bright aqua theme
                backgroundColor = 0x003366;  // Deep blue
                uiTintColor = 0x0099CC;      // Medium cyan
                iconTintColor = 0x00FFCC;    // Bright aqua
                textDefaultColor = 0xFFFFFF; // White
                break;
                
            case 4: // Fire Red - Bold red theme
                backgroundColor = 0x330000;  // Dark red
                uiTintColor = 0xCC0000;      // Bright red
                iconTintColor = 0xFF6600;    // Orange-red
                textDefaultColor = 0xFFFFFF; // White
                break;
                
            case 5: // Lime Punch - Bright green theme
                backgroundColor = 0x1A3300;  // Dark green
                uiTintColor = 0x66CC00;      // Bright lime
                iconTintColor = 0x99FF00;    // Neon lime
                textDefaultColor = 0xFFFFFF; // White
                break;
                
            case 6: // Electric Purple - Bold purple theme
                backgroundColor = 0x2D1B4E;  // Deep purple
                uiTintColor = 0x9933FF;      // Bright purple
                iconTintColor = 0xCC66FF;    // Light purple
                textDefaultColor = 0xFFFFFF; // White
                break;
                
            case 7: // Sunset Gold - Warm orange theme
                backgroundColor = 0x4D2600;  // Dark brown
                uiTintColor = 0xFF9933;      // Gold
                iconTintColor = 0xFFCC00;    // Bright gold
                textDefaultColor = 0xFFFFFF; // White
                break;
                
            case 8: // Mint Flash - Bright mint theme
                backgroundColor = 0x003329;  // Dark teal
                uiTintColor = 0x00CC99;      // Bright teal
                iconTintColor = 0x00FFCC;    // Bright mint
                textDefaultColor = 0xFFFFFF; // White
                break;
                
            case 9: // Hot Pink - Bold magenta theme
                backgroundColor = 0x4D0033;  // Dark magenta
                uiTintColor = 0xFF0099;      // Hot pink
                iconTintColor = 0xFF66CC;    // Light pink
                textDefaultColor = 0xFFFFFF; // White
                break;
                
            default: // Default - Classic black & white
                backgroundColor = Gfx.COLOR_BLACK;
                uiTintColor = Gfx.COLOR_WHITE;
                iconTintColor = Gfx.COLOR_WHITE;
                textDefaultColor = Gfx.COLOR_WHITE;
                break;
        }
    }
    
    // Color palette for individual color settings (used by all 4 color options)
    // Supports 20 colors including both light and dark options
    private function getColorFromIndex(index) as Lang.Number {
        if (index == null) { index = 0; }
        
        var colors = [
            Gfx.COLOR_WHITE,      // 0 - White
            Gfx.COLOR_BLACK,      // 1 - Black
            Gfx.COLOR_LT_GRAY,    // 2 - Light Gray
            Gfx.COLOR_DK_GRAY,    // 3 - Dark Gray
            Gfx.COLOR_RED,        // 4 - Red
            0xFF6B9D,             // 5 - Pink
            0xE65100,             // 6 - Orange
            0xFFC400,             // 7 - Gold/Amber
            0xFFD54F,             // 8 - Yellow
            0x76FF03,             // 9 - Lime Green
            0x1B5E20,             // 10 - Dark Green
            0xC5E1A5,             // 11 - Light Green
            0x00E5FF,             // 12 - Cyan
            0x1A237E,             // 13 - Dark Blue
            0x80DEEA,             // 14 - Light Blue
            0x4A148C,             // 15 - Purple
            0xE040FB,             // 16 - Violet
            0x8B0000,             // 17 - Dark Red
            0x004D40,             // 18 - Teal
            0x64FFDA              // 19 - Mint
        ];
        
        if (index >= 0 && index < colors.size()) {
            return colors[index];
        }
        return Gfx.COLOR_WHITE;
    }

    // Load colored resources based on theme
    private function loadResources() as Void {
        // Load original icons (all themes use same icons, tinted at draw time)
        batteryIcon = App.loadResource(Rez.Drawables.battery);
        caloriesIcon = App.loadResource(Rez.Drawables.calories);
        heartIcon = App.loadResource(Rez.Drawables.heart);
        kmIcon = App.loadResource(Rez.Drawables.km);
        recoveryIcon = App.loadResource(Rez.Drawables.recovery);
        stepsIcon = App.loadResource(Rez.Drawables.steps);
        stressIcon = App.loadResource(Rez.Drawables.stress);
        msgIcon = App.loadResource(Rez.Drawables.msg);
        
        // Load original UI background (same for all themes, transparency allows background color to show)
        ui = App.loadResource(Rez.Drawables.ui);
    }


    function onSettingsChanged() as Void {
        loadSettings();
        loadResources();
        Ui.requestUpdate();
    }

    function onLayout(dc as Gfx.Dc) as Void {
        width = dc.getWidth();
        height = dc.getHeight();
        centerX = width / 2;
        centerY = height / 2;
        // Calculate scale factor based on screen width (260 is the base size for fr255m)
        scale = width / 260.0;
        isFr255sm = (width == 218);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        Ui.requestUpdate();
    }

    function onEnterSleep() as Void {
        Ui.requestUpdate();
    }

    function onShow() as Void {
        // Reload settings when returning from settings menu
        loadSettings();
        Ui.requestUpdate();
    }

    function drawIcon(dc as Gfx.Dc, icon as App.ResourceType, x as Lang.Number, y as Lang.Number, scale as Lang.Number) as Void {
        // Set icon tint color based on theme
        dc.setColor(iconTintColor, Gfx.COLOR_TRANSPARENT);
        
        var t = new Gfx.AffineTransform();
        t.scale(scale.toFloat(), scale.toFloat());
        dc.drawBitmap2(x, y, icon, {:transform => t, :tintColor => iconTintColor});
    }

    // Helper function to scale coordinates based on screen size
    private function s(value as Lang.Number) as Lang.Number {
        return (value * scale).toNumber();
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        var now = Sys.getClockTime();
        var currentTime = now.hour * 3600 + now.min * 60 + now.sec;

        // rarely changed values are updated less often to save battery.
        if (currentTime % 10 == 0 ){
            setDateTxt();
            setStressTxt();
            setSunTxt();
            setTempTxt();
            setStepsTxt();
            setDistTxt();
            setCalsTxt();
            setRecoveryTxt();
            setWindTxt();
            setBodyBatteryTxt();
            setWeatherTxt();
            setNotification();
        }
        setHeartTxt();

        // Draw background color first
        dc.setColor(backgroundColor, backgroundColor);
        dc.fillRectangle(0, 0, width, height);

        // Draw UI overlay with tint color (transparent areas show background)
        dc.drawBitmap2(0, 0, ui, {:tintColor => uiTintColor});
        
        // Battery - percentage text needs to be 1 pixel higher on sm
        //var batteryYOffset = isFr255sm ? s(7) - 2 : s(7);
        drawBattery(dc, centerX-s(40), s(7), s(80), s(21), s(5));
        
        drawTime(dc, centerX-s(65), s(11));
        
        // Date - push up 1 pixel on sm version
        var dateYOffset = isFr255sm ? height-s(25) - 2 : height-s(25);
        draw(dc, centerX, dateYOffset, Gfx.TEXT_JUSTIFY_CENTER, dateTxt, textDefaultColor, Gfx.FONT_XTINY);
        
        draw(dc, centerX, s(213), Gfx.TEXT_JUSTIFY_CENTER, weatherTxt, textDefaultColor, Gfx.FONT_XTINY);

        // Draws 2 columns with icons in the middle and values on the left or right 
        // and with same distance between each row.
        var iconScale = 0.50 * scale;
        for (var i = 0; i < 5; i++) {
            var offsetY = s(85 + (i * 25));
            var offsetX = centerX - s(40);
            var offsetIconX = centerX - s(30);
            var offsetIconY = offsetY + s(6);
            // Left column
            if (i == 0) {
                drawIcon(dc, heartIcon, offsetIconX, offsetIconY, iconScale);
                draw(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_RIGHT, heartTxt, heartColor, Gfx.FONT_TINY);
                if (hasNotification) {
                    drawIcon(dc, msgIcon, offsetX-s(75), offsetY+s(10), 0.5 * scale);
                }
            } else if (i == 1) {
                drawIcon(dc, stressIcon, offsetIconX, offsetIconY, iconScale);
                draw(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_RIGHT, stressTxt, stressColor, Gfx.FONT_TINY);
            } else if (i == 2) {
                drawIcon(dc, batteryIcon, offsetIconX, offsetIconY, iconScale);
                draw(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_RIGHT, bodyBatteryTxt, bodyBatteryColor, Gfx.FONT_TINY);
            } else if (i == 3){
                draw(dc, centerX-s(10), offsetY+s(5), Gfx.TEXT_JUSTIFY_RIGHT, sunTxt, sunColor, Gfx.FONT_XTINY);
            } else if (i == 4) {
                draw(dc, centerX-s(10), offsetY, Gfx.TEXT_JUSTIFY_RIGHT, tempTxt, tempColor, Gfx.FONT_TINY);
            }

            // Right column
            offsetX = centerX + s(40);
            offsetIconX = centerX + s(10);
            if (i == 0) {
                drawIcon(dc, stepsIcon, offsetIconX, offsetIconY, iconScale);
                draw(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_LEFT, stepsTxt, stepsColor, Gfx.FONT_TINY);
            } else if (i == 1) {
                drawIcon(dc, kmIcon, offsetIconX, offsetIconY, iconScale);
                draw(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_LEFT, distTxt, distColor, Gfx.FONT_TINY);
            } else if (i == 2) {
                drawIcon(dc, caloriesIcon, offsetIconX, offsetIconY, iconScale);
                draw(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_LEFT, calsTxt, Gfx.COLOR_YELLOW, Gfx.FONT_TINY);
            } else if (i == 3)  {
                drawIcon(dc, recoveryIcon, offsetIconX, offsetIconY, iconScale);
                draw(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_LEFT, recoveryTxt, recoveryColor, Gfx.FONT_TINY);
            } else if (i == 4)  {
                draw(dc, offsetIconX, offsetY, Gfx.TEXT_JUSTIFY_LEFT, windTxt, windColor, Gfx.FONT_TINY);
            }
        }
    }

    private function draw(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number, txt as Lang.String, color as Lang.Number, font as Gfx.FontType) as Void {
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, txt, justify);
    }


    // Battery percentage
    private function drawBattery(dc as Gfx.Dc, x, y, w, h, border) as Void {
        var stats = Sys.getSystemStats();
        var battery = stats.battery as Lang.Float;
        var textColor = Gfx.COLOR_WHITE;
        var batteryColor = Gfx.COLOR_RED;

        var txtPosX = centerX;
        if (battery > 70) {
            batteryColor = 0x00FF00;
        } else if (battery > 20) {
            batteryColor = 0xFFA500; 
        }

        if (battery > 65) {
            textColor = Gfx.COLOR_BLACK;
            txtPosX = centerX;
        } else {
            txtPosX = x+((battery/100.0) * w)+s(15);
            textColor = Gfx.COLOR_WHITE;
        }

        dc.setColor(batteryColor, Gfx.COLOR_TRANSPARENT);

        // Battery border
        dc.drawRoundedRectangle(x+1, y+1, w-1, h-2, border);

        // The actual fill grade for the battery status
        dc.fillRoundedRectangle(x+2, y+2, ((battery / 100.0) * w)-2, h-3, border);

        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        //dc.drawText(centerX, y, Gfx.FONT_XTINY, battery.toNumber().format("%d") + "%", Gfx.TEXT_JUSTIFY_CENTER);
        
        var offsetY = isFr255sm ? 2 : 0;
        dc.drawText(txtPosX, y-offsetY, Gfx.FONT_XTINY, battery.toNumber().format("%d") + "%", Gfx.TEXT_JUSTIFY_CENTER);
    }

    private function drawTime(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number) as Void {
        var clockTime = Sys.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var seconds = clockTime.sec;

        // Format time as HH:MM:SS
        var hourString = hours.format("%02d");
        var minutString = minutes.format("%02d");

        // Draw main time (HH:MM) - large font
        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX-s(47), y-s(3), Gfx.FONT_NUMBER_HOT, hourString, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(textDefaultColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX-s(45), y, Gfx.FONT_NUMBER_HOT, hourString, Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX-s(2), y+s(22), Gfx.FONT_LARGE, ":", Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(textDefaultColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX, y+s(25), Gfx.FONT_LARGE, ":", Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX+s(45), y-s(3), Gfx.FONT_NUMBER_HOT, minutString, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(textDefaultColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX+s(47), y, Gfx.FONT_NUMBER_HOT, minutString, Gfx.TEXT_JUSTIFY_CENTER);

        // Draw seconds below time (always show, but update respects battery settings)
        var secondsStr = seconds.format("%02d");
        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x+s(165), y+s(45), Gfx.FONT_TINY, secondsStr, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(textDefaultColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x+s(167), y+s(48), Gfx.FONT_TINY, secondsStr, Gfx.TEXT_JUSTIFY_CENTER);


        // Day - push down 1 pixel on sm version
        var info = Calendar.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayYOffset = isFr255sm ? 1 : 0;
        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(s(35), y+s(58)+dayYOffset, Gfx.FONT_XTINY, info.day_of_week, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(textDefaultColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(s(33), y+s(55)+dayYOffset, Gfx.FONT_XTINY, info.day_of_week, Gfx.TEXT_JUSTIFY_CENTER);


        var infow = Calendar.info(Time.now(), Time.FORMAT_SHORT);
        
        // Calculate ISO 8601 week number (LLM was used to get the week number)
        var moment = Time.now();
        var jan1 = Time.Gregorian.moment({:year => infow.year, :month => 1, :day => 1, :hour => 0, :minute => 0, :second => 0});
        var daysSinceJan1 = ((moment.value() - jan1.value()) / 86400).toNumber();
        var jan1Info = Calendar.info(jan1, Time.FORMAT_SHORT);
        
        // Convert day_of_week from Sunday=1 to Monday=0 for ISO
        var jan1DayOfWeek = (jan1Info.day_of_week + 5) % 7;
        var weekNumber = ((daysSinceJan1 + jan1DayOfWeek) / 7).toNumber() + 1;
        
        var weekStr = "w" + weekNumber.toString();
        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(s(37), y+s(45), Gfx.FONT_XTINY, weekStr, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(textDefaultColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(s(35), y+s(42), Gfx.FONT_XTINY, weekStr, Gfx.TEXT_JUSTIFY_CENTER);
    }


    private function setDateTxt() as Void {
        var info = Calendar.info(Time.now(), Time.FORMAT_SHORT);
        dateTxt = Lang.format("$1$-$2$-$3$", [info.year.format("%04u"), info.month.format("%02u"), info.day.format("%02u")]);
    }

    private function setWeatherTxt() as Void {
        var conditions = Weather.getCurrentConditions();
        var currentWeather = WEATHER_INFO[53]; // Default to Unknown
        if (conditions != null) {
            currentWeather = WEATHER_INFO[conditions.condition];
        }
        var perc = conditions.precipitationChance.format("%d");
        weatherTxt = perc + "% - "+ currentWeather[0];
        //weatherColor = currentWeather[1];
    }

    private function setStressTxt() as Void {
        var stressHistory = SensorHistory.getStressHistory({});
        stressTxt = "--";
        stressColor = 0x808080;
        if (stressHistory != null) {
            var stressIter = stressHistory.next();
            if (stressIter != null && stressIter.data != null) {
                var stress = stressIter.data;
                stressTxt = stress.format("%d");
                if (stress < 25) {
                    stressColor = Gfx.COLOR_GREEN;
                } else if (stress < 50) {
                    stressColor = Gfx.COLOR_YELLOW;
                } else if (stress < 75) {
                    stressColor = Gfx.COLOR_ORANGE;
                } else {
                    stressColor = Gfx.COLOR_RED;
                }
            }
        }
    }

    private function setSunTxt() as Void {
        var cc = Weather.getCurrentConditions();
        sunTxt = "--/--";
        if (cc == null) {
            return;
        }

        var loc = cc.observationLocationPosition;
        if (loc == null) {
            var posInfo = Position.getInfo();
            if (posInfo != null && posInfo.position != null) {
                loc = posInfo.position;
            }
        }

        if (loc != null) {
            var now = Time.now();

            var sunrise = Weather.getSunrise(loc, now);
            var sunset  = Weather.getSunset(loc, now);

            if (sunrise != null && sunset != null) {
                var sunriseTime = Calendar.info(sunrise, Time.FORMAT_SHORT);
                var sunsetTime  = Calendar.info(sunset, Time.FORMAT_SHORT);

                var sunriseStr = sunriseTime.hour.format("%02d") + ":" + sunriseTime.min.format("%02d");
                var sunsetStr  = sunsetTime.hour.format("%02d") + ":" + sunsetTime.min.format("%02d");

                sunTxt = sunriseStr + "/" + sunsetStr;
            }
        }
    }

    private function setTempTxt() as Void {
        var conditions = Weather.getCurrentConditions();

        tempTxt = "--°";
        if (conditions != null && conditions.temperature != null) {
            var temp = conditions.temperature;
            var tempText = temp.format("%d") + "°";

            if (temp >= 25) {
                tempColor = Gfx.COLOR_RED;
            } else if (temp <= 0) {
                tempColor = 0x00FFFF; 
            } else {
                tempColor = Gfx.COLOR_YELLOW;
            }

            // Add feels like if available
            if (conditions has :feelsLikeTemperature && conditions.feelsLikeTemperature != null) {
                var feelsLike = conditions.feelsLikeTemperature;
                tempTxt = tempText + "/" + feelsLike.format("%d") + "°";
            }
        }
    }

    private function setStepsTxt() as Void {
        var activityInfo = Act.getInfo();
        stepsTxt = "--";
        if (activityInfo.steps != null) {
            stepsTxt = activityInfo.steps.format("%d");
        }
    }

    private function setHeartTxt () as Void {
        var activityData = Activity.getActivityInfo();
        heartTxt = "--";

        if (activityData != null && activityData.currentHeartRate != null) {
            if (activityData.currentHeartRate < 50) {
                heartColor = Gfx.COLOR_GREEN; // Cyan for low heart rate
            } else if (activityData.currentHeartRate > 100) {
                heartColor = Gfx.COLOR_RED; // Red for high heart rate
            } else {
                heartColor = Gfx.COLOR_YELLOW;  // Green for normal heart rate
            }
            heartTxt = activityData.currentHeartRate.toString();
        }
    }

    private function setDistTxt() as Void {
        var activityInfo = Act.getInfo();

        if (activityInfo.distance != null) {
            var distance = activityInfo.distance;
            var distanceKm = distance / 100000.0; // Convert cm to km
            distTxt = distanceKm.format("%.2f") + "km";
        }
    }

    private function setCalsTxt() as Void {
        calsTxt = "--";
        var today = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);		
        var profile = UserProfile.getProfile();
        var age    = today.year - profile.birthYear;
        var weight = profile.weight / 1000.0;
        var restCalories = 0.0;
        var activeCalories = 0.0;
        var actInfo = Act.getInfo();
        var curCalories = actInfo.calories;

        if (profile.gender == UserProfile.GENDER_MALE) {
            restCalories = 5.2 - 6.116*age + 7.628*profile.height + 12.2*weight;
        } else {
            restCalories = -197.6 - 6.116*age + 7.628*profile.height + 12.2*weight;
        }
        restCalories   = Math.round((today.hour*60+today.min) * restCalories / 1440 ).toNumber();
        activeCalories = curCalories - restCalories;
        if (activeCalories < 0) {
            activeCalories = 0;
        }
        calsTxt = activeCalories.format("%d");
    }

    private function setRecoveryTxt() as Void {
        var info = Act.getInfo();
        recoveryTxt = "--";
        if (info != null && (info has :timeToRecovery) && info.timeToRecovery != null) {
            var recoveryHours = info.timeToRecovery;
            if (recoveryHours < 5) {
                recoveryColor = Gfx.COLOR_GREEN;
            } else if (recoveryHours < 10) {
                recoveryColor = 0xFFFF00; // Yellow
            } else {
                recoveryColor = Gfx.COLOR_RED;
            }
            recoveryTxt = recoveryHours.format("%d") + "h";
        }
    }

    private function setWindTxt() as Void {
        var conditions = Weather.getCurrentConditions();
        windTxt = "-- m/s";
        if (conditions != null && conditions.windSpeed != null) {
            var windSpeed = conditions.windSpeed;
            var bearing = "";
            var wb = conditions.windBearing;
            if (wb >= 0 && wb < 90) {
                bearing = "N";
            } else if (wb >= 90 && wb < 180) {
                bearing = "E";
            } else if (wb >= 180 && wb < 270) {
                bearing = "S";
            } else if (wb >= 270 && wb < 360) {
                bearing = "W";
            } else {
                bearing = "";
            }

            if (windSpeed > 10) {
                windColor = Gfx.COLOR_RED;
            } else if (windSpeed > 5) {
                windColor = Gfx.COLOR_YELLOW; 
            } else {
                windColor = Gfx.COLOR_GREEN;
            }


            windTxt = bearing + " " + windSpeed.format("%2d") + " m/s";
        }
    }

    private function setNotification() as Void {
        var ds = System.getDeviceSettings();
        hasNotification = (ds != null) && (ds.notificationCount != null) && (ds.notificationCount > 0);

    }

    private function setBodyBatteryTxt() as Void {
        var bbHistory = SensorHistory.getBodyBatteryHistory({});
        bodyBatteryTxt = "--";

        if (bbHistory != null) {
            var bbIter = bbHistory.next();
            if (bbIter != null && bbIter.data != null) {
                var bodyBattery = bbIter.data;
                if (bodyBattery < 20) {
                    bodyBatteryColor = Gfx.COLOR_RED;
                } else if (bodyBattery < 50) {
                    bodyBatteryColor = Gfx.COLOR_YELLOW;
                } else {
                    bodyBatteryColor = Gfx.COLOR_GREEN;
                }

                bodyBatteryTxt = bodyBattery.format("%d");
            }
        }
    }
}

