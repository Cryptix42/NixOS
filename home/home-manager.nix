{ config, pkgs, inputs, lib, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.cryptix = { pkgs, ... }: {
      imports = [ 
        ./dot-files/ghostty.nix 
        ./dot-files/niri.nix 
      ];
      home.stateVersion = "25.11";
    };
  };  
}
