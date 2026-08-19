#ge /etc/nixos/flake.nix
{
  description = "flake for pb computers";

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
        ianthe = nixpkgs.lib.nixosSystem {
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
            })
            ./global/configuration.nix
            ./global/apps/firefox.nix
            ./global/system-packages.nix
            ./computers/ianthe/hardware.nix
            ./computers/ianthe/configuration.nix
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
            })
            ./global/configuration.nix
            ./global/apps/firefox.nix
            ./global/system-packages.nix
            ./computers/asphodel/hardware.nix
            ./computers/asphodel/configuration.nix
          ];
        };
      };
    };
}
