#!/bin/bash
# Install immersion-mpd CLI helper script into ~/.local/bin

mkdir -p ~/.local/bin

cat << 'EOF' > ~/.local/bin/immersion-mpd
#!/bin/bash
# AJATT MPD Immersion Manager

case "$1" in
    current)
        echo "🎧 Loading latest condensed audio (current)..."
        mpc update --wait >/dev/null
        mpc clear >/dev/null
        mpc add "current" >/dev/null
        mpc repeat on >/dev/null
        mpc random on >/dev/null
        mpc play
        ;;
    toggle|pause|play)
        mpc toggle
        ;;
    next)
        mpc next
        ;;
    prev)
        mpc prev
        ;;
    status)
        mpc status
        ;;
    stop)
        mpc stop
        ;;
    *)
        echo "🎧 Starting full AJATT background immersion loop..."
        mpc update --wait >/dev/null
        mpc clear >/dev/null
        mpc add / >/dev/null
        mpc random on >/dev/null
        mpc repeat on >/dev/null
        mpc play
        ;;
esac
EOF

chmod +x ~/.local/bin/immersion-mpd
echo "✔ Installed immersion-mpd to ~/.local/bin/immersion-mpd"
