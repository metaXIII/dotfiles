location : `/etc/dnf/dnf.conf`

```conf
# see `man dnf.conf` for defaults and possible options

[main]
# Utiliser le cache des paquets pour éviter les re-téléchargements
keepcache=True

# Télécharger les paquets en parallèle (utile avec une bonne connexion)
max_parallel_downloads=15

# Choisir automatiquement le miroir le plus rapide
fastestmirror=True

# Réduire les métadonnées inutiles
metadata_timer_sync=3600

# Installer automatiquement les dépendances faibles (pratique pour le dev)
install_weak_deps=True

# Nettoyer automatiquement les dépendances inutiles
clean_requirements_on_remove=True

# Affichage plus clair
color=always
color_list_installed_older=yellow
color_list_installed_newer=green
color_list_available_upgrade=bold,blue

# Tolérance réseau (utile sur laptop / Wi-Fi)
timeout=20
retries=5

# Vérification GPG (sécurité, à garder activé)
gpgcheck=True

# Résolution plus rapide des dépendances
best=True

# Priorité à la stabilité
skip_if_unavailable=True

```
