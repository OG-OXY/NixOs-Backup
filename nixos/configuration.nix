# Help is in the configuration.nix(5) man page, on https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
   home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
in
{
   imports =
     [ # Include the results of the hardware scan.
       ./hardware-configuration.nix
       ./dotfiles.nix
       (import "${home-manager}/nixos")
     ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.ty = import ./home.nix;
  
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 15;
    };
  };
   
  nix = {
    settings = {
      # Detects duplicate files and links them to save space
      auto-optimise-store = true;
    };
    
    # Trigger garbage collection.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
   
  # Configure connections with nmtui.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  
  # Set your time zone.
  time.timeZone = "America/New_York";

  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      xwallpaper --output DP-1 --zoom /home/ty/Pictures/Downloads/wpapers/gruvbox-nix.png --output HDMI-1 --zoom /home/ty/Pictures/Downloads/wpapers/gruvbox-nix.png
      xset r rate 200 35 &
    '';
  };

  # Enable the GDM displayManager.
  # services.displayManager.gdm.enable = true;
  
  # Configure keymap in X11.
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  
  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Define a user account.
  security.sudo = {
    enable = true;
    extraRules = [{
      groups = [ "wheel" ];
      commands = [{
        command = "ALL";
	options = [ "NOPASSWD" ];
      }];
    }];
  };
  users.mutableUsers = true;
  users.users.ty = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "render" "input" "audio" ]; # Groups to add user to.
    packages = with pkgs; [
      
    ];
  };

  programs.firefox.enable = true;
  programs.nano.enable = false;

  programs.git = {
    enable = true;
    config = {
      user.name = "Ty";
      user.email = "ogoxy.yt@gmail.com";
      
      # Tell Git to use your SSH key natively for signing.
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
    };
  };
  
  # List packages installed in system profile.
  # https://search.nixos.org/ to find packages (and options).
  environment.systemPackages = with pkgs; [
    ghostty
    yazi
    wget
    fastfetch
    btop
    pfetch
    rofi
    xwallpaper
    scrot
    maim
    xclip
    dysk
    tree
  ];
  
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.enable = true;
  };

  # 2. Ghostty's global session font variables.
  environment.etc."ghostty/config".text = ''
    font-family = "JetBrainsMono Nerd Font"
    
    font-family-bold = "JetBrainsMono Nerd Font"
    font-style-bold = "ExtraBold"
    font-style-bold-italic = "ExtraBold Italic"
    
    font-feature = "liga"
    font-feature = "calt"
  '';
    
  # Global session variables
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false; # Disables insecure password logins.
      PermitRootLogin = "no";         # Blocks root user access.
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Copy the NixOS configuration to (/run/current-system/configuration.nix).
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you installed, used to maintain compatibility with application data (e.g. databases).
  # NEVER change this value.
  # see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05";
}

