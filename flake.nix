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
    # dtsfmt = {
    #   url = "github:juliamertz/dtsfmt/dev?submodules=1";
    #   flake = false;
    # };
    # treesitter-devicetree = {
    #   url = "github:mskelton/tree-sitter-devicetree";
    #   flake = false;
    # };
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
                pkgs.writeText ".dtsfmtrc.toml" # toml
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
