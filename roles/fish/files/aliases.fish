#!/usr/bin/fish

# Switch the desktop to a light theme
function light-theme
  kitty +kitten themes --reload-in=all 'Atom One Light'
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  if pgrep 'emacs' > /dev/null
    emacsclient -e "(load-theme 'doom-one-light :no-confirm)"
  end
end

# Switch the desktop to a dark theme
function dark-theme
  kitty +kitten themes --reload-in=all 'Dracula'
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  if pgrep 'emacs' > /dev/null
    emacsclient -e "(load-theme 'doom-one :no-confirm)"
  end
end

function yaml-to-json -a yaml
  set SCRIPT "\
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
  python -c "$SCRIPT" "$yaml"
end

function json-to-yaml -a json
  set SCRIPT "\
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
  python -c "$SCRIPT" "$json"
end

function url-unquote -a url
  python3 -c "from urllib import parse; print(parse.unquote('$url'))"
end

function url-quote -a url
  python3 -c "from urllib import parse; print(parse.quote('$url'))"
end

function decode-jwt -a jwt
  echo "$jwt" | jq -R 'split(".") | .[0],.[1] | @base64d | fromjson'
end
