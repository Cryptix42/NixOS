{ config, pkgs, inputs, ... }:

{

  users.users.cryptix = {
    isNormalUser = true;
    description = "Jonathan";
    extraGroups = [ "guixBuild" "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ 
      python315
      llvm
      odin
      emacs
      nim
      sbcl
      chez
      gcc
      clang
      reaper
      miktex
      texstudio
      vscodium
      foliate
      prismlauncher
      obsidian
      krita
      guile
      kdePackages.ark
      kdePackages.kate
      kdePackages.kdenlive
      obs-studio
    ];
  };

  services.guix.enable = false;

  home-manager.users.cryptix = { config, ... }: {
    imports = [
      ../modules/niri.nix
      ../home/dot-files/ghostty.nix
    ];
    myHome.niri = {
      enable = true;
      prefNoCsd = true;
      terminal = "ghostty";
      spawnAtStartup = [ "noctalia" ];
      gaps = 4;
      windowRules = [
        { geometryCornerRadius = [ 8 8 0 0 ]; clipToGeometry = true; }
        {
          matches = [ { is-focused = false; } ];
          excludes = [ { app-id = "zen"; } ];
          backgroundEffect.blur = true;
          opacity = 0.8;
        }
      ];
    };
    home.stateVersion = "25.11";
  };

  imports = [ ../modules/guilefetch.nix ];

  programs.guilefetch = {
    enable = true;
    logoFile = ../assets/seraphim-logo.txt;
    logoAlign = "center";
    storageMounts = [ "/" ];
    order = [
      "title" "rule" "os" "kernel" "packages" "cpu" "gpu" "ram" "storage"
      "shell" "editor" "terminal" "wm" "gui-shell" "uptime"
    ];
    extraEntries.uptime = {
      label = "Uptime";
      command = "uptime -p | sed 's/^up //'";
    };
  };
}
