{ config, pkgs, inputs, ... }:

{
  environment = {
    sessionVariables = { 
      QT_QPA_PLATFORMTHEME = "qt6ct"; 
    };
    shellAliases = { 
      path = "echo $PATH | tr ':' '\n' | nl"; 
      fonts = "fc-list | sort -u";
      flakeup = "nix flake update";
      ".." = "cd ..";
      publicip = "curl https://ipinfo.io/ip";
    };
    extraInit = '' export PATH="$HOME/.guix-profile/bin:$HOME/.config/guix/current/bin:$PATH"; '';
    systemPackages = with pkgs; [
      wget
      git
      tmux
      file
      fastfetch
      ncdu
      pciutils
    ];
  };

}
