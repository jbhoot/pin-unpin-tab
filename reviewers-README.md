Instructions are for macOS.

## Pre-requisites

- nodejs
- yarn
- web-ext

## Steps

```sh
# 1. Install opam
# src: https://opam.ocaml.org/doc/Install.html
bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"

# 2. Init opam, which will also install a default OCaml compiler (which we don't need)
opam init

# 3. Install OCaml compiler v4.14.0
opam switch create 4.14.0

# 4. Bring the current shell env in sync with opam's env
eval $(opam env)

# 5. Install a build dependency - melange
opam install mel

# 6. Go to project's folder
cd pin-unpin-tab

# 7. Install dependencies
yarn install

# 8. Link melange runtime libs into our project's node_modules
ln -sfn $(opam var prefix)/lib/melange/runtime node_modules/melange

# 9a. Load the extension in dev mode
yarn test

# 9b. Build the extension
yarn build:ext
```
