{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ocaml
    ocamlPackages.findlib
    dune_2
    ocamlPackages.ocaml-lsp
    ocamlformat
    ocamlPackages.utop
    fswatch

    ocamlPackages.js_of_ocaml
    ocamlPackages.js_of_ocaml-ppx
    ocamlPackages.js_of_ocaml-lwt
    ocamlPackages.lwt_ppx
    ocamlPackages.promise_jsoo

    nodejs
    nodePackages.web-ext
  ];
}
