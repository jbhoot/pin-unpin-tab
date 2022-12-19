{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    melange.url = "github:melange-re/melange";
  };

  outputs = { self, ... }@inputs:
    let
      systems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" ];
      createDevShell = system:
        let
          pkgs =
            inputs.nixpkgs.legacyPackages.${system}.extend
              inputs.melange.overlays.default;
        in
        pkgs.mkShell {
          buildInputs = with pkgs.ocamlPackages; [
            ocaml
            reason
            findlib
            dune_3
            merlin
            dot-merlin-reader
            ocaml-lsp
            pkgs.ocamlformat
            ocamlformat-rpc-lib
            melange
            mel
            utop

            pkgs.entr
            pkgs.nodejs
            pkgs.yarn
          ];

          shellHook = ''
            ln -sfn ${pkgs.ocamlPackages.melange}/lib/melange/runtime node_modules/melange
          '';
        };
    in
    {
      devShell = inputs.nixpkgs.lib.genAttrs systems createDevShell;
    };
}
