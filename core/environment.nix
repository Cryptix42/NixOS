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
    };
    extraInit = '' export PATH="$HOME/.guix-profile/bin:$HOME/.config/guix/current/bin:$PATH"; '';
    systemPackages = with pkgs; [
      wget
      git
      ghostty
      nh
      btop
      bat
      eza
      nix-output-monitor
      matugen
      fastfetch
      dsearch
      xwayland-satellite
      yazi
      gtk3
      qt6Packages.qt6ct
      nwg-look
      micro-full
      file
      wl-clipboard
      inputs.zen-browser.packages.x86_64-linux.default
      inputs.noctalia.packages.x86_64-linux.default
      fuzzel
      feh
      mpv
      ncspot
      fzf
      xdg-utils      
      adw-gtk3
      localsend
      helium
    ] ++ (with yaziPlugins; [wl-clipboard drag ouch gvfs sudo chmod gitui piper office compress clipboard mediainfo rich-preview]);
  };

}
