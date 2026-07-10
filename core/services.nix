{config, pkgs, inputs, ... }:

{
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
    gvfs = { enable = true; };
    tumbler = { enable = true; };
  };
}
