{ config, pkgs, inputs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "Nephilim";
  system.stateVersion = "25.11";
}
