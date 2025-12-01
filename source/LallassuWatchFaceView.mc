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

class LallassuWatchFaceView extends Ui.WatchFace {
    private const timeColor = 0xFFFFFF;
    private const columnFont = Gfx.FONT_TINY;
    private const WEATHER_INFO = {} as Lang.Dictionary;

    private var lastUpdateTime = 0;
    private var isAwake;
    private var width = 0;
    private var height = 0;
    private var centerX = 0; 
    private var centerY = 0;
    private var batteryIcon;
    private var caloriesIcon;
    private var heartIcon;
    private var kmIcon;
    private var recoveryIcon;
    private var stepsIcon;
    private var stressIcon;
    private var iconScale = 0.5;
    private var ui;
    private var currentWeather = {} as Lang.Dictionary;

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
        setWeatherCondition();

        batteryIcon = App.loadResource(Rez.Drawables.battery);
        caloriesIcon = App.loadResource(Rez.Drawables.calories);
        heartIcon = App.loadResource(Rez.Drawables.heart);
        kmIcon = App.loadResource(Rez.Drawables.km);
        recoveryIcon = App.loadResource(Rez.Drawables.recovery);
        stepsIcon = App.loadResource(Rez.Drawables.steps);
        stressIcon = App.loadResource(Rez.Drawables.stress);
        ui = App.loadResource(Rez.Drawables.ui);

        WatchFace.initialize();
    }

    function onLayout(dc as Gfx.Dc) as Void {
        width = dc.getWidth();
        height = dc.getHeight();
        centerX = width / 2;
        centerY = height / 2;
    }

    function onHide() as Void {
        isAwake = false;
    }

    function onExitSleep() as Void {
        isAwake = true;
        Ui.requestUpdate();
    }

    function onEnterSleep() as Void {
        isAwake = false;
        Ui.requestUpdate();
    }

    function onShow() as Void {
        isAwake = true;
    }

    function drawIcon(dc as Gfx.Dc, icon as App.ResourceType, x as Lang.Number, y as Lang.Number, scale as Lang.Number) as Void {
        var t = new Gfx.AffineTransform();
        t.scale(scale, scale);
        dc.drawBitmap2(x, y, icon, {:transform => t});
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        var now = Sys.getClockTime();
        var currentTime = now.hour * 3600 + now.min * 60 + now.sec;
        lastUpdateTime = currentTime;

        if (currentTime % 10 == 0 ){
            setWeatherCondition();
            // TBD: Update other data periodically if needed and just draw
            // last values.
        }

      
        var t = new Gfx.AffineTransform();
        dc.drawBitmap2(0,0, ui, {:transform => t});
        drawBattery(dc, centerX-(80/2), 7, 80, 21, 5);
        drawTime(dc, centerX-65, 11);
        drawDate(dc, centerX, 260-25);
        drawWeatherCondition(dc, centerX, 213);

        // Draws 2 columns with icons in the middle and values on the left or right 
        // and with same distance between each row.
        var iconScale = 0.50;
        for (var i = 0; i < 5; i++) {
            var offsetY = 85 + (i * 25);
            var offsetX = centerX - 40;
            var offsetIconX = centerX - 30;
            var offsetIconY = offsetY + 6;
            // Left column
            if (i == 0) {
                drawIcon(dc, heartIcon, offsetIconX, offsetIconY, iconScale);
                drawHeartRate(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_RIGHT);
            } else if (i == 1) {
                drawIcon(dc, stressIcon, offsetIconX, offsetIconY, iconScale);
                drawStress(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_RIGHT);
            } else if (i == 2) {
                drawIcon(dc, batteryIcon, offsetIconX, offsetIconY, iconScale);
                drawBodyBattery(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_RIGHT);
            } else if (i == 3){
                drawSunriseSunset(dc, centerX-10, offsetY+5, Gfx.TEXT_JUSTIFY_RIGHT);
            } else if (i == 4) {
                drawTemperature(dc, centerX-10, offsetY, Gfx.TEXT_JUSTIFY_RIGHT);
            }

            // Right column
            offsetX = centerX + 40;
            offsetIconX = centerX + 10;
            if (i == 0) {
                drawIcon(dc, stepsIcon, offsetIconX, offsetIconY, iconScale);
                drawSteps(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_LEFT);
            } else if (i == 1) {
                drawIcon(dc, kmIcon, offsetIconX, offsetIconY, iconScale);
                drawDistance(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_LEFT);
            } else if (i == 2) {
                drawIcon(dc, caloriesIcon, offsetIconX, offsetIconY, iconScale);
                drawActiveCalories(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_LEFT);
            } else if (i == 3)  {
                drawIcon(dc, recoveryIcon, offsetIconX, offsetIconY, iconScale);
                drawRecoveryTime(dc, offsetX, offsetY, Gfx.TEXT_JUSTIFY_LEFT);
            } else if (i == 4)  {
                drawWindSpeed(dc, offsetIconX, offsetY, Gfx.TEXT_JUSTIFY_LEFT);
            }
        }
    }

    private function drawWeatherCondition(dc as Gfx.Dc, x  as Lang.Number, y  as Lang.Number) as Void {
        if (currentWeather == null) {
            return;
        }
        var font = Gfx.FONT_XTINY;
        dc.setColor(currentWeather[1], Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, currentWeather[0], Gfx.TEXT_JUSTIFY_CENTER);
    }

    private function setWeatherCondition() {
        var conditions = Weather.getCurrentConditions();
        if (conditions == null) {
            currentWeather = WEATHER_INFO[53]; // Unknown
            return;
        }
        currentWeather = WEATHER_INFO[conditions.condition];
    }  

    // Battery percentage
    private function drawBattery(dc as Gfx.Dc, x, y, w, h, border) as Void {
        var stats = Sys.getSystemStats();
        var battery = stats.battery as Lang.Float;
        var textColor = Gfx.COLOR_WHITE;
        var batteryColor = Gfx.COLOR_RED;

        if (battery > 70) {
            batteryColor = 0x00FF00;
        } else if (battery > 20) {
            batteryColor = 0xFFA500; 
        }

        if (battery > 60) {
            textColor = Gfx.COLOR_BLACK;
        }

        dc.setColor(batteryColor, Gfx.COLOR_TRANSPARENT);

        // Battery border
        dc.drawRoundedRectangle(x+1, y+1, w-1, h-2, border);

        // The actual fill grade for the battery status
        dc.fillRoundedRectangle(x+2, y+2, ((battery / 100.0) * w)-2, h-3, border);

        dc.setColor(textColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX, y, Gfx.FONT_XTINY, battery.toNumber().format("%d") + "%", Gfx.TEXT_JUSTIFY_CENTER);
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
        dc.drawText(centerX-47, y-3, Gfx.FONT_NUMBER_HOT, hourString, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(timeColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX-45, y, Gfx.FONT_NUMBER_HOT, hourString, Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX-2, y+22, Gfx.FONT_LARGE, ":", Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX, y+25, Gfx.FONT_LARGE, ":", Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX+45, y-3, Gfx.FONT_NUMBER_HOT, minutString, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(timeColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(centerX+47, y, Gfx.FONT_NUMBER_HOT, minutString, Gfx.TEXT_JUSTIFY_CENTER);

        // Draw seconds below time (always show, but update respects battery settings)
        var secondsStr = seconds.format("%02d");
        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x+165, y+45, Gfx.FONT_TINY, secondsStr, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(timeColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x+167, y+48, Gfx.FONT_TINY, secondsStr, Gfx.TEXT_JUSTIFY_CENTER);


        // Day
        var info = Calendar.info(Time.now(), Time.FORMAT_MEDIUM);
        dc.setColor(0x000000, Gfx.COLOR_TRANSPARENT);
        dc.drawText(35, y+58, Gfx.FONT_XTINY, info.day_of_week, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(timeColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(33, y+55, Gfx.FONT_XTINY, info.day_of_week, Gfx.TEXT_JUSTIFY_CENTER);


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
        dc.drawText(37, y+45, Gfx.FONT_XTINY, weekStr, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(timeColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(35, y+42, Gfx.FONT_XTINY, weekStr, Gfx.TEXT_JUSTIFY_CENTER);
    }


    // Temperature + Feels Like
    private function drawTemperature(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var conditions = Weather.getCurrentConditions();

        if (conditions != null && conditions.temperature != null) {
            var temp = conditions.temperature;
            var tempText = temp.format("%d") + "°";

            // Add feels like if available
            if (conditions has :feelsLikeTemperature && conditions.feelsLikeTemperature != null) {
                var feelsLike = conditions.feelsLikeTemperature;
                tempText = tempText + "/" + feelsLike.format("%d") + "°";
            }

            dc.setColor(0x00BFFF, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, tempText, justify);
        } else {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "--°", justify);
        }
    }

    // Wind speed in m/s
    private function drawWindSpeed(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var conditions = Weather.getCurrentConditions();

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
            dc.setColor(0x87CEEB, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, bearing + " " + windSpeed.format("%d") + " m/s", justify);
        } else {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "-- m/s", justify);
        }
    }

    // Sunrise/Sunset times
    private function drawSunriseSunset(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var cc = Weather.getCurrentConditions();
        if (cc == null) {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "--/--", justify);
            return;
        }

        var drawEmpty = true;
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

                dc.setColor(0xFFA500, Gfx.COLOR_TRANSPARENT);
                dc.drawText(x, y, Gfx.FONT_XTINY, sunriseStr + "/" + sunsetStr, justify);
                drawEmpty = false;
            }
        }

        if (drawEmpty) {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "--/--", justify);
        }
    }

    private function drawDate(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number) as Void {
        var info = Calendar.info(Time.now(), Time.FORMAT_SHORT);

        var dateText = Lang.format("$1$-$2$-$3$", [info.year.format("%04u"), info.month.format("%02u"), info.day.format("%02u")]);
        dc.setColor(timeColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_XTINY, dateText, Gfx.TEXT_JUSTIFY_CENTER);
    }

    private function drawRecoveryTime(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var info = Act.getInfo();

        if (info != null && (info has :timeToRecovery) && info.timeToRecovery != null) {
            var recoveryHours = info.timeToRecovery;
            var text = recoveryHours.format("%d") + "h";
            dc.setColor(0xADD8E6, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, text, justify);
        } else {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "--", justify);
        }
    }

    private function drawSteps(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var activityInfo = Act.getInfo();

        if (activityInfo.steps != null) {
            var steps = activityInfo.steps;
            dc.setColor(0x32CD32, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, steps.format("%d"), justify);
        } else {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "--", justify);
        }
    }

    private function drawHeartRate(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var activityData = Activity.getActivityInfo();
        var hrText = "--";

        if (activityData != null && activityData.currentHeartRate != null) {
            hrText = activityData.currentHeartRate.toString();
        }

        dc.setColor(0xFF6B6B, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, columnFont, hrText, justify);
    }

    private function drawActiveCalories(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var actInfo = Act.getInfo();

        if (actInfo == null || actInfo.calories == null) {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "--", justify);
            return;
        }

        //NOTE: Some LLM generated calculation as we cannot get active calories directly

        var totalCalories = actInfo.calories as Lang.Number;

        // Get user profile for BMR estimation
        var profile = UserProfile.getProfile();
        if (profile == null ||
            profile.weight == null ||
            profile.height == null ||
            profile.birthYear == null ||
            profile.gender == null) {

            // Fallback: show total calories if we can't estimate resting
            dc.setColor(0xFF8C00, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, totalCalories.format("%d"), justify);
            return;
        }

        // Time-of-day: minutes since midnight
        var now = Time.now();
        var dateInfo = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var minutesToday = dateInfo.hour * 60 + dateInfo.min;

        var age = dateInfo.year - profile.birthYear;

        // Mifflin–St Jeor BMR (weight in grams, height in cm)
        // BMR = 10*kg + 6.25*cm - 5*age + s
        // weight(kg) = weight(g) / 1000
        var bmr = (10.0 / 1000.0) * profile.weight +
            6.25 * profile.height -
            5.0 * age +
            ((profile.gender == UserProfile.GENDER_MALE) ? 5.0 : -161.0);

        // Estimate resting calories for a full day (sedentary factor 1.2)
        var nonActiveDay = (bmr * 1.2).toFloat();

        // Resting calories so far today
        var nonActiveSoFar = nonActiveDay * minutesToday / (24.0 * 60.0);

        // Active calories ≈ total - resting
        var activeCalories = totalCalories.toFloat() - nonActiveSoFar;
        if (activeCalories < 0) {
            activeCalories = 0;
        }

        var activeInt = activeCalories.toNumber();

        dc.setColor(0xFF8C00, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, columnFont, activeInt.format("%d"), justify);
    }

    private function drawDistance(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var activityInfo = Act.getInfo();

        if (activityInfo.distance != null) {
            var distance = activityInfo.distance;
            var distanceKm = distance / 100000.0; // Convert cm to km
            dc.setColor(0x00CED1, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, distanceKm.format("%.0f") + "km", justify);
        } else {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "--", justify);
        }
    }

    private function drawStress(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var stressHistory = SensorHistory.getStressHistory({});

        if (stressHistory != null) {
            var stressIter = stressHistory.next();
            if (stressIter != null && stressIter.data != null) {
                var stress = stressIter.data;
                dc.setColor(0xDA70D6, Gfx.COLOR_TRANSPARENT);
                dc.drawText(x, y, columnFont, stress.format("%d"), justify);
            } else {
                dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
                dc.drawText(x, y, columnFont, "--", justify);
            }
        } else {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "--", justify);
        }
    }

    private function drawBodyBattery(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, justify as Lang.Number) as Void {
        var bbHistory = SensorHistory.getBodyBatteryHistory({});
        if (bbHistory != null) {
            var bbIter = bbHistory.next();
            if (bbIter != null && bbIter.data != null) {
                var bodyBattery = bbIter.data;
                var bbColor = Gfx.COLOR_RED;

                if (bodyBattery > 70) {
                    bbColor = Gfx.COLOR_GREEN;
                } else if (bodyBattery > 30) {
                    bbColor = 0xFFFF00; 
                }

                dc.setColor(bbColor, Gfx.COLOR_TRANSPARENT);
                dc.drawText(x, y, columnFont, bodyBattery.format("%d"), justify);
            } else {
                dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
                dc.drawText(x, y, columnFont, "--", justify);
            }
        } else {
            dc.setColor(0x808080, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, y, columnFont, "--", justify);
        }
    }
}

