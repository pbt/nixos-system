# /etc/nixos/flake.nix
{
  description = "flake for mooncake";

  inputs = {

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      nixos-hardware,
      nix-cachyos-kernel,
    }:
    {
      nixosConfigurations = {
        shumai = nixpkgs.lib.nixosSystem {
          specialArgs =
            let
              system = "x86_64-linux";
            in
            {
              pkgs-stable = import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
            };
          modules = [
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
              boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
              # # testing for wifi issues
              # boot.kernelPackages = pkgs.linuxPackages_latest;
            })
           ./configuration.shumai.nix
          ];
        };
        asphodel = nixpkgs.lib.nixosSystem {
          specialArgs =
            let
              system = "x86_64-linux";
            in
            {
              pkgs-stable = import nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
            };
          modules = [
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];
              boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
              # # testing for wifi issues
              # boot.kernelPackages = pkgs.linuxPackages_latest;
            })
           ./configuration.nix
          ];
        };
      };
    };
}
