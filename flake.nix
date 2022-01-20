{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/1f06456eabe9f768f87a26d3ff8b2dc14eb4046d";
    mypkgs.url = "github:jayesh-bhoot/nix-pkgs/60287b2ad6005e79df45cfe699b162cc6fce997e";
  };

  outputs = { self, nixpkgs, mypkgs }:
    let
      system = "x86_64-darwin";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShell.${system} = pkgs.mkShell {
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
          mypkgs.packages.${system}.promise_jsoo

          nodejs
          nodePackages.web-ext
        ];
      };
    };
}
