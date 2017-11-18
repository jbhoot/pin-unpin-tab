Pin Unpin Tab is a Firefox WebExtension that toggles the pinned status of the active tab.

Currently, the add-on provides the following methods:

- Custom keyboard shortcut from addon preferences page. Defaults to `Alt+P`.
- A click on the pin icon on browser toolbar

## Development

### Installation

#### Firefox

#### node
[Manually download](https://nodejs.org/en/download/) or install with a package manager such as homebrew:
```bash
brew install node
```

#### yarn
*If not on a Mac, see the [official installation instructions](https://yarnpkg.com/en/docs/install).*
```bash
brew install yarn
```

#### Clone repo
```bash
git clone https://github.com/jayesh-bhoot/pin-unpin-tab
cd pin-unpin-tab
```

#### Package dependencies
From the directory's root, run:
```bash
yarn
```

### Workflow
Activate the `webpack` file watcher and `web-ext` with:
```bash
yarn dev
```

### Build an unsigned release artifact
```bash
yarn build-artifact
# => ./releases/pin_unpin_tab-X.X-unsigned.xpi
```

Start editing! 👷

## Planned Enhancements

This section lists the enhancements I have in mind. Though I am not sure if the WebExtension API possesses the required capabilities. We will see as we go.

- Double-click on a tab (active or not) to toggle the pinned status
