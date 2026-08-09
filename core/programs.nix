{ config, pkgs, inputs, ... }:

{
  programs = {
    appimage = { enable = true; binfmt = true; };  
    zoxide = {
      enable = true;
      enableZshIntegration = true;	
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      ohMyZsh = { 
        enable = true; 
        theme = "fino"; 
        plugins = [
          "zsh-interactive-cd"
          "z"
          "alias-finder"
        ];
      };
      
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
