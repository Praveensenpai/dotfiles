#!/bin/bash
case "$1" in
  toggle)
    fcitx5-remote -t
    ;;
  mozc)
    fcitx5-remote -s mozc >/dev/null 2>&1 || true
    fcitx5-remote -o >/dev/null 2>&1 || true
    ;;
  us)
    fcitx5-remote -c >/dev/null 2>&1 || true
    ;;
  *)
    echo "Usage: $0 {toggle|mozc|us}"
    exit 1
    ;;
esac
