var longClickTimer;

function isItLeftClick(event) {    
    // The event.buttons check is useful to discard simultaneous click of multiple mouse buttons.
    // But only in the cases where the left button hasn't been clicked first.
    
    // There is no point in testing for event.metaKey.
    // MDN doc (https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/metaKey)
    // explicitly states that Firefox doesn't see Windows key as meta key.
    // This makes sense as in Windows OS, that key is controlled by the OS.
    // So Firefox as a cross-platform browser has to respect that behaviour.

    return event.button == 0 && 
        event.buttons == 1 &&
        (!(event.shiftKey || event.ctrlKey || event.altKey));
}

function setLongClickTimer(event) {
    if (isItLeftClick(event)) {
        longClickTimer = window.setTimeout(function() {
            browser.runtime.sendMessage({toggle: true});
        }, event.currentTarget.longClickToggleTime);
    }
}

function unsetLongClickTimer (event) {
    // Don't bother to check if isItLeftClick() here.
    // Even if it was another click after the timer has been set,
    // it means that user intends to carry out some multiple click operation.
    // So, we have to clear the timeout in that case anyway.
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
