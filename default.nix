{
  lib,
  pkgs,
  stdenv,
  src,
  r-with-packages,
  ...
}:
let
in
pkgs.stdenv.mkDerivation (finalAttrs: rec {
  pname = "IBC_2024_presentation";
  version = "0";
  src = ./.;

  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [
    r-with-packages
    pkgs.pandoc
    pkgs.coreutils
    pkgs.xdg-utils
    pkgs.which
  ];

  # To skip the Makefile
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/src
    mkdir -p $out/bin

    cp -r ./IBC_2024.Rmd $out/src/.
    # cp -r ./style.css $out/src/.
    cp -r ./start_presentation.R $out/src/.
    cp -r ./src $out/src/.

    cat <<EOF > $out/bin/IBC_2024_presentation
    #!${pkgs.bash}/bin/bash

    # R stuff to ensure no conflicts with existing R installation
    export R_LIBS_USER="'''"
    export LANG="C.UTF-8"
    export LC_ALL="C.UTF-8"

    export IBC_PRESENTATION_FILE="$out/src/IBC_2024.Rmd"
    export IBC_PRESENTATION_DIR="$out/src"

    help() {
        echo "Usage: presentation [options]"
        echo ""
        echo "Options:"
        echo "  --host <hostname>   The IPv4 address that the application should listen on."
    }

    HOST="127.0.0.1"
    while [ "\$1" != "" ]; do
      case "\$1" in
        --host)
            shift
            HOST="\$1"
            ;;
        --help)
            help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Error: Unkown argument \"\$1\""
            help
            exit 1
            ;;
      esac
      shift
    done
    export HOST


    Rscript --vanilla $out/src/start_presentation.R

    # could be nice to automatically
    # open the browser
    # xdg-open https://localhost:3838

    EOF
    chmod +x $out/bin/IBC_2024_presentation
  '';

  postFixup = ''
    wrapProgram $out/bin/IBC_2024_presentation \
    --set PATH ${lib.makeBinPath buildInputs}
  '';
})
