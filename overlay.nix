final: prev: with prev.lib; let
  target = with systems.parse; tripleFromSystem (mkSystemFromString final.system);
  inherit (final.stdenv) mkDerivation;
in
{
  scripts = with final; rec {
    copy-derivation =
      let copy = writeScript "cp" ''
        install -Dpm755 $2 $(realpath -e $3)/$(realpath $2 --relative-base=$1)
      ''; in
      writeScript "cp" ''
        find $1 -type f -exec ${copy} $1 {} $2 \;
      '';

    cloneFromGitHub = attrs:
      let src = fetchFromGitHub attrs; in
      writeScript "clone" ''
        ${copy-derivation} ${src} $1
      '';
  };

  solana-testnet = mkDerivation rec {
    pname = "solana";
    version = "1.7.12";
    src = fetchTarball {
      url = "https://github.com/solana-labs/solana/releases/download/v${version}/${pname}-release-${target}.tar.bz2";
    };
    installPhase = ''
      install -Dm755 bin/* -t $out/bin
    '';
  };
  solana = mkDerivation rec {
    pname = "solana";
    version = "1.6.25";
    src = fetchTarball {
      url = "https://github.com/solana-labs/solana/releases/download/v${version}/${pname}-release-${target}.tar.bz2";
    };
    installPhase = ''
      install -Dm755 bin/* -t $out/bin
    '';
  };
}
