{
  pkgs,
  inputs,
  ...
}: let
  firmware = import inputs.glove80-zmk {inherit pkgs;};

  board' = opts: board:
    firmware.zmk.override (opts // {inherit board;});

  zmkConfig = opts: let
    board = board' opts;
  in
    firmware.combine_uf2 (board "glove80_lh") (board "glove80_rh");
in
  zmkConfig {
    keymap = "${../src}/main.dts";
    kconfig = ../glove80.conf;
    extraModules = [inputs.zmk-helpers];
  }
