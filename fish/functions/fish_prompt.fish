function fish_prompt --description 'Write out the prompt'
    switch (uname)
        case Linux
            set md5 "md5sum"
        case Darwin
            set md5 "md5"
    end
    set user_color (id -un | eval $md5 | cut -c1-6)
    set host_color (hostname -s | eval $md5 | cut -c1-6)
    if test -z $WINDOW
        printf '%s%s@%s%s%s%s%s> ' (set_color $user_color) (whoami) (set_color $host_color) (hostname|cut -d . -f 1) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
    else
        printf '%s%s@%s%s%s(%s)%s%s%s> ' (set_color $user_color) (whoami) (set_color $host_color) (hostname|cut -d . -f 1) (set_color white) (echo $WINDOW) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
    end
end
