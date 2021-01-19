const validClick = (event) => {
    const clickedOnDocumentScrollbar = event => {
        // solution adopted from https://stackoverflow.com/a/34805113
        return event.clientX >= document.documentElement.offsetWidth
            || event.clientY >= document.documentElement.offsetHeight;
    }

    const clickedOnElementScrollbar = event => {
        // This check, while ignoring clicks on element's scrollbar,
        // unfortunately also ignores clicks on borders and margins.
        // MDN: clientWidth includes padding but excludes borders, margins, and vertical scrollbars (if present).

        // Both getBoundingClientRect() and MouseEvent.clientX/Y
        // use the top-left of viewport as the reference point.

        const rect = event.target.getBoundingClientRect()
        return event.clientX > rect.x + event.target.clientWidth
            || event.clientY > rect.y + event.target.clientHeight
    }

    const leftButtonClicked = event => {
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

    return leftButtonClicked(event) &&
        !clickedOnDocumentScrollbar(event) &&
        !clickedOnElementScrollbar(event)
}

const togglePin = () => {
    browser.runtime.sendMessage({ toggle: true });
}

const prefs = async () => {
    const pref = await browser.storage.local.get()
    return pref
}

const handleMouse = () => {
    let timeoutHandle = null

    const handleMouseDown = async event => {
        if (validClick(event)) {
            const pref = await prefs()
            timeoutHandle = window.setTimeout(togglePin, pref.longClickToggleTime)
        }
    }

    const handleMouseUp = () => {
        // Don't bother to check if leftButtonClicked() here.
        // Even if it was another click after the timer has been set,
        // it means that user intends to carry out some multiple click operation.
        // So, we have to clear the timeout in that case anyway.
        timeoutHandle && window.clearTimeout(timeoutHandle)
    }

    const handleMouseMove = () => {
        timeoutHandle && window.clearTimeout(timeoutHandle)
    }

    const installListeners = () => {
        // https://stackoverflow.com/a/11986895
        // I cannot tinker with the event handler function directly
        // because I use removeEventListener later on, which needs identical arguments.
        window.addEventListener('mousedown', handleMouseDown, true);
        window.addEventListener('mouseup', handleMouseUp, true);
        window.addEventListener('mousemove', handleMouseMove, true);
    }

    const uninstallListeners = () => {
        window.removeEventListener('mousedown', handleMouseDown, true);
        window.removeEventListener('mouseup', handleMouseUp, true);
        window.removeEventListener('mousemove', handleMouseMove, true);
    }

    return {installListeners, uninstallListeners}
}

const main = async () => {
    const mouseHandle = handleMouse()

    browser.storage.onChanged.addListener(changes => {
        changes.longClickToggle.newValue
            ? mouseHandle.installListeners()
            : mouseHandle.uninstallListeners()
    })

    const configure = async () => {
        const pref = await prefs()
        pref.longClickToggle
            ? mouseHandle.installListeners()
            : mouseHandle.uninstallListeners()
    }
    configure()
}
main()
