{ nix2containerPkgs, pkgs }:
{
  builder =
    {
      imageName ? null,
      presentation ? null,
      tag ? "latest",
    }:
    let
    in
    nix2containerPkgs.nix2container.buildImage {
      name = imageName;
      tag = tag;
      maxLayers = 100;

      layers = [
        # dependencies layer
        (nix2containerPkgs.nix2container.buildLayer { deps = presentation.buildInputs; })
      ];

      copyToRoot = [
        (pkgs.buildEnv {
          name = "root";
          paths =
            with pkgs;
            with pkgs.dockerTools;
            [
              presentation

              fakeNss
              tzdata

              bashInteractive
              coreutils
              usrBinEnv
              binSh
            ];
          ignoreCollisions = false;
          pathsToLink = [
            "/bin"
            "/var"
            "/run"
            "/tmp"
            "/etc"
            "/share"
          ];
        })
      ];

      config = {
        WorkingDir = "/";
        Cmd = [
          "${presentation}/bin/IBC_2024_presentation"
          "--host"
          "0.0.0.0"
        ];
        Expose = 3838;
      };
    };
}
