#!/bin/bash

# Configuration
DEST_BASE="/mnt/HDD/Medias"
JOURS=180  # Seuil d'inactivité en jours
FOLDERS=("Documents" "Pictures" "Music" "Videos")
LOG_DIR="$HOME/Logs/archive"
OBSIDIAN_DIR="Obsidian"

echo "=== Début du grand nettoyage et archivage ($JOURS jours d'inactivité) ==="
mkdir -p "$LOG_DIR" 2>/dev/null

ARCHIVE_STATUS=0
for FOLDER in "${FOLDERS[@]}"; do
    SRC_DIR="$HOME/$FOLDER"
    DEST_DIR="$DEST_BASE/$FOLDER"

    if [ -d "$SRC_DIR" ]; then
        echo "Scan et archivage de $FOLDER (hors Obsidian)..."
        if ! mkdir -p "$DEST_DIR"; then
            echo "[X] Impossible de créer le dossier de destination $DEST_DIR."
            ARCHIVE_STATUS=1
            continue
        fi
        if ! cd "$SRC_DIR"; then
            echo "[X] Impossible d'accéder au dossier source $SRC_DIR."
            ARCHIVE_STATUS=1
            continue
        fi

        # 2. Rsync avec find en mode exclusion d'Obsidian :
        # - Si on croise le dossier Obsidian, on le saute (-prune)
        # - Sinon (-type f), on archive en conservant l'arborescence exacte (--relative)
        set -o pipefail
        if ! find . \( -name "$OBSIDIAN_DIR" -type d \) -prune -o -type f -mtime +$JOURS -print0 | \
            rsync -av --relative --ignore-existing --remove-source-files --files-from=- --from0 ./ "$DEST_DIR/"; then
            echo "[X] Une erreur est survenue pendant l'archivage de $FOLDER."
            ARCHIVE_STATUS=1
            continue
        fi

        # 3. Nettoyage des sous-dossiers devenus vides sur le NVMe (en évitant de toucher à Obsidian)
        if ! find . \( -name "$OBSIDIAN_DIR" -type d \) -prune -o -mindepth 1 -type d -empty -delete; then
            echo "[X] Impossible de nettoyer les dossiers vides dans $SRC_DIR."
            ARCHIVE_STATUS=1
        fi
    fi
done

# ==========================================
# Rotation des logs : Conserver uniquement les 5 plus récents
# ==========================================
if [ -d "$LOG_DIR" ]; then
    echo "Nettoyage des anciens fichiers de log (conservation des 5 derniers)..."
    ls -t "$LOG_DIR"/archive-*.log 2>/dev/null | tail -n +6 | xargs -r rm --
fi

if [ "$ARCHIVE_STATUS" -eq 0 ]; then
    echo "=== Archivage terminé avec succès ! ==="
else
    echo "=== Archivage terminé avec des erreurs ==="
fi

exit "$ARCHIVE_STATUS"
