{ config, pkgs, inputs, ... }:
{
  imports = [ 
    ./hardware-configuration.nix  
    ../../desktops/niri.nix
    ../../core/default.nix
    ../../users/cryptix.nix
    ../../home/home-manager.nix
    ../../modules/host-display.nix
    inputs.sops-nix.nixosModules.sops
  ];

  networking.hostName = "Seraphim";

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = { enable = true; finegrained = false; };
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  system.stateVersion = "26.05";

  myHost.monitors = {
    "HDMI-A-1" = { mode = "1920x1080@60"; x = 0; y = 0; };
    "ASUSTek COMPUTER INC VG27B N8LMQS026748" = { mode = "2560x1440"; x = 1920; y = 0; };
  };

  boot = { 
    loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  services.tailscale.enable = true;

#  sops = {
#    defaultSopsFile = ../../secrets/secrets.yaml;
#    age.sshKeyPaths = [ "/home/cryptix/.config/sops/age/keys.txt" ]; 
#    secrets.tailscale-authkey = { };
#  };
}
