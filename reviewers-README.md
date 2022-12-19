Instructions are for macOS.

## Pre-requisites

- nodejs
- yarn

## Steps

```sh
# 0. Ensure that nodejs and yarn are installed and are in PATH.

# 1. Install opam (src: https://opam.ocaml.org/doc/Install.html)
bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"

# 2. Init opam, which will also install a default OCaml compiler (which we don't need)
opam init

# 3. Install OCaml compiler v4.14.0
opam switch create 4.14.0

# 4. Bring the current shell env in sync with opam's env
eval $(opam env)

# 5. Install build dependencies
opam install mel reason

# 6. Go to project's folder
cd pin-unpin-tab

# 7. Install project and test dependencies
yarn install

# 8. Link a runtime lib into our project's node_modules
ln -sfn $(opam var prefix)/lib/melange/runtime node_modules/melange

# 9a. Load the extension in dev mode
yarn test

# 9b. Build the extension
yarn build:ext
```
