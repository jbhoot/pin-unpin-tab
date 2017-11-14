
// An event handler to look for the designated keyboard shortcut.
// This handler will come into action when the customizable keyboard shortcut feature is implemented.
window.addEventListener("keydown", function (event) {
    if (event.defaultPrevented) {
        return; // Do nothing if the event was already processed
    }

    if (event.key.toLowerCase() === "x" && event.altKey) {
        browser.runtime.sendMessage({toggle: true});

        // Cancel the default action to avoid it being handled twice
        event.preventDefault();
    }
}, true);
