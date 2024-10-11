{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    glove80-zmk = {
      url = "github:darknao/zmk/darknao/rgb-dts";
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
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
          inherit (pkgs) callPackage writeShellScriptBin;
          inherit (config) packages;
          firmwareLoader = firmware-loader.packages.${system}.default;
        in
        {
          packages.firmware = callPackage ./packages/firmware.nix { inherit inputs; };
          packages.visual = callPackage ./packages/visual.nix { inherit inputs; };
          packages.flash = writeShellScriptBin "flash" ''
            ${lib.getExe firmwareLoader} --file ${packages.firmware}/glove80.uf2
          '';

          packages.default = packages.firmware;
          apps.default = {
            type = "app";
            program = packages.flash;
          };
        };
    };
}
