var longClickTimer;

function init() {
    setLongClickToggle();
    browser.storage.onChanged.addListener(function (changes, areaName) {
        if (changes.longClickToggle || changes.longClickToggleTime) {
            setLongClickToggle();
        }
    });
}

function setLongClickToggle() {
    browser.storage.local.get()
        .then(function (prefs) {
            if (prefs.longClickToggle) {
                setClickEvents(prefs.longClickToggleTime);
            } else {
                unsetClickEvents();
            }
        });
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
    window.removeEventListener('mousemove', unsetLongClickTimer, true);
}

function setLongClickTimer(event) {
    if (!leftButtonClicked(event)) return;
    if (clickedOnDocumentScrollbar(event)) return;
    if (clickedOnElementScrollbar(event)) return

    longClickTimer = window.setTimeout(function () {
        browser.runtime.sendMessage({ toggle: true });
    }, event.currentTarget.longClickToggleTime);
}

function unsetLongClickTimer(event) {
    // Don't bother to check if leftButtonClicked() here.
    // Even if it was another click after the timer has been set,
    // it means that user intends to carry out some multiple click operation.
    // So, we have to clear the timeout in that case anyway.
    clearTimeout(longClickTimer);
}

function clickedOnDocumentScrollbar(event) {
    // solution adopted from https://stackoverflow.com/a/34805113
    return event.clientX >= document.documentElement.offsetWidth
        || event.clientY >= document.documentElement.offsetHeight;
}

function clickedOnElementScrollbar(event) {
    // This check, while ignoring clicks on element's scrollbar,
    // unfortunately also ignores clicks on borders and margins.
    // MDN: clientWidth includes padding but excludes borders, margins, and vertical scrollbars (if present).

    // Both getBoundingClientRect() and MouseEvent.clientX/Y
    // use the top-left of viewport as the reference point.

    const rect = event.target.getBoundingClientRect()
    return event.clientX > rect.x + event.target.clientWidth
        || event.clientY > rect.y + event.target.clientHeight
}

function leftButtonClicked(event) {
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


init()