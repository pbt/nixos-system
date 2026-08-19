# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:

{
  # lix
  nix.package = pkgs.lixPackageSets.stable.lix;

  nix.settings.substituters = [
    "https://nix-community.cachix.org"
    "https://attic.xuyh0120.win/lantian"
    "https://cache.nixos.org/"
  ];

  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
  ];

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
  };

  # peripherals
  # openrgb
  services.hardware.openrgb.enable = true;
  # zsa
  hardware.keyboard.zsa.enable = true;
  hardware.keyboard.qmk.enable = true;

  services.udev = {

    packages = with pkgs; [
      qmk
      qmk-udev-rules # the only relevant
      qmk_hid
      via
      vial
    ]; # packages

  }; # udev

  # monitor control
  hardware.i2c.enable = true;
  services.ddccontrol.enable = true;
  boot.kernelModules = [ "i2c-dev" ];

  # gaming
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];
  programs.steam.package = pkgs.steam.override {
    extraPkgs =
      pkgs': with pkgs'; [
        libXcursor
        libXi
        libXinerama
        libXScrnSaver
        libpng
        pkgsRocm.ffmpeg-full
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib # Provides libstdc++.so.6
        libkrb5
        keyutils
        # Add other libraries as needed
      ];
  };

  programs.steam.gamescopeSession.enable = true;
  programs.steam.gamescopeSession.args = [
    "--adaptive-sync"
    "--hdr-enabled"
    "--steam"
    "--mangoapp"
    "--rt"
  ];

  programs.gamemode.enable = true;

  programs.gamescope = {
    enable = true;
    enableWsi = true;
    capSysNice = false;
  };

  programs.nix-index.enable = true;

  programs.niri.enable = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.optimise.automatic = true;

  # environment
  environment.localBinInPath = true;

  # pb: direnv
  programs.direnv.enable = true;

  virtualisation.docker.enable = true;

  # pb: tailscale
  services.tailscale.enable = true;

  # pb: flatpak
  services.flatpak.enable = true;
  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      configPackages = [ pkgs.xdg-desktop-portal-gnome ];
      config.common.default = "gnome";
    };
    mime.defaultApplications = {
      "inode/directory" = [ "nautilus.desktop" ];
      "application/x-gnome-saved-search" = [ "nautilus.desktop" ];
    };
  };

  # pb: enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      experimental = true; # show battery

      # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
      # for pairing bluetooth controller
      Privacy = "device";
      JustWorksRepairing = "always";
      Class = "0x000100";
      FastConnectable = true;
    };
  };

  # gamepad
  services.blueman.enable = true;
  hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  # nixpkgs.config.rocmSupport = true;

  # hardware.opengl.extraPackages = with pkgs; [
  #   # rocm-opencl-icd
  #   rocm-runtime-ext
  # ];

  # pb: Enable experimental features
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # pb: obs
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-gstreamer
      obs-vkcapture
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15dd";
  };

  nixpkgs.config = {
    chromium = {
      enableWideVine = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pb = {
    isNormalUser = true;
    description = "Persephone";
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c" # needed for monitor control/ddc
      "docker" # run w/o sudo
    ];
    shell = pkgs.nushell;
    packages = with pkgs; [
      figma-agent
      aseprite
      browsh
      (pkgs.lutris.override {
        extraLibraries = pkgs: [
          pkgs.gamemode
        ];
      })
      carla
      haruna
      inkscape
      gpu-screen-recorder
      kdePackages.yakuake
      keymapp
      krename
      nushell
      lagrange
      pkgs-stable.newsflash
      nicotine-plus
      openttd
      itch
      pdfarranger
      playerctl
      qalculate-gtk
      recoll
      obsidian
      # strawberry
      supersonic
      vicinae
      thunderbird
      ungoogled-chromium
      zotero
    ];
  };

  # pb: avahi
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    nssmdns6 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # pb: fprintd
  services.fprintd = {
    enable = true;
  };

  security.pam.services.polkit-1.fprintAuth = true;
  services.gnome.gnome-keyring.enable = true;
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  # pb: power mgmt
  services.power-profiles-daemon.enable = true;
  #   services.tlp = {
  #       enable = true;
  #       settings = {
  #         CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #         CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #
  #         CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #         CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  #
  #         CPU_MIN_PERF_ON_AC = 0;
  #         CPU_MAX_PERF_ON_AC = 100;
  #         CPU_MIN_PERF_ON_BAT = 0;
  #         CPU_MAX_PERF_ON_BAT = 20;
  #
  #        # Optional helps save long term battery health
  #        START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
  #        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
  #
  #       };
  # };

  systemd.timers.flatpak-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "flatpak-update.service";
    };
  };

  systemd.services.flatpak-update = {
    path = [ pkgs.flatpak ];
    script = ''
      flatpak update -y
    '';
  };

  systemd.user.services.mpris-proxy = {
    enable = true;
    description = "Mpris proxy";
    after = [
      "network.target"
      "sound.target"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  programs._1password.enable = true;
  programs._1password.package = pkgs-stable._1password-cli;
  programs._1password-gui = {
    enable = true;
    package = pkgs-stable._1password-gui;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "pb" ];
  };

  security.polkit.enable = true; # polkit

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # kde connect
  programs.kdeconnect.enable = true;

  # fonts
  fonts = {
    fontDir.enable = true;
    fontconfig = {
      useEmbeddedBitmaps = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        serif = [ "Source Serif 4" ];
        sansSerif = [ "Atkinson Hyperlegible Next" ];
        monospace = [ "0xProto" ];
      };
    };
    packages = with pkgs; [
      _0xproto
      atkinson-hyperlegible-mono
      atkinson-hyperlegible-next
      corefonts
      vista-fonts
      dina-font
      fira-code
      fira-code-symbols
      fira-sans
      inconsolata
      inter
      iosevka
      libertine
      mplus-outline-fonts.githubRelease
      nerd-fonts._0xproto
      nerd-fonts.symbols-only
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      proggyfonts
      public-sans
      source-sans
      source-sans-pro
      source-serif
      source-serif-pro
    ];
  };

  # pb : syncthing
  services.syncthing = {
    enable = true;
    group = "users";
    user = "pb";
    dataDir = "/home/pb/Documents"; # Default folder for new synced folders
    configDir = "/home/pb/.config/syncthing"; # Folder for Syncthing's settings and keys
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

  # Networking
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # wifi
  # networking.wireless.iwd.enable = true;
  # networking.wireless.iwd.settings = {
  #   Network = {
  #     EnableIPv6 = true;
  #   };
  #   Settings = {
  #     AutoConnect = true;
  #   };
  # };
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.displayManager.defaultSession = "niri";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "pb";

  programs.dconf.profiles.user = {
    databases = [
      {
        lockAll = true;
        settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Adwaita";
            cursor-theme = "Adwaita";
          };
        };
      }
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {

    raopOpenFirewall = true;
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
    #
    wireplumber = {
      enable = true;
    };

    extraConfig.pipewire.adjust-sample-rate = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.allowed-rates" = [
          44100
          48000
          192000
        ];
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config.credential.helper = "libsecret";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  programs.ssh = {
    package = pkgs-stable.openssh;
    enableAskPassword = true;
    askPassword = "";
    # startAgent = false;
  };

  programs.mosh.enable = true;

  environment.sessionVariables = {
    # SSH_ASKPASS_REQUIRE = "prefer";
    EDITOR = "hx";
    VISUAL = "hx";
    NIXOS_OZONE_WL = "1";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    package = pkgs-stable.openssh;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "pb" ];
      MaxAuthTries = 3;
      PerSourcePenalties = "crash:3600s authfail:3600s max:86400s";
    };
  };
}
