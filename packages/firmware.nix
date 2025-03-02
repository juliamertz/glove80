{ pkgs, inputs, ... }:
let
  firmware = import inputs.glove80-zmk { inherit pkgs; };
  board =
    board:
    firmware.zmk.override {
      inherit board;
      keymap = "${../src}/main.dts";
      kconfig = ../glove80.conf;
      snippets = [ inputs.zmk-helpers ];
    };

  left = board "glove80_lh";
  right = board "glove80_rh";
in
firmware.combine_uf2 left right
