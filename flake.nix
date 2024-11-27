{
  description = "Flake for a R environment";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";

    # for R packages (to use same nixpkgs as for other packages):
    rpkgs.url = "nixpkgs/nixos-24.05";
    # Or to use a specific R version;
    # check https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=R
    # to get the nixpkgs commit hash for each R versions:
    # rpkgs.url = "github:NixOS/nixpkgs/67b4bf1df4ae54d6866d78ccbd1ac7e8a8db8b73";

    plantbreedgame.url = "github:timflutre/PlantBreedGame/v1.1.1";

    flake-utils.url = "github:numtide/flake-utils";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      rpkgs,
      plantbreedgame,
      flake-utils,
      nix2container,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        Rpkgs = import rpkgs { inherit system; };
        plantbreedgamePkgs = plantbreedgame.packages.${system};
        nix2containerPkgs = nix2container.packages.${system};
        imageBuilder = (import ./dockerfile.nix { inherit nix2containerPkgs pkgs; }).builder;

        R-packages = with Rpkgs.rPackages; [
          # list necessary R packages here
          rmarkdown
          shiny

          # not in CRAN or Bioconductor:
          # https://github.com/r-for-educators/flair
          (pkgs.rPackages.buildRPackage {
            name = "flair";
            src = pkgs.fetchFromGitHub {
              owner = "r-for-educators";
              repo = "flair";
              rev = "5658aae1257bf5d57ef03dfcb2fcde35236b10ae";
              sha256 = "sha256-a3xRKZFVaEmpIdDRSrKHztk2CLDYLEaXhsVxgvQzvuI=";
            };
            propagatedBuildInputs = with pkgs.rPackages; [
              dplyr
              ggplot2
              glue
              htmltools
              knitr
              magrittr
              purrr
              rmarkdown
              stringr
            ];
          })
        ];
        R-packages-dev = with Rpkgs.rPackages; [
          # list R packages used for developement
          languageserver
        ];

        r-with-packages = (Rpkgs.rWrapper.override { packages = R-packages; });
        r-with-packages_dev = (Rpkgs.rWrapper.override { packages = R-packages ++ R-packages-dev; });
      in
      rec {
        packages = { };

        devShells.default = pkgs.mkShell {
          LOCALE_ARCHIVE =
            if "${system}" == "x86_64-linux" then "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive" else "";
          R_LIBS_USER = "''"; # to not use users' installed R packages
          R_PROFILE_USER = "''"; # to disable`.Rprofile` files (eg. if the project use `renv`)

          IBC_PRESENTATION_FILE = "./IBC_2024.Rmd";
          IBC_PRESENTATION_DIR = "./.";
          nativeBuildInputs = [ pkgs.bashInteractive ];
          buildInputs = [
            r-with-packages_dev
            (Rpkgs.rstudioWrapper.override { packages = R-packages ++ R-packages-dev; })
            plantbreedgamePkgs.plantBreedGame
            pkgs.pandoc
          ];
        };

        packages.presentation = pkgs.stdenv.mkDerivation (finalAttrs: rec {
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

            EOF
            chmod +x $out/bin/IBC_2024_presentation
          '';

          postFixup = ''
            wrapProgram $out/bin/IBC_2024_presentation \
            --set PATH ${nixpkgs.lib.makeBinPath buildInputs}
          '';
        });
        packages.default = packages.presentation;

        apps = rec {
          presentation = {
            type = "app";
            program = "${packages.presentation}/bin/IBC_2024_presentation";
          };
          default = presentation;
        };

        images = {
          latest =
            let
            in
            (imageBuilder {
              # imageName = "IBC2024presentation";
              imageName = "ghcr.io/juliendiot42/IBC_2024_presentation/IBC2024presentation";

              presentation = packages.presentation;
              tag = "latest";
            });
        };

      }
    );
}
