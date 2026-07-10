{ config, pkgs, inputs, ... }:
{
  imports = [ 
    ./hardware-configuration.nix  
    ../../desktops/niri.nix
    ../../core/default.nix
    ../../users/cryptix.nix
    ../../home/home-manager.nix
  ];

  networking.hostName = "Seraphim";

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = { enable = false; finegrained = false; };
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  system.stateVersion = "26.05";
}
