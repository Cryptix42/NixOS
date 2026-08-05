{config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../desktops/kde-plasma.nix
    ../../core/default.nix
    ../../users/kutaren.nix
  ];
  networking.hostName = "Ain_Soph";

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = { enable = true; finegrained = false; };
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];


  boot = { 
    loader = { grub = { enable = true; efiSupport = true; device = "nodev"; } efi.canTouchEfiVariables = true; };
    kernelPackages = pkgs.linuxPackages_latest;
  };


}
