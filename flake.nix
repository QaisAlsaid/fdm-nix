{
  description = "IshowSpeed package for NixOS.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let 
      systems = [
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      in {
        packages = forAllSystems (system:
         let 
           pkgs = import nixpkgs {
             inherit system;
             config.allowUnfree = true; 
           };
         in {
           default = pkgs.callPackage ./package.nix {};
         }
        );
      };
}
