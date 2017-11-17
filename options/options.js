const preferencesForm = document.querySelector('#preferences');
const shortcutInput = document.querySelector('#shortcut');
const restoreDefaultShortcutButton = document.querySelector('#restore-default-shortcut')

const defaultShortcut = browser.runtime.getManifest()
    .commands.toggle_pinned_status.suggested_key.default;

browser.storage.local.get()
    .then(
        storage => {
            shortcutInput.value = storage.shortcut || defaultShortcut;
        },
        console.error
    );

shortcutInput.addEventListener('focus', event => event.target.select());
shortcutInput.addEventListener('click', event => event.target.select());

const letterCodes = 'qwertyuiopasdfghjklzxcvbnm'.split('')
    .map(letter => `Key${letter.toUpperCase()}`);
const validateHotkey = event => (event.altKey || event.ctrlKey)
    && letterCodes.some(code => code === event.code)

shortcutInput.addEventListener('keydown', event => {
    if (event.key === 'Tab') return;

    event.preventDefault();

    if (validateHotkey(event)) {
        const ctrl = event.ctrlKey
            ? 'Ctrl+'
            : '';
        const alt = event.altKey
            ? 'Alt+'
            : '';
        event.target.value = ctrl + alt + event.code.slice(-1);
    }
});

// save shortcut
preferencesForm.addEventListener('submit', event => {
    event.preventDefault();
    setShortcut(shortcutInput.value);
});

// reset shortcut
restoreDefaultShortcutButton.addEventListener('click', event => {
    event.preventDefault();
    setShortcut(defaultShortcut);
    shortcutInput.value = defaultShortcut;
})

function setShortcut(shortcut) {
    try {
        browser.storage.local.set({shortcut});
    } catch(e) {
        console.error(e);
    }
}
