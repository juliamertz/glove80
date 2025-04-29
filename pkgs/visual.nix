{
  pkgs,
  lib,
  stdenvNoCC,
  writeText,
}: let
  keymapDrawer = pkgs.python3Packages.callPackage ./keymap-drawer.nix {};

  configuration =
    writeText "config.yaml"
    # yaml
    ''
      draw_config:
        split_gap: 30.0
        dark_mode: true
        line_spacing: 1.2
        arc_radius: 6.0
    '';
in
  stdenvNoCC.mkDerivation {
    name = "layout-visualization";
    src = ../.;

    buildPhase = ''
      mkdir -p $out
      ${lib.getExe keymapDrawer} -c ${configuration} parse -c 10 -z ${../src/main.dts} > $out/layout.yaml
      ${lib.getExe keymapDrawer} -c ${configuration} draw --qmk-keyboard glove80 $out/layout.yaml > $out/layout.svg
    '';
  }
