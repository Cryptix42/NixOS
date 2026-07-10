{ config, pkgs, lib, inputs, ... }:
{
  imports = [ 
    ./services.nix 
    ./environment.nix
    ./programs.nix
    ./gaming.nix
  ];

  nixpkgs.config = { 
    packageOverrides = pkgs: {    
      steam = pkgs.steam.override { extraArgs = "-system-composer -no-cef-sandbox"; };
    };
    allowUnfree = true;
  };
  
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

  networking = {
    firewall = { enable = true; };
    wireless = { enable = true; };
    networkmanager = { enable = true; };
  };
  
  boot = { 
    loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  security = {
    polkit = { enable = true; };
    rtkit = { enable = true; };
  };

  xdg.portal = {
    enable = true; 
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome 
    ];
    config.common.default = "*";
  };

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

  time.timeZone = "America/New_York";
  
  fonts.packages = with pkgs; [ ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);  
}
