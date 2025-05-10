#!/usr/bin/env zsh

if command -v kubectl &> /dev/null; then
  if [ -z $HOME/.zfunctions/_kubectl ]; then
    kubectl completion zsh > $HOME/.zfunctions/_kubectl
  fi
  compdef _kubectl kubectl
  compdef _kubectl k
fi
if command -v oc &> /dev/null; then
  if [ -z $HOME/.zfunctions/_oc ]; then
    oc completion zsh > $HOME/.zfunctions/_oc
  fi
  compdef _oc oc
fi
if [ -f ~/.asdf/asdf.sh ]; then
  source ~/.asdf/asdf.sh
  source ~/.asdf/completions/asdf.bash
fi
