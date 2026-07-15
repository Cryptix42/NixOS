{ config, inputs, pkgs, ... }:
{
  users.users.kutaren = {
    isNormalUser = true;
    description = "Cameron";
    extraGroups = [ "guixBuild" "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ 
      python315
      emacs
      reaper
      vscodium
      foliate
      prismlauncher
      obsidian
    ];
  };
}
