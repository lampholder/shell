# ~/.config/fish/config.fish

# SSH Agent
#
# Start SSH Agent if it's not already running, and add the
# id_(nice_hostname) identity.
setenv SSH_ENV "$HOME/.ssh/environment"
if [ -n "$SSH_AGENT_PID" ]
    ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null
    if [ $status -eq 0 ]
        test_identities
    end
else
    if [ -f $SSH_ENV ]
        . $SSH_ENV > /dev/null
    end
    ps -ef | grep $SSH_AGENT_PID | grep -v grep | grep ssh-agent > /dev/null
    if [ $status -eq 0 ]
        test_identities
    else
        start_agent
    end
end

# Solarized theme, brutally exported from the fishd.arglebargle generated locally by fish_config
set __fish_classic_git_prompt_initialized \x1d
set __fish_init_1_50_0 \x1d
set fish_color_autosuggestion 586e75
set fish_color_command 93a1a1
set fish_color_comment 586e75
set fish_color_cwd green
set fish_color_cwd_root red
set fish_color_end 268bd2
set fish_color_error dc322f
set fish_color_escape cyan
set fish_color_history_current cyan
set fish_color_host \x2do\x1ecyan
set fish_color_match cyan
set fish_color_normal normal
set fish_color_operator cyan
set fish_color_param 839496
set fish_color_quote 657b83
set fish_color_redirection 6c71c4
set fish_color_search_match \x2d\x2dbackground\x3dpurple
set fish_color_selection \x2d\x2dbackground\x3dpurple
set fish_color_status red
set fish_color_user \x2do\x1egreen
set fish_color_valid_path \x2d\x2dunderline
# set fish_greeting Welcome\x20to\x20fish\x2c\x20the\x20friendly\x20interactive\x20shell\x0aType\x20\x1b\x5b32mhelp\x1b\x5b30m\x1b\x28B\x1b\x5bm\x20for\x20instructions\x20on\x20how\x20to\x20use\x20fish
# set fish_key_bindings fish_default_key_bindings
set fish_pager_color_completion normal
set fish_pager_color_description 555\x1eyellow
set fish_pager_color_prefix cyan
set fish_pager_color_progress cyan

test -s /Users/tom/.nvm-fish/nvm.fish; and source /Users/tom/.nvm-fish/nvm.fish

eval (python -m virtualfish)
