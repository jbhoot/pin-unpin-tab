export const defaultHotkey = browser.runtime.getManifest()
    .commands.toggle_pinned_status.suggested_key.default;

const _letterCodes = 'qwertyuiopasdfghjklzxcvbnm'.split('')
    .map(letter => `Key${letter.toUpperCase()}`);


const _serializeCtrlKey = event => event.ctrlKey ? 'Ctrl+' : '';
const _serializeAltKey = event => event.altKey ? 'Alt+' : '';
const _serializeShiftKey = event => event.shiftKey ? 'Shift+' : '';

export const serializeHotkey = event => _serializeCtrlKey(event)
    + _serializeAltKey(event)
    + _serializeShiftKey(event)
    + event.code.slice(-1);

export const getHotkey = () => browser.storage.local.get()
    .then(storage => Promise.resolve(storage.hotkey || defaultHotkey));

export const setHotkey = hotkey => {
    try {
        browser.storage.local.set({hotkey});
    } catch(e) {
        console.error(e);
    }
}


export const validateHotkey = event => (event.altKey || event.ctrlKey)
    && _letterCodes.some(code => code === event.code);

export const onHotkeyPress = event => {
    const input = serializeHotkey(event);

    return getHotkey()
        .then(hotkey => hotkey === input
            ? Promise.resolve()
            : Promise.reject()
        );
};
