Instructions are for macOS, tested on Big Sur.

# Set up OCaml environment

1. install `opam` - OCaml package manager, which itself can be used to install OCaml

```sh
brew install opam
opam init
eval `opam env`
```

1. install ocaml compiler version 4.11.1

```sh
opam switch create 4.11.1
eval `opam env`
```

1. install ocaml's build system `dune`

```sh
opam install dune
```

# Set up project's dependencies

1. install project dependencies

```sh
opam install js_of_ocaml js_of_ocaml-ppx js_of_ocaml-lwt lwt_ppx promise_jsoo
```


# Build project

1. go to project root where `build.sh` is located

```sh
cd pin-unpin-tab
```

1. To run the extension in dev mode, run the dev script.

```sh
sh run-dev.sh
```

1. To build the extension, run the build script.

```sh
sh build.sh
```

The built `zip` is generated in `_build/default/web-ext-artifacts` dir. The rest of the build artifacts in `_build` dir can be ignored.