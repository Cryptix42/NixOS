{config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../desktops/kde-plasma.nix
    ../../core/default.nix
    ../../users/kutaren.nix
    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.sops-nix.nixosModules.sops
  ];
  networking.hostName = "AinSoph";

  nixpkgs.overlays = [ inputs.nix-minecraft.overlays.default ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = { enable = true; finegrained = false; };
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];


  boot = { 
    loader = { grub = { enable = true; efiSupport = true; device = "nodev"; }; efi.canTouchEfiVariables = true; };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.tailscale-authkey = { };
  };

  services.tailscale.enable = true;
  
  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/srv/minecraft";
    openFirewall = true;
    servers.family = {
      enable = true;
      package = pkgs.fabricServers.fabric-26_2.override {
        jre_headless = pkgs.temurin-jre-bin-25;
      };   
      jvmOpts = "-Xmx4G -Xms4G";
      serverProperties = {
        white-list = false;
        difficulty = "normal";
        motd = "MC test server";
        server-port = 25565;
      };
      whitelist = { };  
      symlinks."mods/fabric-api.jar" =
      pkgs.fetchurl { 
        url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/Kr4WG5mG/fabric-api-0.154.2+26.2.jar"; 
        sha512 = "sha512-fO2thi6BBafejbCQwHB8JaFKlHJlQJCGHc9JD4NIYsMhJyPnYvb3l6DkaDEE9LOiDTaS+ynXtcCvQ3YTKD002w=="; 
      };
    };
  };

}
