#!/bin/bash
# Re-apply battery charge limit after waking from suspend or hibernate
case "${1:-}/${2:-}" in
  post/*)
    /usr/local/bin/omarchy-set-charge-limit --restore || true
    ;;
esac
