{ config, pkgs, inputs,  ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./seraphim.nix
    ];

  # Hardware Settings
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
      ];
    };
    bluetooth = { enable = true; };
  };
  
  

  # Nix Settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.cryptix = { pkgs, ... }: {
      imports = [ ./ghostty.nix ./niri.nix ];
      home.stateVersion = "25.11";
    };
  };

  # Global System Environment
  environment = {
    sessionVariables = { QT_QPA_PLATFORMTHEME = "qt6ct"; };
    shellAliases = { 
      path = "echo $PATH | tr ':' '\n' | nl"; 
      fonts = "fc-list | sort -u";
      config = "sudo nano /etc/nixos/configuration.nix";
    };
    extraInit = '' export PATH="$HOME/.guix-profile/bin:$HOME/.config/guix/current/bin:$PATH"; '';
    systemPackages = with pkgs; [
      wget
      git
      niri
      fuzzel
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
      polkit
      gtk3
      qt6Packages.qt6ct
      nwg-look
      quickshell
      micro-full
      file
      home-manager
      obsidian
      wl-clipboard
      vscodium
      foliate
      prismlauncher
      krita
      texstudio
      miktex
      guix
      inputs.zen-browser.packages.x86_64-linux.default
      inputs.noctalia.packages.x86_64-linux.default
      feh
      mpv
      ncspot
      fzf
      reaper
      
    ] ++ (with yaziPlugins; [wl-clipboard drag ouch gvfs sudo chmod gitui piper office compress clipboard mediainfo rich-preview]);
  };

  # Service Settings
  services = {
    openssh = { enable = true; };
    udisks2 = { enable = true; };
    xserver = { 
      enable = true; 
      xkb = { layout = "us"; variant = ""; }; 
    };
#   displayManager.sddm = { enable = true; wayland.enable = true; };
    tuned = { enable = true; };
    upower = { enable = true; };  
    flatpak = { enable = true; };
    printing = { enable = true; };
    pulseaudio = { enable = false; };
    pipewire = { 
      enable = true; 
      alsa = { enable = true; support32Bit = true; }; 
      pulse.enable = true; 
    };
    libinput = { enable = true; };
    guix = {
      enable = true;
      package = pkgs.guix;
      gc.enable = true;
      storeDir = "/gnu/store";
      stateDir = "/var";
    };
  };
  
  # Security Settings
  security = {
    polkit = { enable = true; };
    rtkit = { enable = true; };
  };
  
  # Networking Settings, proxy optional
  networking = {
    firewall = { enable = true; };
    wireless = { enable = true; };
    networkmanager = { enable = true; };
#   proxy = { default = "http://user:password@proxy:port/"; noProxy = "127.0.0.1,localhost,internal.domain"; };
  };

  # Boot Settings
  boot = { 
    loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Time Zone
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Programs Settings: An alternative to package install for programs that need special settings set.
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Optional: for Steam Remote Play
      dedicatedServer.openFirewall = true; # Optional: for Source Dedicated Server
    };
    niri = { enable = true; };
    appimage = { enable = true; binfmt = true; };  
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      ohMyZsh = { enable = true; theme = "fino"; };
    };
    noctalia-greeter = {
      enable = true;
      package = inputs.noctalia-greeter.packages.x86_64-linux.default;
      greeter-args = "--session niri";
      settings = {
        cursor = { theme = "Adwaita"; size = 24; };
        keyboard = { layout = "us"; };
      };
    };
  };
  
  # Nixpkgs Configuration
  nixpkgs.config = { 
    packageOverrides = pkgs: {    
      steam = pkgs.steam.override { extraArgs = "-system-composer -no-cef-sandbox"; };
    };
    allowUnfree = true;
  };

  # XDG Portal Settings
  xdg.portal = {
    enable = true; 
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
    
  };

  # User Account Configuration
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
    ];
  };
  
  # System Fonts, grabs ALL nerdfonts by default
  fonts.packages = with pkgs; [ ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
