# Help is in the configuration.nix(5) man page, on https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
   home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
   imports =
     [ # Include the results of the hardware scan.
       ./hardware-configuration.nix
       (import "${home-manager}/nixos")
     ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.ty = import ./home.nix;
  home-manager.users.root = import ./home.nix;
  
  users.users.ty.shell = pkgs.fish;
  users.users.root.shell = pkgs.fish;

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
   
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 10;
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
    extraGroups = [ "wheel" "networkmanager" "video" "render" "input" "audio"
];
    # User only pkgs.
    packages = with pkgs; [

    ];
  };
  # Package manager settings.
  nix = {
    settings = {
      # Links duplicates to save space.
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };

  # Garbage collection.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  networking.hostName = "nixos"; # Define your hostname.
  
  # Manage connections with nmtui.
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable the GDM displayManager.
  # services.displayManager.gdm.enable = true;
  
  # Configure keymap in X11.
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  
  programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.zoxide.enable = true;
  programs.atuin.enable = true;
  programs.starship.enable = true;
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

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

  # List services that you want to enable:

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      xwallpaper --output DP-1 --zoom /home/ty/Pictures/Downloads/wpapers/gruv
box-nix.png --output HDMI-1 --zoom /home/ty/Pictures/Downloads/wpapers/gruvbox
-nix.png
      xset r rate 200 35 &
    '';
  };

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.zram-generator = {
    enable = true;
    settings = {
      zram0 = {
        compression-algorithm = "lz4";
	zram-size = 16384;
      };
    };
  };

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

  # Executes inside a nixos-rebuild VM sandbox
  virtualisation.vmVariant = {
    # Force the passwd "test"
    users.users.ty.password = "test";
    users.users.root.password = "test";
  };

  # Copy your NixOs (/run/current-system/configuration.nix).
  system.copySystemConfiguration = true;

  # Set your time zone.
  time.timeZone = "America/New_York";
  
  programs.nano.enable = false;
  services.libinput.enable = false;
  services.printing.enable = false;

  environment.etc."atuin/config.toml".source = /etc/nixos/config/atuin/config.toml;

  # Origin version of NixOS, used for compatibility. NEVER change this value. 
  # See "https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion".
  system.stateVersion = "26.05";
}
