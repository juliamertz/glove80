{
  lib,
  profile,
}: {
  CONFIG_EXPERIMENTAL_RGB_LAYER = true;
  CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_IDLE = true;
  CONFIG_ZMK_IDLE_TIMEOUT = 300000;
  CONFIG_BT_DEVICE_NAME = "Julia's ${lib.optionalString (profile == "work") "Work "}Glove80";
}
