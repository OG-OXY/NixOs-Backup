  { config, pkgs, ...}:
    
  {
    home.username = "ty";
    home.homeDirectory = "/home/ty";
    home.stateVersion = "26.05";

    programs.bash = {
      enable = true;
      shellAliases = {
        nrs = "sudo nixos-rebuild switch";
      };
    };
  }

