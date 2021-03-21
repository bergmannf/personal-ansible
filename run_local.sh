#!/bin/sh

PLAYBOOK="${1:-all.yml}"

echo "Running playbook: $PLAYBOOK"
ansible-playbook --inventory="localhost," --connection=local --become --ask-become-pass "$PLAYBOOK"
