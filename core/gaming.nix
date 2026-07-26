{ config, pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Optional: for Steam Remote Play
      dedicatedServer.openFirewall = true; # Optional: for Source Dedicated Server
    };
  };
  services = {
    wivrn = {
      enable = true;
      openFirewall = true;
      steam = { enable = true; importOXRRuntimes = true; };
    };
  };
#  hardware.graphics.extraPackages = [ 
#    libva-vdpau-driver
#    libvdpau-va-gl 
#  ];
}
