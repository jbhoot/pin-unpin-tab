// New learning: Implement the following flow after understanding Promises better.
// initiateToggle() {
//   findActiveTab().then(togglePinnedStatus)
// }

function toggleSucceeded(tab) {
    console.log('toggled tab $(tab.id)')
}

function toggleFailed(tab) {
    console.log('toggle failed for tab $(tab.id)')
}

function queryingActiveTabSucceeded(tabs) {
    if (tabs.length < 1) {
        console.log('Tabs array was somehow empty. This should not happen. There should always be one active tab. File a bug.')
        return;
    }
    const activeTab = tabs[0];
    var togglingActiveTab = browser.tabs.update(activeTab.id, {pinned: !activeTab.pinned});
    togglingActiveTab.then(toggleSucceeded, toggleFailed)
}

function queryingActiveTabFailed(error) {
  console.log(`Error: ${error}`);
}

function initiatePinToggle() {
    var queryingActiveTab = browser.tabs.query({currentWindow: true, active: true});
    queryingActiveTab.then(queryingActiveTabSucceeded, queryingActiveTabFailed);
}

// Event handler to listen to clicks on the pin icon on browser toolbar.
browser.browserAction.onClicked.addListener(initiatePinToggle);

// Event handler to listen to the keyboard shortcut configured in manifest.json.
// This shortcut works even on Firefox Pages.
browser.commands.onCommand.addListener(function(command) {
    if (command == "toggle_pinned_status") {
        initiatePinToggle();
    }
});

browser.runtime.onMessage.addListener(function(event) {
    if (event.toggle) {
        initiatePinToggle();
    }
});
