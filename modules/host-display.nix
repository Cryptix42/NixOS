{ lib, ... }:
{
  options.myHost.monitors = lib.mkOption {
    default = { };
    type = lib.types.attrsOf (lib.types.submodule { options = {
      mode = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
      x    = lib.mkOption { type = lib.types.int; default = 0; };
      y    = lib.mkOption { type = lib.types.int; default = 0; };
    }; });
  };
}
