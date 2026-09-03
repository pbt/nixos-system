{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:

{
  # monitor control
  hardware.i2c.enable = true;
  services.ddccontrol.enable = true;
  boot.kernelModules = [ "i2c-dev" ];

  # can't find any other way to apply regulatory domain to us
  systemd.services.regdom-us = {
    path = [ pkgs.iw ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    script = ''
      iw reg set US
    '';
  };

  # amd gpu
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.amdgpu.overdrive.enable = true;
  hardware.firmware = [
    pkgs.linux-firmware
    pkgs.wireless-regdb
  ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.amdgpu.opencl.enable = true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:pbt/nixos-system#asphodel";
    flags = [
      "-L" # print build logs
      "--commit-lock-file"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  # kde connect
  programs.kdeconnect.enable = true;

  # pb : syncthing
  services.syncthing = {
    enable = true;
    group = "users";
    user = "pb";
    dataDir = "/home/pb/Documents"; # Default folder for new synced folders
    configDir = "/home/pb/.config/syncthing"; # Folder for Syncthing's settings and keys
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-841e7165-c5f2-480c-a938-bcaa36cb817c".device =
    "/dev/disk/by-uuid/841e7165-c5f2-480c-a938-bcaa36cb817c";
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  hardware.wirelessRegulatoryDatabase = true;

  boot.extraModprobeConfig = ''
    options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y
    options rtw89_core disable_ps_mode=y
  '';

  # Networking
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.hostName = "asphodel"; # Define your hostname.
  # wifi
  services.gnome.gnome-keyring.enable = true;
  networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
  # networking.networkmanager.wifi.powersave = false;

  # Enable Podman in configuration.nix
  virtualisation.podman = {
    enable = true;
    # Create the default bridge network for podman
    defaultNetwork.settings.dns_enabled = true;
  };

  # Set your time zone.
  time.timeZone = "America/New_York";
  # services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.lact.enable = true;

  # rocm packages
  environment.systemPackages = with pkgs; [
    pkgsRocm.ffmpeg-full
    btop-rocm
    rocmPackages.rocm-smi
    openrgb-with-all-plugins
  ];

  # rocm
  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];

  system.stateVersion = "24.05";
}
