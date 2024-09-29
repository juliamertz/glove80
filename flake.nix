{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    glove80-zmk = {
      url = "github:moergo-sc/zmk";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = [ ./firmware.nix ];

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          packages.default = config.packages.firmware;
          packages.flash =
            let
              firmwareLoader = pkgs.callPackage ./flash { };
            in
            pkgs.writeShellScriptBin "flash" # sh
              ''
                ${pkgs.lib.getExe firmwareLoader} --file ${config.packages.firmware} 
              '';

          apps.default = {
            type = "app";
            program = config.packages.flash;
          };
        };
    };
}
