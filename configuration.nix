{ pkgs, ... }:
{
  imports = [ ./open-webui.nix ./comfyui ];
  nixpkgs.config.allowUnfree = true;
  hardware.nvidia.open = true;
  system.stateVersion = "25.05";
  networking.hostName = "kac-machine";
  environment.systemPackages = with pkgs; [
  ntfs3g
  gnutar
  xz          # For high compression ratio with LZMA2
  lrzip       # Optional: alternative compressor optimized for large files
  lshw        # To record hardware info
  parted      # To manage and record partition info
  aria2
  btop
  exiftool
  ffmpeg-full
  kdePackages.dolphin
  firefox
  gimp
  git
  kitty
  krita
  libreoffice
  netflix
  nvtopPackages.full
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
  mako # notification daemon
  grim
  #kanshi
  slurp
  vscodium
  alacritty # Alacritty is the default terminal in the config
  dmenu # Dmenu is the default in the config but i recommend wofi since its wayland nativ
  spotifyd
  yt-dlp
  (inkscape-with-extensions.override { inkscapeExtensions = [ inkscape-extensions.inkstitch ]; })
];
  hardware.enableRedistributableFirmware = true;
  nix.package = pkgs.nixVersions.latest;
  nix.settings = {
   experimental-features = [ "nix-command" "flakes" ];
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90;
  };
#Disable Gnome for Sway
  nix.settings.trusted-users = [ "kac" "@wheel" "root" ];
  users.users.root.hashedPassword = "$y$j9T$AoL07JnG/cftMnUt7GXJo/$TuSzOYSLmS36IWTqd0dWltt1l2OjvJ.xzQE9MiOxB8A";
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
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 50;
    };
    efi.canTouchEfiVariables = false;
  };
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };
  services.gvfs.enable = true;
  services.tailscale.enable = true;
  boot.supportedFilesystems = [ "ntfs" ];#
  boot.blacklistedKernelModules = [ "ntfs3" ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
  };
}
