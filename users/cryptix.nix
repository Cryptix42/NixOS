{ config, pkgs, inputs, stable, beam, ... }:

{

  imports = [ 
    ../modules/guilefetch.nix 
    inputs.umbriel.nixosModules.default
  ];

  environment.sessionVariables = {
    EDITOR = "micro";
  };
  
  users.users.cryptix = {
    isNormalUser = true;
    description = "Jonathan";
    extraGroups = [ "guixBuild" "networkmanager" "wheel" "libvirtd" "kvm" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ 

      ## Interpreted programming languages ##
      (python3.withPackages (ps: with ps; [
        # --- Graphics / windowing ---
        pysdl2              # SDL2 bindings; for SDL3 see note below
        glfw                # pyGLFW
        pywayland           # Wayland protocol bindings
        raylib-python-cffi  # raylib (verify name)
        pygame-ce           # community pygame fork, SDL-based, easiest 2D
        pyglet              # pure-Python windowing + OpenGL, no C deps to fight
        pyopengl            # raw OpenGL calls
        moderngl            # modern, much nicer OpenGL wrapper
        pillow              # image loading/saving

        # --- Stats / data (for Applied Stats 2) ---
        numpy
        scipy               # scipy.stats lives here
        pandas
        statsmodels         # regression, ANOVA, GLMs, time series
        scikit-learn
        matplotlib
        seaborn             # statistical plots on top of matplotlib
        sympy               # symbolic math (handy for algebra too)

        # --- Workflow ---
        ipython
        jupyterlab          # notebooks; PyCharm can also open .ipynb
        rich                # pretty terminal output/tracebacks
        requests
      ]))
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
##      chickenPackages_5.chickenEggs.lsp-server # Chicken LSP
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
      pycharm
      clion
      godot
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
      libreoffice # Office suite
      nyxt
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
      dux-search # CLI fuzzy find filesystem search  
      fetch # +1 larp 
      fzf # TUI fuzzy find filesystem search
      kew # TUI audio player
      mmtui # TUI disk mounter
      wiremix # TUI pipewire mixer
      fetch # stupidly fancy fastfetch 
      catnip # TUI audio visualizer
     
    ];
  };

  services.guix.enable = false;

##  UmbrielWM Config  ##

  programs.umbriel.enable = true;
  home-manager.users.cryptix = { config, ... }: {
    imports = [
      ../modules/niri.nix
      ../home/dot-files/ghostty.nix
      inputs.umbriel.homeModules.default
    ];
    programs.umbriel = {
      enable = true;
      settings = {
        general.autostart = [ "noctalia" ];
        layout.gap = 5;
        input.keyboard.layout = "us";
        input.cursor.follows_focus = true;
        keybinds = {
          "Mod+Return"  = "spawn ghostty";
          "Mod+Q"       = "window-close";
          "Mod+V"       = "window-toggle-floating";
          "Mod"         = "spawn noctalia msg panel-toggle launcher";
          "Mod+left"    = "window-focus-or-output-left";
          "Mod+right"   = "window-focus-or-output-right";
          "Mod+up"      = "window-focus-or-workspace-up";
          "Mod+down"    = "window-focus-or-workspace-down";
          "Mod+C"       = "column-center";
          "Mod+O"       = "overview-toggle";
          "Mod+F"       = "window-toggle-maximize";
          "Mod+Shift+F" = "window-toggle-fullscreen";

          "Mod+Equal"        = "window-modify-primary-extent 0.1";
          "Mod+Minus"         = "window-modify-primary-extent -0.1";
          "Mod+Shift+Equal"  = "window-modify-secondary-extent 0.1";
          "Mod+Shift+Minus"   = "window-modify-secondary-extent -0.1";

          "Mod+Shift+1"       = "spawn umbriel msg workspace-set-layout scrolling";
          "Mod+Shift+2" = "spawn umbriel msg workspace-set-layout dwindle";
          "Mod+Shift+3" = "spawn umbriel msg workspace-set-layout master";
          "Mod+Shift+4" = "spawn umbriel msg workspace-set-layout stacking";
          
          "Mod+Shift+left"  = "window-move-or-output-left";
          "Mod+Shift+right" = "window-move-or-output-right";
          "Mod+Shift+up"    = "window-move-or-workspace-up";
          "Mod+Shift+down"  = "window-move-or-workspace-down";
          "Mod+Alt+left"    = "window-consume-or-expel-left";
          "Mod+Alt+right"   = "window-consume-or-expel-right";

          "Mod+Shift+S"     = "window-move-to-scratchpad";
          "Mod+S"           = "scratchpad-toggle";
          "Mod+Control+S"   = "window-restore-from-scratchpad";
          "Mod+Alt+S"       = "scratchpad-focus-next";

          "Mod+Tab"         = "cheatsheet-toggle";

        };
      };
    };

##  NiriWM Config  ##

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

##  Virtual Machine  ##
  virtualisation.libvirtd = {
    enable = true;	
    qemu.swtpm.enable = true;
  };
  programs.virt-manager.enable = true;
  
}
