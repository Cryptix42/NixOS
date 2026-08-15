{ config, pkgs, inputs, stable, beam, ... }:

{
  environment.sessionVariables = {
    EDITOR = "micro";
  };
  users.users.cryptix = {
    isNormalUser = true;
    description = "Jonathan";
    extraGroups = [ "guixBuild" "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ 

      ## Interpreted programming languages ##
      python314 # Python 3.14
      stable.erlang # Erlang language for VM Elixer and Gleam both use
      stable.gleam # Gleam language for Erlang VM
      beam.elixir_1_19 # Elixer language for Erlang VM

      ## Compiled programming languages  ##
      gcc # GNU C/C++ language
      clang # LLVM C/C++ language
      odin # Odin language
      nim # Nim language

      ## God's chosen programming languages (Multi-paradigm Lisp family) ##
      sbcl # Steel Bank Common Lisp type2
      guile # Scheme R5RS Lisp type1
      chez # Scheme R6RS Lisp type1
      chicken # Scheme R7RS Lisp type1

      ## LSPs (Language Server Protocols) and language tooling ##
      nil # nix LSP
      nimlangserver # Nim LSP
      python314Packages.python-lsp-server # Python LSP
      clang-tools # extra clang tooling + C/C++ LSP
      guile-lsp-server # Guile LSP
      chickenPackages_5.chickenEggs.lsp-server # Chicken LSP
      akkuPackages.scheme-langserver # Chez LSP
      llvm # Multilanguage toolchain, compiles LLVM-IR
      nimble # package manager for Nim
      akku # package manager for R6RS (Chez, or Guile in R6RS mode)
      beam.rebar3 # dependancy for Gleam using Erlang packages
      beam.elixir-ls # Elixer LSP, MAY SOON BE REPLACED BY "expert"
      stable.inotify-tools # Elixer file watching dependancy

      ## Math stuff for school ##
      miktex # LaTeX toolchain
      texstudio # LaTeX IDE

      ## Various KDE apps I have yet to replace ##
      krita # KDE paint
      kdePackages.ark # KDE archive opener
      kdePackages.kate # KDE notepad and code editor wuth LSP integration
      kdePackages.kdenlive # KDE video editor
      kdePackages.konsole # KDE terminal emulater, needed for Kate

      ## GUI Tools ##
      obs-studio # Video recording and streaming
      foliate # Ebook and PDF reader
      emacs # Extensable text editor + LISP interpreter 
      freecad # Parametric modelling software
      prismlauncher # Minecraft client
      obsidian # Markdown notes app
      inputs.zen-browser.packages.x86_64-linux.default # Visually minimal Firefox browser
      localsend # LAN filesharing
      ghostty # Terminal emulator
      feh # Minimal image viewer
      mpv # Minimal video player
      zathuraPkgs.zathuraWrapper # Minimal document viewer with plugins (PDF, PostScript, DjVu, etc)
      discord # Instant messaging
      # lmstudio # trying out as flatpak first
       
      ## Theming controls for Niri WM ##
      nwg-look
      gtk3
      qt6Packages.qt6ct
      matugen
      xdg-utils      
      adw-gtk3

      ## Needed for Niri WM functionality ##
      fuzzel # App launcher
      xwayland-satellite # xorg to wayland compatability package that Niri uses
      wl-clipboard # wayland clipboard
      
      ## TUI and CLI Tools ##
      btop # TUI process monitor
      gdu # TUI disk analyzer
      yazi # TUI file explorer
      superfile # TUI file explorer
      micro-full # TUI multibuffer text editor
      fileshare # CLI LAN file sharing
      eza # text colored alt to ls
      bat # text colored alt to cat
      dsearch # CLI fuzzy find filesystem search  
      fzf # TUI fuzzy find filesystem search

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
