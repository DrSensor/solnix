final: prev: with prev.lib; {
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
}
