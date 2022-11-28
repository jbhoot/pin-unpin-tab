{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" ];
      createDevShell = system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            bashInteractive
          ];

          buildInputs = with pkgs; [
            ocaml
            ocamlPackages.findlib
            dune_3
            ocamlPackages.ocaml-lsp
            ocamlformat
            ocamlPackages.ocamlformat-rpc-lib
            ocamlPackages.utop

            ocamlPackages.js_of_ocaml
            ocamlPackages.js_of_ocaml-ppx
            ocamlPackages.js_of_ocaml-lwt
            ocamlPackages.lwt_ppx
            ocamlPackages.gen_js_api
            ocamlPackages.promise_jsoo
            ocamlPackages.ocaml-vdom

            nodejs
            nodePackages.web-ext
          ];
        };
    in
    {
      devShell = nixpkgs.lib.genAttrs systems createDevShell;
    };
}
