#!/bin/sh

echo "Running playbook"
ansible-playbook --inventory="localhost," --connection=local --become --ask-become-pass all.yml
