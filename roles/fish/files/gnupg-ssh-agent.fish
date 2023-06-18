# See: https://wiki.archlinux.org/index.php/GnuPG#Configuration_2
set -e SSH_AGENT_PID

set -q gnupg_SSH_AUTH_SOCK_by; or set gnupg_SSH_AUTH_SOCK_by 0
if [ "$gnupg_SSH_AUTH_SOCK_by" -ne $fish_pid ]
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
end

export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
