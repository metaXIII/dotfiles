switch-en() {
    echo "=== Configuration du clavier en Anglais US (en_US / QWERTY) pour Fedora ==="

    # 1. Changement immédiat pour la session active (X11 et Wayland)
    local SESSION_STATUS=0
    local SESSION_COMMAND_USED=0

    if command -v setxkbmap &> /dev/null; then
        SESSION_COMMAND_USED=1
        if setxkbmap us; then
            SESSION_STATUS=0
        else
            SESSION_STATUS=1
        fi
    fi
    # Support explicite pour GNOME Wayland
    if command -v gsettings &> /dev/null && [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
        SESSION_COMMAND_USED=1
        if gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us')]"; then
            SESSION_STATUS=0
        else
            SESSION_STATUS=1
        fi
    fi
    # Support explicite pour KDE Plasma Wayland
    if command -v kwriteconfig6 &> /dev/null && [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
        SESSION_COMMAND_USED=1
        if kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us"; then
            SESSION_STATUS=0
        else
            SESSION_STATUS=1
        fi
    fi
    if [ "$SESSION_COMMAND_USED" -ne 1 ] || [ "$SESSION_STATUS" -ne 0 ]; then
        echo "[X] Impossible de modifier le clavier de la session courante."
        return 1
    fi
    echo "[✓] Clavier de la session courante passé en en_US (QWERTY)."

    # 2. Changement global et persistant du système
    echo "-> Modification de la configuration système locale..."
    if ! sudo localectl set-x11-keymap us || ! sudo localectl set-keymap us; then
        echo "[X] Impossible de mettre à jour la configuration locale du système."
        return 1
    fi
    echo "[✓] Configuration locale système mise à jour en en_US."

    # 3. Forcer Dracut à inclure la configuration du clavier pour le chiffrement
    echo "-> Configuration de Dracut pour l'initramfs..."
    if [ ! -f /etc/dracut.conf.d/keyboard.conf ] || ! grep -Fxq 'i18n_install_all="yes"' /etc/dracut.conf.d/keyboard.conf; then
        if [ -f /etc/dracut.conf.d/keyboard.conf ]; then
            if ! echo 'i18n_install_all="yes"' | sudo tee -a /etc/dracut.conf.d/keyboard.conf > /dev/null; then
                echo "[X] Impossible de compléter la configuration Dracut."
                return 1
            fi
        elif ! echo 'i18n_install_all="yes"' | sudo tee /etc/dracut.conf.d/keyboard.conf > /dev/null; then
            echo "[X] Impossible de créer la configuration Dracut."
            return 1
        fi
        echo "[✓] Fichier de configuration Dracut créé."
    else
        echo "[i] Dracut est déjà configuré pour inclure les dispositions de clavier."
    fi

    # 4. Régénération de l'initramfs avec Dracut
    echo "=== Régénération de l'image de démarrage (Initramfs) ==="
    echo "Cette étape nécessite les privilèges root et prend quelques secondes..."
    
    sudo dracut -f --regenerate-all
    local DRACUT_STATUS=$?

    if [ "$DRACUT_STATUS" -eq 0 ]; then
        echo "[✓] Initramfs mis à jour avec succès pour tous les noyaux."
        echo "---"
        echo "Félicitations ! Votre clavier est configuré en en_US (QWERTY)."
        echo "Au prochain redémarrage, l'écran de déverrouillage du disque sera en QWERTY."
        return 0
    else
        echo "[X] Une erreur est survenue lors de la génération de l'initramfs."
        return 1
    fi
}
