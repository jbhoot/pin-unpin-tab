// Set default preferences at one place, here, when add-on is installed or updated.
browser.runtime.onInstalled.addListener(function() {
    function setDefaults() {
        const defaultPreferences = {
            defaultLongClickToggle: true,
            defaultLongClickToggleTime: 500,
            longClickToggle: true,
            longClickToggleTime: 500,
            minLongClickToggleTime: 400,
            maxLongClickToggleTime: 1000            
        };
        
        // The onInstalled event is fired even when an add-on is updated.
        // We wouldn't want to reset user preferences after an update.
        // So heck for stored preferences first.
        browser.storage.local.get(defaultPreferences).then(function(prefs) {
            browser.storage.local.set(prefs);
        });
    }
    
    setDefaults();
});

function initiatePinToggle() {
    function getActiveTab() {
        return browser.tabs.query({currentWindow: true, active: true})
            .then(function(tabs) {
                if (tabs.length < 1) {
                    console.log('Tabs array was somehow empty.',
                                'This should not happen.',
                                'There should always be one active tab.',
                                'File a bug.');
                    return;
                }
                return tabs[0];
            });
    }
    
    function updatePinnedStatus(activeTab) {
        return browser.tabs.update(activeTab.id, {pinned: !activeTab.pinned});
    }
    
    function failed(err) {
        console.log('Pin Unpin Tab extension: Something went wrong.');
        console.log(err);
    }
    
    getActiveTab()
        .then(updatePinnedStatus)
        .catch(failed);
}

// Toggle pinned status via the add-on icon.
browser.browserAction.onClicked.addListener(initiatePinToggle);

// Toggle pinned status via the global keyboard shortcut (which also works on Firefox Pages and on AMO).
browser.commands.onCommand.addListener(function(command) {
    if (command == "toggle_pinned_status") {
        initiatePinToggle();
    }
});

// Toggle pinned status via custom keyboard shortcut (which don't work on Firefox Pages and on AMO)
// and via long left mouse click.
browser.runtime.onMessage.addListener(function(event) {
    if (event.toggle) {
        initiatePinToggle();
    }    
});
