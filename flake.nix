{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    promiseJsooChan.url = "github:jayesh-bhoot/nixpkgs/promise_jsoo";
    ocamlVdomChan.url = "github:jayesh-bhoot/nixpkgs/ocaml-vdom";
  };

  outputs = { self, nixpkgs, promiseJsooChan, ocamlVdomChan }:
    let
      systems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" ];
      createDevShell = system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        let
          promiseJsooChanPkgs = import promiseJsooChan { inherit system; };
          ocamlVdomChanPkgs = import ocamlVdomChan { inherit system; };
        in
        pkgs.mkShell {
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
            promiseJsooChanPkgs.ocamlPackages.promise_jsoo
            ocamlVdomChanPkgs.ocamlPackages.ocaml-vdom

            nodejs
            nodePackages.web-ext
          ];
        };
    in
    {
      devShell = nixpkgs.lib.genAttrs systems createDevShell;
    };
}
