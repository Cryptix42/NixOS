{ config, pkgs, inputs, ... }:
{
  imports = [ 
    ./hardware-configuration.nix 
    ../../desktops/niri.nix
    ../../core/default.nix
    ../../users/cryptix.nix
    ../../home/home-manager.nix
  ];

  networking.hostName = "Nephilim";
  system.stateVersion = "25.11";
}
