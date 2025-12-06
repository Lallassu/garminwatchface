using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Application.Storage;

class SettingsMenu extends Ui.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Settings"});
        addItems();
    }

    function addItems() {
        var themeValue = Storage.getValue("Theme");
        if (themeValue == null) { themeValue = 0; }
        
        Menu2.addItem(
            new Ui.MenuItem(
                "Theme Preset",
                getThemeName(themeValue),
                "Theme",
                {}
            )
        );
        
        var bgColorValue = Storage.getValue("BackgroundColor");
        Menu2.addItem(
            new Ui.MenuItem(
                "Background",
                bgColorValue == null ? "From Theme" : getColorName(bgColorValue),
                "BackgroundColor",
                {}
            )
        );
        
        var iconColorValue = Storage.getValue("IconColor");
        Menu2.addItem(
            new Ui.MenuItem(
                "Icon Color",
                iconColorValue == null ? "From Theme" : getColorName(iconColorValue),
                "IconColor",
                {}
            )
        );
        
        var uiColorValue = Storage.getValue("UIColor");
        Menu2.addItem(
            new Ui.MenuItem(
                "UI Color",
                uiColorValue == null ? "From Theme" : getColorName(uiColorValue),
                "UIColor",
                {}
            )
        );
        
        var textColorValue = Storage.getValue("TextColor");
        Menu2.addItem(
            new Ui.MenuItem(
                "Text Color",
                textColorValue == null ? "From Theme" : getColorName(textColorValue),
                "TextColor",
                {}
            )
        );
    }
    
    function getColorName(colorIndex) {
        var colorNames = [
            "White",          // 0
            "Black",          // 1
            "Light Gray",     // 2
            "Dark Gray",      // 3
            "Red",            // 4
            "Pink",           // 5
            "Orange",         // 6
            "Gold",           // 7
            "Yellow",         // 8
            "Lime",           // 9
            "Dark Green",     // 10
            "Light Green",    // 11
            "Cyan",           // 12
            "Dark Blue",      // 13
            "Light Blue",     // 14
            "Purple",         // 15
            "Violet",         // 16
            "Dark Red",       // 17
            "Teal",           // 18
            "Mint"            // 19
        ];
        
        if (colorIndex < 0 || colorIndex >= colorNames.size()) {
            return colorNames[0];
        }
        
        return colorNames[colorIndex];
    }

    function getThemeName(themeIndex) {
        var themeNames = [
            "Default",
            "Arctic Neon",
            "Solar Flare",
            "Ocean Wave",
            "Fire Red",
            "Lime Punch",
            "Electric Purple",
            "Sunset Gold",
            "Mint Flash",
            "Hot Pink"
        ];
        
        if (themeIndex < 0 || themeIndex >= themeNames.size()) {
            return themeNames[0];
        }
        
        return themeNames[themeIndex];
    }
}

class SettingsMenuDelegate extends Ui.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();
        cycleSetting(item, id);
    }

    hidden function cycleSetting(item, fieldId) {
        var menu = new SettingsMenu();
        
        if (fieldId.equals("Theme")) {
            var currentValue = Storage.getValue(fieldId);
            if (currentValue == null) { currentValue = 0; }
            
            var nextValue = (currentValue + 1) % 10;  // 10 themes (0-9)
            var subLabel = menu.getThemeName(nextValue);
            
            Storage.setValue(fieldId, nextValue);
            
            Storage.deleteValue("BackgroundColor");
            Storage.deleteValue("IconColor");
            Storage.deleteValue("UIColor");
            Storage.deleteValue("TextColor");
            
            item.setSubLabel(subLabel);
        } else if (fieldId.equals("BackgroundColor") || fieldId.equals("IconColor") || 
                 fieldId.equals("UIColor") || fieldId.equals("TextColor")) {
            var currentValue = Storage.getValue(fieldId);
            
            if (currentValue == null) {
                Storage.setValue(fieldId, 0);
                item.setSubLabel(menu.getColorName(0));
            } else if (currentValue >= 19) {
                Storage.deleteValue(fieldId);
                item.setSubLabel("From Theme");
            } else {
                var nextValue = currentValue + 1;
                Storage.setValue(fieldId, nextValue);
                item.setSubLabel(menu.getColorName(nextValue));
            }
        }
        Ui.requestUpdate();
    }
}
