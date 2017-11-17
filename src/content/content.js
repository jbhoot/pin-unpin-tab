
// An event handler to look for the designated keyboard shortcut.
// This handler will come into action when the customizable keyboard shortcut feature is implemented.
window.addEventListener("keydown", function (event) {
    if (event.defaultPrevented) {
        return; // Do nothing if the event was already processed
    }

    // TODO: read this guide to see how to migrate to webpack https://github.com/mdn/webextensions-examples/blob/master/react-es6-popup/README.md
    // TODO: after migrating to webpack, get shortcut and compare it to string converted event code with modifiers
    if (event.key.toLowerCase() === "x" && event.altKey) {
        browser.runtime.sendMessage({toggle: true});

        // Cancel the default action to avoid it being handled twice
        event.preventDefault();
    }
}, true);
