{ config, pkgs, inputs, ... }:
{
  security = {
    polkit = { enable = true; };
    rtkit = { enable = true; };
    apparmor = { enable = true; };
  };   
}
