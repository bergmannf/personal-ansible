#!/bin/sh

echo "Installing dependencies"
ansible-galaxy install --roles-path=roles -r requirements.yml

echo "Running playbook"
ansible-playbook --inventory="localhost," --connection=local --become --ask-become-pass all.yml
