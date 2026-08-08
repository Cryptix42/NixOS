{ config, pkgs, inputs, lib, ... }:

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

  networking.hostName = "Nephilim";
  system.stateVersion = "25.11";

  services.tailscale.enable = true;

  myHost.monitors = {
    "eDP-1" = { mode = "1920x1080@60"; x = 0; y = 0; };
  };

  boot = { 
    loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; };
    kernelPackages = pkgs.linuxPackages_latest;
  };

#  sops = {
#    defaultSopsFile = ../../secrets/secrets.yaml;
#    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
#    secrets.tailscale-authkey = { };
#  };
}
