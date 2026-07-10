{ config, pkgs, inputs, ... }:

{
  programs = {
    appimage = { enable = true; binfmt = true; };  
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      ohMyZsh = { enable = true; theme = "fino"; };
    };
    xfconf = { enable = true; };
    dconf = { enable = true; };
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        pkgs.thunar-archive-plugin
        pkgs.thunar-volman
      ];
    };
  };
}
