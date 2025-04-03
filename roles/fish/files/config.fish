#!/usr/bin/fish

if status is-interactive
    # Commands to run in interactive sessions can go here
    if [ -f ~/.asdf/asdf.fish ]
        source ~/.asdf/asdf.fish
    end

    if [ -f /usr/share/fzf/shell/key-bindings.fish ]
        source /usr/share/fzf/shell/key-bindings.fish
    end

    if command -v kubectl &>/dev/null
        kubectl completion fish | source
    end

    if command -v oc &>/dev/null
        oc completion fish | source
    end

    source ~/.aliases

    if [ -f ~/.aliases.fish ]
        source ~/.aliases.fish
    end

    direnv hook fish | source
    starship init fish | source
end

# Set keybindings

bind \ep up-or-search
bind \en down-or-search
