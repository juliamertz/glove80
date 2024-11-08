{
  pkgs,
  lib,
  stdenvNoCC,
  writeText,
  inputs,
}:
let
  poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };
  keymapDrawer = lib.getExe (
    poetry2nix.mkPoetryApplication {
      projectDir = inputs.keymap-drawer;
      preferWheels = true;
      meta.mainProgram = "keymap";
    }
  );
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
    ${keymapDrawer} -c ${configuration} parse -c 10 -z ${../src/main.dts} > $out/layout.yaml
    ${keymapDrawer} -c ${configuration} draw --qmk-keyboard glove80 $out/layout.yaml > $out/layout.svg
  '';
}
