{ config, pkgs, inputs, ... }:
{
  imports = [ 
    inputs.noctalia-greeter.nixosModules.default 
    inputs.noctalia.nixosModules.default	
  ];

  environment.systemPackages = with pkgs; [ 
    inputs.noctalia.packages.x86_64-linux.default 
    xwayland-satellite
  ];

  nixpkgs.overlays = [
    (final: prev: {
      xwayland-satellite = inputs.xwayland-satellite.packages.${pkgs.system}.default;
    })
  ];
  
  services.displayManager.noctalia-greeter = {
    enable = true;
    package = inputs.noctalia-greeter.packages.x86_64-linux.default;
    greeter-args = "--session niri";
    settings = {
      cursor = { theme = "Adwaita"; size = 24; };
      keyboard = { layout = "us"; };
    };
  };
  
  programs = {
    niri = { enable = true; };
    noctalia = { enable = true; systemd.enable = true; };
    };
}
