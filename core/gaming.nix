{ config, pkgs, ... }:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Optional: for Steam Remote Play
      dedicatedServer.openFirewall = true; # Optional: for Source Dedicated Server
    };
  };
}
