#!/usr/bin/env zsh

function light-theme() {
  kitty +kitten themes --reload-in=all 'Atom One Light'
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  if pgrep 'emacs' > /dev/null; then
    emacsclient -e "(load-theme 'doom-one-light :no-confirm)"
  fi
}

function dark-theme() {
  kitty +kitten themes --reload-in=all 'Dracula'
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  if pgrep 'emacs' > /dev/null; then
    emacsclient -e "(load-theme 'doom-one :no-confirm)"
  fi
}

function yaml-to-json () {
  SCRIPT="\
#!/usr/bin/env python3

import os
import sys
import json
import yaml

arg = sys.argv[1]

if os.path.isfile(arg):
    content = open(arg).read()
else:
    content = arg

d = yaml.safe_load(content)
print(json.dumps(d))"
  python -c "$SCRIPT" "$1"
}

function json-to-yaml () {
  SCRIPT="\
#!/usr/bin/env python3

import os
import sys
import json
import yaml

arg = sys.argv[1]

if os.path.isfile(arg):
    content = open(arg).read()
else:
    content = arg

d = json.loads(arg)
print(yaml.dump(d))"
  python -c "$SCRIPT" "$1"
}

function url-unquote () {
  python3 -c "from urllib import parse; print(parse.unquote('$1'))"
}

function url-quote () {
  python3 -c "from urllib import parse; print(parse.quote('$1'))"
}

function decode-jwt () {
  jq -R 'split(".") | .[0],.[1] | @base64d | fromjson' <<< "$1"
}

function reset-gpg-card {
  killall -9 ssh-agent gpg-agent
  for keystub in $(gpg --with-keygrip --list-secret-keys 'bergmann.f@gmail.com' | grep Keygrip | awk '{print $3}'); do
    rm "/home/florian/.gnupg/private-keys-v1.d/$keystub.key";
  done;
  gpg --card-status
  eval $(gpg --launch gpg-agent)
}
