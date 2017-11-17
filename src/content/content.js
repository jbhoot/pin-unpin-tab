import {onHotkeyPress} from '../hotkey';

// An event handler to look for the designated keyboard shortcut.
window.addEventListener('keydown', function (event) {
    if (event.defaultPrevented) {
        return; // Do nothing if the event was already processed
    }

    onHotkeyPress(event)
        .then(() => browser.runtime.sendMessage({toggle: true}))
        .then(() => event.preventDefault());
}, true);
