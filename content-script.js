var longClickTimer;

function setLongClickTimer(event) {
    longClickTimer = window.setTimeout(function() {
        browser.runtime.sendMessage({toggle: true});
    }, event.currentTarget.longClickToggleTime);
}

function unsetLongClickTimer (event) {
    clearTimeout(longClickTimer);
}

function setClickEvents(longClickToggleTime) {
    // https://stackoverflow.com/a/11986895
    // I cannot tinker with the event handler function directly
    // because I use removeEventListener later on, which needs identical arguments.
    window.longClickToggleTime = longClickToggleTime;
    window.addEventListener('mousedown', setLongClickTimer, true);
    window.addEventListener('mouseup', unsetLongClickTimer, true);
    window.addEventListener('mousemove', unsetLongClickTimer, true);
}

function unsetClickEvents() {
    window.removeEventListener('mousedown', setLongClickTimer, true);
    window.removeEventListener('mouseup', unsetLongClickTimer, true);
    window.addEventListener('mousemove', unsetLongClickTimer, true);
}

function setLongClickToggle() {
    browser.storage.local.get()
        .then(function(prefs) {
            if(prefs.longClickToggle) {
                setClickEvents(prefs.longClickToggleTime);
            } else {
                unsetClickEvents();
            }
        });
}

setLongClickToggle();

browser.storage.onChanged.addListener(function(changes, areaName) {
    if(changes.longClickToggle || changes.longClickToggleTime) {
        setLongClickToggle();
    }
});
