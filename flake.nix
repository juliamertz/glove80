{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    glove80-zmk = {
      url = "github:darknao/zmk/rgb-layer-24.12";
      flake = false;
    };
    zmk-helpers = {
      url = "github:urob/zmk-helpers";
      flake = false;
    };
    dtsfmt = {
      url = "github:juliamertz/dtsfmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firmware-loader = {
      url = "github:juliamertz/glove80-firmware-updater";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    keymap-drawer = {
      url = "github:caksoylar/keymap-drawer";
      flake = false;
    };
  };

  outputs = {
    systems,
    flake-parts,
    firmware-loader,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import systems;

      perSystem = {
        self',
        config,
        pkgs,
        lib,
        system,
        ...
      }: let
        inherit (pkgs) callPackage writeShellScriptBin writeText;
        inherit (config) packages;

        firmwareLoader = firmware-loader.packages.${system}.default;
        dtsfmt = inputs.dtsfmt.packages.${system}.default;
      in {
        packages = {
          default = self'.packages.firmware;
          firmware = callPackage ./packages/firmware.nix {inherit inputs;};
          visual = callPackage ./packages/visual.nix {inherit inputs;};
        };

        formatter = let
          dtsfmtrc =
            writeText ".dtsfmtrc.toml" # toml
            ''
              layout = "moergo:glove80"

              [options]
              separate_sections = true
              indent_size = 4
            '';
        in
          writeShellScriptBin "dtsfmt" ''
            ${lib.getExe dtsfmt} --config-file ${dtsfmtrc} $@
          '';

        apps.default = {
          type = "app";
          program = writeShellScriptBin "flash" ''
            ${lib.getExe firmwareLoader} --file ${packages.firmware}/glove80.uf2 --mount
          '';
        };

        checks.firmware = self'.packages.firmware;

        devShells.default = pkgs.mkShell {
          packages = [];
        };
      };
    };
}
