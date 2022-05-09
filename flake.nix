{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mypkgs.url = "github:jayesh-bhoot/nix-pkgs";
  };

  outputs = { self, nixpkgs, mypkgs }:
    let
      systems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" ];
      createDevShell = system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            ocaml
            ocamlPackages.findlib
            dune_2
            ocamlPackages.ocaml-lsp
            ocamlformat
            ocamlPackages.ocamlformat-rpc-lib
            ocamlPackages.utop

            ocamlPackages.js_of_ocaml
            ocamlPackages.js_of_ocaml-ppx
            ocamlPackages.js_of_ocaml-lwt
            ocamlPackages.lwt_ppx
            mypkgs.packages.${system}.promise_jsoo

            nodejs
            nodePackages.web-ext
          ];
        };
    in
    {
      devShell = nixpkgs.lib.genAttrs systems createDevShell;
    };
}