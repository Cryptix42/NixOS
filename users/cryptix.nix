{ config, pkgs, inputs, ... }:

{

  users.users.cryptix = {
    isNormalUser = true;
    description = "Jonathan";
    extraGroups = [ "guixBuild" "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ 

      ## Interpreted programming languages ##
      python315

      ## Compiled programming languages  ##
      gcc # C/C++ language
      odin # Odin language
      nim # Nim language
      nimble # package manager for Nim

      ## God's chosen programming languages (Multi-paradigm Lisp family) ##
      sbcl # Steel Bank Common Lisp type2
      guile # Scheme R5RS Lisp type1
      chez # Scheme R6RS Lisp type1
      chicken # Scheme R7RS Lisp type1

      ## Math stuff for school ##
      miktex # LaTeX toolchain
      texstudio # LaTeX IDE

      ## Various KDE apps I have yet to replace ##
      krita # KDE paint
      kdePackages.ark # KDE archive opener
      kdePackages.kate # KDE notepad and code editor
      kdePackages.kdenlive # KDE video editor

      ## My Go-to Apps ##
      obs-studio # Video recording and streaming
      zathuraPkgs.zathuraWrapper # Minimal document viewer with plugins (PDF, PostScript, DjVu, etc)
      foliate # Ebook and PDF reader
      emacs # Extensable text editor + LISP interpreter 
      freecad # Parametric modelling software
      prismlauncher # Minecraft client
      obsidian # Markdown notes app

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
