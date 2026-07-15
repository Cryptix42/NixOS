{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ self, nixpkgs, ... }:
    let
      mkHost = hostPath: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ hostPath ];
        specialArgs = { inherit self; inherit inputs; };
      };
    in {
      nixosConfigurations = {
        Seraphim = mkHost ./hosts/seraphim/default.nix; 
        Nephilim = mkHost ./hosts/nephilim/default.nix;
        Ain_Soph = mkHost ./hosts/ain_soph/default.nix;
      };
    };
}
