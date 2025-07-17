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
  #  sway environment setting
environment.variables.WLR_RENDERER = "vulkan";
  system.stateVersion = "25.05";
  networking.hostName = "kac-machine";
#maybbbbbbb
# hardware.enableRedistributableFirmware = true;
#systemd.network.enable = true; ***this was recommened by boot up app as confusing
  services.resolved.enable = true;

  # --- NETWORK ---
  networking = {
    useDHCP = false;
    wireless = {
      networks.DoESLiverpool-5g.psk = "decafbad00";
      networks.Virgin135535733br.psk = "MandySmith";
      enable = true;
      userControlled.enable = true;
      allowAuxiliaryImperativeNetworks = true;
    };
    interfaces.enp6s0.useDHCP = true;
    interfaces.wlo1.useDHCP = true;
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
alacritty # GPU-accelerated terminal emulator, fast and modern; kitty is also highly ranked for advanced features
aria2 # Lightweight multi-protocol & multi-source command-line download utility
btop # Resource monitor with a graphical interface, shows system stats
bat
blender
dmenu # Dynamic menu for X, useful for launching applications; for Wayland, consider wofi or bemenu
exiftool # Tool to read, write, and edit metadata in image files
ffmpeg-full # Multimedia framework for video/audio processing and conversion
#flameshot
gimp # Open source image editor, alternative to Photoshop; krita is better for digital painting
git # Version control system for source code management
gnutar # GNU tar archiving utility, standard for file archiving and compression
godot # Open source game engine for 2D and 3D game development
grim # Screenshot utility for Wayland; use with slurp for region selection
kitty # GPU-based terminal emulator, fast and feature-rich; alacritty is a good alternative for speed
krita # Digital painting and illustration software, great for artists; gimp is better for photo editing
kdePackages.kio-admin #open as admin 
kdePackages.dolphin
alsa-utils    # for aplay
pciutils      # for lspc
libreoffice # Office suite including word processor, spreadsheet, and presentation tools; ONLYOFFICE is another option with better PDF editing
lrzip # Long Range ZIP compression tool, good for very large files
lshw # Hardware lister, provides detailed info about system hardware
mako # Notification daemon for Wayland
netflix # Streaming service app, for watching movies and TV shows; use web browser for best compatibility
networkmanagerapplet
copyq
ntfs3g # NTFS filesystem driver for Linux, allows read/write access to NTFS partitions
nvtopPackages.full # NVIDIA GPU monitoring tool, useful for performance tracking
neovim
vimPlugins.vim-nix
vimPlugins.nvim-cmp
vimPlugins.cmp-nvim-lsp
vimPlugins.cmp-path
vimPlugins.vim-oscyank
vimPlugins.gitsigns-nvim
kdePackages.okular  # PDF viewer and annotator, highly recommended for NixOS; top-ranked PDF tool
pandoc # Document converter supporting multiple formats
pavucontrol #control sound
## Input configuration
parted # Disk partitioning tool, useful for managing disk partitions
pcmanfm # Lightweight file manager, good for minimal setups; thunar is another popular choice
poppler_utils # PDF utilities including text extraction and conversion
psmisc
pulseaudio
python313Packages.pymupdf # Python bindings for MuPDF, useful for PDF manipulation
signal-desktop # Secure messaging app with end-to-end encryption
slurp # Selection tool for Wayland, often used with grim for screenshots
spotify # Spotify client daemon for playing music; ncspot is a TUI alternative
swayidle # Idle management daemon for Sway
swaylock # Screen locker for Sway window manager
tesseract # OCR (Optical Character Recognition) engine
translate-shell # Command-line translator using various translation engines
unoconv # Converts between different office document formats
vim-full # Highly configurable text editor, popular among developers; neovim is a modern alternative
vimPlugins.vim-wayland-clipboard
evince #documient viewer as in gnome
gnome-text-editor # text editor
vscodium # Open source build of Visual Studio Code; vscode (Microsoft) offers more extensions but is proprietary
waybar
#autostart
networkmanagerapplet
copyq
logseq
wofi
# foot outdated terminal
emacs
mpv
mako
grim #screenshot with slurp
brightnessctl
playerctl
wf-recorder # Wayland screen recorder
wget # Command-line utility for downloading files from the web; aria2 is more powerful for parallel downloads
wpa_supplicant_gui
whatsapp-for-linux # Unofficial WhatsApp client for Linux; use web.whatsapp.com in browser for official support
wireshark # Network protocol analyzer for troubleshooting and analysis
wl-clipboard-rs # Clipboard utilities for Wayland
wofi-emoji
xz # Compression tool using LZMA2 algorithm, efficient for large files
yt-dlp # YouTube downloader with many features; fork of youtube-dl, recommended for modern sites
    (inkscape-with-extensions.override { inkscapeExtensions = [ inkscape-extensions.inkstitch ]; })
  ];

  # --- PROGRAMS ---
  programs.firefox.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraOptions = [
     # "--unsupported-gpu"
      "--config=${./xconfigs/config}"
    ];
  };
services.unifi.enable = true;
services.unifi.openFirewall = true;
services.unifi.openPorts = true;


  programs.bash.shellAliases = {
    swayextra = "WLR_RENDERER=vulkan exec sway --unsupported-gpu";
    lx = "l --sort=extension";
    cal = "cal -m";
    du-all = "du -ah --max-depth=1 . | sort -rh";
    du-dir = "du -h --max-depth=1 . | sort -rh";
    du-files = "find . -maxdepth 1 -type f -exec du -h {} + | sort -rh";
    kit = "kitten icat";
    bt = "bluetoothctl";
    timer = "alarmm";
    time = "alarmt";
    wpa = "wpa_gui";
    #send copy text to website url to send to someone
    wlpaste = "wl-paste | nc termbin.com 9999";
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
    HandleLidSwitch=ignore
    IdleAction=ignore
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
  #auto login
  security.sudo.wheelNeedsPassword = false;
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
