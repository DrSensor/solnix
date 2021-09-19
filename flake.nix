{
  outputs = inputs@{ self, nixpkgs }:
    let
      # UNIX only (including WSL)
      givenSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helpers to instantiate nixpkgs for supported system types.
      give = with nixpkgs.lib; let forAllSystems = f: genAttrs givenSystems (system: f system); in
      f: forAllSystems (system: f (import nixpkgs { inherit system; overlays = [ self.overlay ]; }));
    in
    {
      packages = give ({ pkgs, mkShell, lib, ... }: with lib; {

        # nix develop github:drsensor/solnix#metaplex
        metaplex = mkShell {
          packages = with pkgs; [ nodejs yarn cargo ];
          shellHook = with pkgs;
          optionalString (!(pathExists ./.gitignore)) ''
            find ${metaplex-src} -type f -exec ${copy-drv} ${metaplex-src} {} ./ \;
          '';
        };

        # nix develop github:drsensor/solnix#dapp-scaffold
        dapp-scaffold = mkShell {
          packages = with pkgs; [ nodejs yarn cargo ];
          shellHook = with pkgs;
          optionalString (!(pathExists ./.gitignore)) ''
            find ${dapp-scaffold-src} -type f -exec ${copy-drv} ${dapp-scaffold-src} {} ./ \;
          '';
        };
      });

      # extra pkgs
      overlay = final: prev: with prev.lib; {
        nodejs = prev.nodejs-16_x;
        lib = prev.lib // rec {
          nodePackages-prefix = "node_";
          nodePackages-getName = drv: removePrefix nodePackages-prefix (getName drv);
        };
        # TODO: add solana prebuilt binaries
        copy-drv = final.writeScript "cp" ''
          install -Dpm755 $2 $(basename $3)/$(realpath $2 --relative-base=$1)
        '';
        metaplex-src = final.fetchFromGitHub {
          owner = "metaplex-foundation";
          repo = "metaplex";
          rev = "master";
          sha256 = "1m87xzffc87zgkpspgqlhsync7iimv8jjjh328g0f9ga92gn8w8a";
        };
        dapp-scaffold-src = final.fetchFromGitHub {
          owner = "solana-labs";
          repo = "dapp-scaffold";
          rev = "main";
          sha256 = "1jkkiik3b4q5rh8kshnw1x0ps1gwk9bz7rffapv6wa7v4vy2ipyy";
        };
      };
    };
}
