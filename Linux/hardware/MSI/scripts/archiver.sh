#!/bin/bash

# Configuration
DEST_BASE="/mnt/HDD/Medias"
JOURS=90  # Seuil d'inactivité en jours

echo "=== Début du grand nettoyage et archivage ($JOURS jours d'inactivité) ==="

# 1. Documents
if [ -d "$HOME/Documents" ]; then
    echo "Scan de Documents..."
    find "$HOME/Documents" -type f -mtime +$JOURS -exec mkdir -p "$DEST_BASE/Documents" \; -exec mv -n {} "$DEST_BASE/Documents/" \;
fi

# 2. Pictures
if [ -d "$HOME/Pictures" ]; then
    echo "Scan de Pictures..."
    find "$HOME/Pictures" -type f -mtime +$JOURS -exec mkdir -p "$DEST_BASE/Pictures" \; -exec mv -n {} "$DEST_BASE/Pictures/" \;
fi

# 3. Music
if [ -d "$HOME/Music" ]; then
    echo "Scan de Music..."
    find "$HOME/Music" -type f -mtime +$JOURS -exec mkdir -p "$DEST_BASE/Music" \; -exec mv -n {} "$DEST_BASE/Music/" \;
fi

# 4. Videos
if [ -d "$HOME/Videos" ]; then
    echo "Scan de Videos..."
    find "$HOME/Videos" -type f -mtime +$JOURS -exec mkdir -p "$DEST_BASE/Videos" \; -exec mv -n {} "$DEST_BASE/Videos/" \;
fi

echo "=== Archivage terminé avec succès ! ==="
