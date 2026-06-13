# /etc/nixos/dotfiles.nix
{ config, pkgs, ... }: {

  # =========================================================================
  # 1. System Integrated Modules (Native optimizations instead of systemPackages)
  # =========================================================================
  programs.fish.enable = true;
  programs.tmux.enable = true;
  programs.git.enable = true;
  
  programs.neovim = {
    enable = true;
    defaultEditor = true; # Exports $EDITOR and $VISUAL globally
  };
  
  system.activationScripts.syncConfigs = {
    deps = [];
    text = ''
      SRC_DIR="/etc/nixos/config"

      if [ -d "$SRC_DIR" ]; then
        # Loop strictly through pairs using a space-separated string to avoid Nix escaping bugs
        # Format: username:groupname:config_subdir_path
        for user_data in "ty:users:/home/ty/.config" "root:root:/root/.config"; do
          
          # Split data using IFS (Internal Field Separator)
          IFS=":" read -r U G BASE_PATH <<< "$user_data"

          T_GHOSTTY="$BASE_PATH/ghostty"
          T_FISH="$BASE_PATH/fish"
          T_TMUX="$BASE_PATH/tmux"
          T_YAZI="$BASE_PATH/yazi"
          T_BTOP="$BASE_PATH/btop"

          # Re-create targets cleanly
          rm -rf "$T_GHOSTTY" "$T_FISH" "$T_TMUX" "$T_YAZI" "$T_BTOP"
          mkdir -p "$T_GHOSTTY" "$T_TMUX" "$T_YAZI" "$T_BTOP"
          mkdir -p "$T_FISH/functions" "$T_FISH/conf.d" "$T_FISH/completions"

          # Scan and hard link matching files from our config directory
          find "$SRC_DIR" -type f | while read -r src_file; do
            rel_path="''${src_file#$SRC_DIR/}"
            
            if [[ "$rel_path" == ghostty/* ]]; then
              dest_file="$T_GHOSTTY/''${rel_path#ghostty/}"
            elif [[ "$rel_path" == fish/* ]]; then
              dest_file="$T_FISH/''${rel_path#fish/}"
            elif [[ "$rel_path" == tmux/* ]]; then
              dest_file="$T_TMUX/''${rel_path#tmux/}"
            elif [[ "$rel_path" == yazi/* ]]; then
              dest_file="$T_YAZI/''${rel_path#yazi/}"
            elif [[ "$rel_path" == btop/* ]]; then
              dest_file="$T_BTOP/''${rel_path#btop/}"
            else
              continue
            fi

            mkdir -p "$(dirname "$dest_file")"
            ln "$src_file" "$dest_file"
          done

          # Set uniform ownership using clean, parsed string values
          chown -R "$U:$G" "$T_GHOSTTY" "$T_FISH" "$T_TMUX" "$T_YAZI" "$T_BTOP"
        done
      fi
    '';
  };
}
