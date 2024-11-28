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
          plotly
          rmarkdown
          shiny
          cranlogs
          qrcode
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
        packages.presentation = pkgs.callPackage ./default.nix {
          inherit pkgs r-with-packages;
          src = pkgs.lib.sources.cleanSource ./.;
        };
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
