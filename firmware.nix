{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      packages.firmware =
        let
          firmware = import inputs.glove80-zmk { inherit pkgs; };

          keymap = ./glove80.keymap;
          kconfig = pkgs.writeText "glove80.conf" "";

          left = firmware.zmk.override {
            inherit keymap kconfig;
            board = "glove80_lh";
          };

          right = firmware.zmk.override {
            inherit keymap kconfig;
            board = "glove80_rh";
          };
        in
        firmware.combine_uf2 left right;
    };
}
