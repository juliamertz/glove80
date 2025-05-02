{
  pkgs,
  lib,
  writeText,
  runCommand,
  inputs,
  enableGamingLayer ? false,
  profile ? "default",
  ...
}: let
  firmware = import inputs.glove80-zmk {inherit pkgs;};

  withDefines = path: defines: let
    toStr = val:
      if builtins.isBool val
      then
        builtins.toString (
          if val
          then 1
          else 0
        )
      else builtins.toString val;

    definesText =
      defines
      |> lib.mapAttrsToList (name: value: "#define ${name} ${toStr value}")
      |> lib.concatStringsSep "\n";

    joined = [definesText (builtins.readFile path)] |> lib.concatStringsSep "\n\n";
  in
    writeText (builtins.baseNameOf path) joined;

  serializeKeyValueSet = let
    toStr = val:
      if builtins.isString val
      then ''"${val}"''
      else if builtins.isBool val
      then
        (
          if val
          then "y"
          else "n"
        )
      else builtins.toString val;
  in
    attrs:
      attrs
      |> lib.mapAttrsToList (key: value: "${key}=${toStr value}")
      |> lib.concatStringsSep "\n"
      |> pkgs.writeText "glove80.conf";

  zmkConfig = opts: let
    patchedKeymap = runCommand "glove80-config" {} ''
      mkdir -p $out
      ln -sf ${opts.src}/*.dtsi $out
      ln -sf ${withDefines "${opts.src}/main.dts" opts.defines} $out/main.dts
    '';

    cleanOpts = lib.removeAttrs opts ["defines" "src"];
    finalOpts = cleanOpts // {keymap = "${patchedKeymap}/main.dts";};

    board = board:
      firmware.zmk.override (finalOpts // {inherit board;});
  in
    firmware.combine_uf2 (board "glove80_lh") (board "glove80_rh");
in
  zmkConfig {
    src = ../src;
    kconfig = import ../config.nix {inherit lib profile;} |> serializeKeyValueSet;
    extraModules = [inputs.zmk-helpers];
    defines = {
      ENABLE_GAMING_LAYER = enableGamingLayer;
    };
  }
