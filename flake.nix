{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {self, ...} @ inputs: let
    systems = ["x86_64-darwin" "aarch64-darwin" "x86_64-linux"];
    createDevShell = system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
    in
      pkgs.mkShell {
        buildInputs =
          [
            pkgs.entr
            pkgs.nodejs
            pkgs.opam
          ]
          # solution to "fatal error: 'CoreServices/CoreServices.h' file not found"
          # https://github.com/commercialhaskell/stack/issues/1698#issuecomment-178098712
          # https://github.com/idris-lang/Idris-dev/pull/2938
          ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [
            # macOS framework build inputs
            CoreServices
          ]);

        shellHook = ''
          eval $(opam env)
        '';
      };
  in {
    devShell = inputs.nixpkgs.lib.genAttrs systems createDevShell;
  };
}
