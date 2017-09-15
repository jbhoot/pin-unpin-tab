function toggleSucceeded(tab) {
    console.log('toggled tab $(tab.id)')
}

function toggleFailed(tab) {
    console.log('toggle failed for tab $(tab.id)')
}

function queryingActiveTabSucceeded(tabs) {
  console.log('array length:', tabs.length)
  var activeTab = tabs[0];
  console.log('before toggle pinned: ', activeTab.pinned);
  
  var togglingActiveTab = browser.tabs.update(activeTab.id, {pinned: !activeTab.pinned});
  togglingActiveTab.then(toggleSucceeded, toggleFailed)
}

function queryingActiveTabFailed(error) {
  console.log(`Error: ${error}`);
}

function initiatePinToggle() {
    console.log('querying')
    var queryingActiveTab = browser.tabs.query({currentWindow: true, active: true});
    queryingActiveTab.then(queryingActiveTabSucceeded, queryingActiveTabFailed);
}

browser.browserAction.onClicked.addListener(initiatePinToggle);

browser.commands.onCommand.addListener(function(command) {
    if (command == "toggle_pinned_status") {
        initiatePinToggle();
    }
});

// This listener will come in action when the custom shortcut feature is added.
browser.runtime.onMessage.addListener(function(event) {
    if (event.toggle) {
        initiatePinToggle();
    }    
});
