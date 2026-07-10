{ config, pkgs, inputs, ... }:

{
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
      reaper
      miktex
      texstudio
      vscodium
      foliate
      prismlauncher
      obsidian
      krita
    ];
  };
}
