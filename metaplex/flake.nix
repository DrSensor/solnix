{
  inputs = {
    solnix.url = "github:drsensor/solnix";
  };
  outputs = inputs@{ self, nixpkgs, solnix }:
    let
      # UNIX only (including WSL)
      givenSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helpers to instantiate nixpkgs for supported system types.
      give = with nixpkgs.lib; let forAllSystems = f: genAttrs givenSystems (system: f system); in
      f: forAllSystems (system: f (import nixpkgs { inherit system; overlays = [ solnix.overlay self.overlay ]; }));
    in
    {
      # nix develop
      devShell = give ({ pkgs, mkShell, lib, ... }: with lib;
        mkShell {
          packages = with pkgs; [ nodejs yarn cargo solana ];
          shellHook = with pkgs.scripts;
            optionalString (!(pathExists ./.gitignore)) ''
              ${cloneFromGitHub {
                owner = "metaplex-foundation";
                repo = "metaplex";
                rev = "master";
                sha256 = "03invymsz6bm2pa8v8k26a0g6gbrsrh64vz6s4n96bk5y6iabn9w";
              }} ./
            '' + ''
              pushd js
                [ -d node_modules ] || yarn install
              popd
              pushd rust
                [ -d target ] || cargo check
              popd
              export NODE_PATH=$(realpath ./node_modules)
              export PATH=$(realpath ./node_modules/.bin):$PATH
            '';
        }
      );

      # override pkgs
      overlay = final: prev: with prev.lib; {
        nodejs = prev.nodejs-16_x;
        solana = prev.solana-testnet;
      };
    };
}
