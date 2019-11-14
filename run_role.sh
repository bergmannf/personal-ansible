#!/usr/bin/bash

tempfile=$(mktemp -p .)

cat > "$tempfile" <<EOF
---
- hosts: all
  roles:
    - $1
EOF

echo "RUNNING: $tempfile"

ansible-playbook --inventory="localhost," --connection=local --become --ask-become-pass "$tempfile"

rm "$tempfile"
