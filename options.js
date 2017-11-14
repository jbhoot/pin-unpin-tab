const preferencesForm = document.querySelector('#preferences');
const shortcutInput = document.querySelector('#shortcut');
const restoreDefaultShortcutButton = document.querySelector('#restore-default-shortcut')

const defaultShortcut = browser.runtime.getManifest()
  .commands.toggle_pinned_status.suggested_key.default;

browser.storage.local.get()
  .then(
    storage => {
      console.log(storage)
      shortcutInput.value = storage.shortcut || defaultShortcut;
    },
    console.error
  );

preferencesForm.addEventListener('submit', event => {
  event.preventDefault();

  setShortcut(shortcutInput.value)
});

restoreDefaultShortcutButton.addEventListener('click', event => {
  event.preventDefault();

  setShortcut(defaultShortcut);
  shortcutInput.value = defaultShortcut;
})

function setShortcut(shortcut) {
  try {
    browser.storage.local.set({shortcut});
  } catch(e) {
    console.error(e)
  }
}
