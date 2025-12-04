{ config, lib, pkgs, ... }:

{
  # WSL-specific configuration
  wsl = {
    enable = true;
    defaultUser = "gfoster";
    startMenuLaunchers = true;
    
    # Enable native systemd support
    nativeSystemd = true;
    
    # WSL-specific settings
    wslConf = {
      automount.root = "/mnt";
      network.generateHosts = true;
      network.generateResolvConf = true;
    };
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Essential tools
    wget
    curl
    git
    vim
    
    # Development tools
    gcc
    gnumake
    
    # System utilities
    htop
    btop
    tree
    
    # Network tools
    dig
    netcat
    
    # Archive tools
    unzip
    zip
    gnutar
  ];

  # Enable nix flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    
    settings = {
      # Enable automatic garbage collection
      auto-optimise-store = true;
      
      # Trusted users for nix commands
      trusted-users = [ "root" "@wheel" ];
    };
    
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # User configuration
  users.users.gfoster = {
    isNormalUser = true;
    home = "/home/gfoster";
    description = "G Foster";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    
    # Set initial password (change after first login)
    initialPassword = "password";
  };

  # Enable sudo for wheel group
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  # System-wide shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
  };

  # Enable Docker (optional, for development)
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Time zone
  time.timeZone = "America/New_York"; # Adjust to your timezone

  # Networking
  networking = {
    hostName = "nixos-wsl";
    
    # Enable NetworkManager
    networkmanager.enable = true;
  };

  # System state version
  system.stateVersion = "23.11";

  # Enable home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}