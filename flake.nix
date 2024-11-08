{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    glove80-zmk = {
      url = "github:juliamertz/zmk";
      flake = false;
    };
    zmk-helpers = {
      url = "github:urob/zmk-helpers";
      flake = false;
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

  outputs =
    {
      nixpkgs,
      flake-parts,
      firmware-loader,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem =
        {
          config,
          pkgs,
          lib,
          system,
          ...
        }:
        let
          inherit (pkgs) callPackage writeShellScriptBin writeText;
          inherit (config) packages;

          firmwareLoader = firmware-loader.packages.${system}.default;
          dtsfmt = callPackage ./packages/dtsfmt.nix { inherit inputs; };
        in
        {
          packages.firmware = callPackage ./packages/firmware.nix { inherit inputs; };
          packages.visual = callPackage ./packages/visual.nix { inherit inputs; };
          packages.flash = writeShellScriptBin "flash" ''
            ${lib.getExe firmwareLoader} --file ${packages.firmware}/glove80.uf2 --mount
          '';
          packages.format =
            let
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

          devShells.default = pkgs.mkShell { packages = [ packages.format ]; };

          packages.default = packages.firmware;
          apps.default = {
            type = "app";
            program = packages.flash;
          };
        };
    };
}
