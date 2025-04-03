# Guide to compile and test run the web extension

Instructions are tested on macOS.

The following code snippet couples the description (as a bash comment) and the command of each step.

```sh
# 0. Install nodejs and ensure that it is in the PATH.

# 1. Install opam - OCaml's package manager.
# src: https://opam.ocaml.org/doc/Install.html
bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"

# 2. Initialise opam
opam init --bare

# 3. Go to project's folder
cd pin-unpin-tab

# 4. Set up a switch with OCaml compiler version 4.14.1. A switch is roughly equivalent to a virtualenv in Python.
opam switch create . 4.14.1 -y --deps-only

# 5. Bring the current shell env in sync with opam's env
eval $(opam env)

# 6. Install dependencies
opam install -y . --deps-only
npm ci

# 7a. Load the extension in dev mode
npm run test

# 7b. Build the extension
npm run build:ext
```
