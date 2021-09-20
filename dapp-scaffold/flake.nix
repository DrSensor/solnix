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
              ${cloneFromGithub {
                owner = "solana-labs";
                repo = "dapp-scaffold";
                rev = "main";
                sha256 = "1jkkiik3b4q5rh8kshnw1x0ps1gwk9bz7rffapv6wa7v4vy2ipyy";
              }} ./
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
