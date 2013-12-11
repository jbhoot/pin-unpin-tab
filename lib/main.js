var tabs = require('sdk/tabs');

const { Cu } = require('chrome');
Cu.import('resource:///modules/devtools/gcli.jsm');

gcli.addCommand({
    name: 'pintab',
    description: 'Pin current tab',
    exec: function(args, context) {
        var currentTab = tabs.activeTab;
        if (!currentTab.isPinned)
            currentTab.pin();
        else
            return 'Tab already pinned.'
    }
});

gcli.addCommand({
    name: 'unpintab',
    description: 'Unpin current tab',
    exec: function(args, context) {
        var currentTab = tabs.activeTab;
        if (currentTab.isPinned)
            currentTab.unpin();
        else
            return 'Tab already unpinned.'
    }
});

modifierKey = require('sdk/simple-prefs').prefs['modifierKey'];
normalKey = require('sdk/simple-prefs').prefs['normalKey'];
var { Hotkey } = require('sdk/hotkeys');
showHotKey = Hotkey({
    combo: modifierKey + '-' + normalKey,
    onPress: function() {
        togglePinnedStatus();
    }
});

function onModifierKeyChange() {
    modifierKey = require('sdk/simple-prefs').prefs['modifierKey'];
    normalKey = require('sdk/simple-prefs').prefs['normalKey'];

    showHotKey.destroy();
    showHotKey = Hotkey({
        combo: modifierKey + '-' + normalKey,
        onPress: function() {
            togglePinnedStatus();
        }
    });
}
function onNormalKeyChange() {
    modifierKey = require('sdk/simple-prefs').prefs['modifierKey'];
    normalKey = require('sdk/simple-prefs').prefs['normalKey'];

    showHotKey.destroy();
    showHotKey = Hotkey({
        combo: modifierKey + '-' + normalKey,
        onPress: function() {
            togglePinnedStatus();
        }
    });
}
function onResetClick() {
    require('sdk/simple-prefs').prefs['modifierKey'] = 'alt';
    require('sdk/simple-prefs').prefs['normalKey'] = 'p';

    modifierKey = require('sdk/simple-prefs').prefs['modifierKey'];
    normalKey = require('sdk/simple-prefs').prefs['normalKey'];

    showHotKey.destroy();
    showHotKey = Hotkey({
        combo: modifierKey + '-' + normalKey,
        onPress: function() {
            togglePinnedStatus();
        }
    });
}
require('sdk/simple-prefs').on('modifierKey', onModifierKeyChange);
require('sdk/simple-prefs').on('normalKey', onNormalKeyChange);
require('sdk/simple-prefs').on('resetButton', onResetClick);

var widgets = require('sdk/widget');
var self = require('sdk/self');
var widget = widgets.Widget({
    id: 'tab-pinner',
    label: 'Pin this tab',
    contentURL: self.data.url('pin.png'),
    onClick: function() {
        togglePinnedStatus();
    }
});


function togglePinnedStatus() {
    var currentTab = tabs.activeTab;
    if (currentTab.isPinned)
        currentTab.unpin();
    else
        currentTab.pin();
}

