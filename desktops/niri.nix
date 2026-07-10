{ config, pkgs, inputs, ... }:
{
  imports = [ 
    inputs.noctalia-greeter.nixosModules.default 
    inputs.noctalia.nixosModules.default
  ];
  
  programs = {
    niri = { enable = true; };
    noctalia = { enable = true; systemd.enable = true; };
    noctalia-greeter = {
      enable = true;
      package = inputs.noctalia-greeter.packages.x86_64-linux.default;
      greeter-args = "--session niri";
      settings = {
        cursor = { theme = "Adwaita"; size = 24; };
        keyboard = { layout = "us"; };
      };
    };
  };
}
