document.addEventListener("DOMContentLoaded", function() {
    const longClickToggleElement = document.querySelector("#longClickToggle");
    const longClickToggleTimeElement = document.querySelector("#longClickToggleTime");
    
    function updateUI(storedPrefs) {
        longClickToggleElement.checked = storedPrefs.longClickToggle;
            
        longClickToggleTimeElement.min = storedPrefs.minLongClickToggleTime;
        longClickToggleTimeElement.max = storedPrefs.maxLongClickToggleTime;
        longClickToggleTimeElement.value = storedPrefs.longClickToggleTime;
        longClickToggleTimeElement.disabled = !storedPrefs.longClickToggle;
    }
    
    longClickToggleElement.addEventListener("change", function(evt) {
        let val = evt.target.checked;
        browser.storage.local.set({longClickToggle: val});
        longClickToggleTimeElement.disabled = !val;
    });

    longClickToggleTimeElement.addEventListener("change", function(evt) {
        let val = evt.target.value;
        browser.storage.local.get()
            .then(function(storedPrefs) {
                if (val >= storedPrefs.minLongClickToggleTime
                    && val <= storedPrefs.maxLongClickToggleTime) {
                    browser.storage.local.set({longClickToggleTime: val});
                }
                return;
            });
        return;
    });
    
    browser.storage.local.get().then(updateUI);
});
