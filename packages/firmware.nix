{ pkgs, inputs, ... }:
let
  firmware = import inputs.glove80-zmk { inherit pkgs; };

  keymap = "${../src}/main.dts";
  kconfig = ../glove80.conf;
  extra_modules = [ inputs.zmk-helpers ];

  left = firmware.zmk.override {
    inherit keymap kconfig extra_modules;
    board = "glove80_lh";
  };

  right = firmware.zmk.override {
    inherit keymap kconfig extra_modules;
    board = "glove80_rh";
  };
in
firmware.combine_uf2 left right
