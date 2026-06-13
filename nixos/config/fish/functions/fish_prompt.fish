function fish_prompt
    # 1. Alias user "ty" to "Ty", others stay default
    set -l user_display $USER
    if test "$USER" = "ty"
        set -l user_display "Ty"
    end

    # 2. Alias hostname "nixos" to "@NixOs", others stay default
    set -l host_display "@$hostname"
    if test "$hostname" = "nixos"
        set -l host_display "@NixOs"
    end

    # 3. Handle prompt character based on privileges
    # root user gets double dagger (‡), normal user gets single dagger (†)
    set -l suffix "†"
    if fish_is_root_user
        set -l suffix "‡"
    end

    # 4. Format and print the prompt line
    # Output: Ty@NixOs:~/present/dir] † 
    echo -n -s $user_display $host_display ":" (prompt_pwd) "]" " " $suffix " "
end
