import {defaultHotkey, getHotkey, serializeHotkey, setHotkey, validateHotkey} from '../hotkey'

const form = document.querySelector('#options');
const hotkeyInput = document.querySelector('#hotkey');
const restoreDefaulthotkeyButton = document.querySelector('#restore-default-hotkey')

getHotkey()
    .then(hotkey => hotkeyInput.value = hotkey)
    .catch(console.error);

hotkeyInput.addEventListener('focus', event => event.target.select());
hotkeyInput.addEventListener('click', event => event.target.select());


hotkeyInput.addEventListener('keydown', event => {
    if (event.key === 'Tab') return;

    event.preventDefault();

    if (validateHotkey(event)) {
        event.target.value = serializeHotkey(event)
    }
});

// save hotkey
form.addEventListener('submit', event => {
    event.preventDefault();
    setHotkey(hotkeyInput.value);
});

// reset hotkey
restoreDefaulthotkeyButton.addEventListener('click', event => {
    event.preventDefault();
    setHotkey(defaultHotkey);
    hotkeyInput.value = defaultHotkey;
})

