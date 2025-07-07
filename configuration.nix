{ pkgs, ... }:

{
  imports = [ ./open-webui.nix ./comfyui ];

  services.ollama = {
    host = "0.0.0.0";
    openFirewall = true;
  };

  nixpkgs.config.allowUnfree = true;
  hardware.nvidia.open = true;
  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.05";
  networking.hostName = "kac-machine";

  systemd.network.enable = true;
  services.resolved.enable = true;

  # --- NETWORK ---
  networking = {
    #useDHCP = false;
    wireless = {
      networks.DoESLiverpool-5g.psk = "decafbad00";
      enable = true;
      userControlled.enable = true;
      allowAuxiliaryImperativeNetworks = true;
    };
    #interfaces.wlo1.useDHCP = true;
  };

  systemd.network.wait-online.enable = false;

  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.openssh.enable = true;

  # --- SYSTEM PACKAGES ---
  environment.systemPackages = with pkgs; [
    ntfs3g
    gnutar
    xz
    lrzip
    lshw
    parted
    aria2
    btop
    exiftool
    ffmpeg-full
    kdePackages.dolphin
    gimp
    git
    godot
    kitty
    krita
    libreoffice
    netflix
    nvtopPackages.full
    python313Packages.pymupdf
    pandoc
    poppler_utils
    signal-desktop
    tesseract
    translate-shell
    unoconv
    vim
    wireshark
    wget
    whatsapp-for-linux
    swaylock
    swayidle
    wl-clipboard
    wf-recorder
    mako
    grim
    slurp
    vscodium
    alacritty
    dmenu
    spotifyd
    yt-dlp
    (inkscape-with-extensions.override { inkscapeExtensions = [ inkscape-extensions.inkstitch ]; })
  ];

  # --- PROGRAMS ---
  programs.firefox.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.bash.shellAliases = {
    lx = "l --sort=extension";
    cal = "cal -m";
    du-all = "du -ah --max-depth=1 . | sort -rh";
    du-dir = "du -h --max-depth=1 . | sort -rh";
    du-files = "find . -maxdepth 1 -type f -exec du -h {} + | sort -rh";
    kit = "kitten icat";
    bt = "bluetoothctl";
  };

  # --- NIX SETTINGS ---
  nix.package = pkgs.nixVersions.latest;
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "kac" "@wheel" "root" ];
  };

  # --- SWAP ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
  };

  # --- POWER MANAGEMENT ---
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
    HandleLidSwitch=hibernate
    IdleAction=hibernate
    IdleActionSec=15min
  '';

  services.tlp = {
    enable = true;
    settings = {
      PCIE_ASPM_ON_BAT = "powersupersave";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_MAX_PERF_ON_AC = "100";
      CPU_MAX_PERF_ON_BAT = "30";
      STOP_CHARGE_THRESH_BAT1 = "95";
      STOP_CHARGE_THRESH_BAT0 = "95";
    };
  };

  powerManagement.enable = true;

  # --- USERS ---
  users.users.kac = {
    hashedPassword = "$y$j9T$AoL07JnG/cftMnUt7GXJo/$TuSzOYSLmS36IWTqd0dWltt1l2OjvJ.xzQE9MiOxB8A";
    isNormalUser = true;
    extraGroups = [
      "input"
      "wheel"
      "dialout"
      "kvm"
      "audio"
      "pipewire"
    ];
  };
  users.mutableUsers = false;

  # --- BOOT ---
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 50;
    };
    efi.canTouchEfiVariables = false;
  };
  boot.supportedFilesystems = [ "ntfs" ];
  boot.blacklistedKernelModules = [ "ntfs3" ];

  # --- SERVICES ---
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland
    openFirewall = true;
  };
  services.gvfs.enable = true;
  services.tailscale.enable = true;

  # --- AUDIO ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # --- PRINTING ---
  services.printing = {
    # enable = true;
    stateless = true;
    browsing = true;
    drivers = with pkgs; [ gutenprint ];
  };

  # --- FONTS ---
  fonts.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
  ];
}
