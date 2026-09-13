#ge /etc/nixos/flake.nix
{
  description = "flake for pb computers";

  inputs = {

    noctalia.url = "github:noctalia-dev/noctalia";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

  };

  outputs =
    inputs@{
      self,
      noctalia,
      nixpkgs,
      nixpkgs-stable,
      nixos-hardware,
      chaotic,
    }:
    {
      nixosConfigurations = {
        ianthe = nixpkgs.lib.nixosSystem {
          specialArgs =
            let
              system = "x86_64-linux";
            in
            {
              inherit inputs;
              pkgs-stable = import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
            };
          modules = [
            ({ pkgs, ... }: {
              boot.kernelPackages = pkgs.linuxPackages_latest;
            })
            ./global/configuration.nix
            ./global/apps/firefox.nix
            ./global/system-packages.nix
            ./computers/ianthe/hardware.nix
            ./computers/ianthe/configuration.nix
            chaotic.nixosModules.default
          ];
        };
        asphodel = nixpkgs.lib.nixosSystem {
          specialArgs =
            let
              system = "x86_64-linux";
            in
            {
              inherit inputs;
              pkgs-stable = import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
            };
          modules = [
            ({ pkgs, ... }: {
              boot.kernelPackages = pkgs.linuxPackages_cachyos;
              # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
            })
            ./global/configuration.nix
            ./global/apps/firefox.nix
            ./global/system-packages.nix
            ./computers/asphodel/hardware.nix
            ./computers/asphodel/configuration.nix
            chaotic.nixosModules.default
          ];
        };
      };
    };
}
