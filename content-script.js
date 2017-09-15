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
