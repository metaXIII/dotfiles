# see `man dnf.conf` for defaults and possible options

[main]
# --- Performance & Téléchargement ---
# 10 à 15 est le "sweet spot". Au-delà, certains miroirs peuvent limiter la connexion.
max_parallel_downloads=10
fastestmirror=True
# Utilise le protocole DeltaRPM pour ne télécharger que les différences (gain de bande passante)
deltarpm=True

# --- Gestion du Cache & Stockage ---
# Garder le cache est utile si tu réinstalles souvent, sinon ça prend de la place pour rien.
keepcache=True
# Supprime les dépendances qui ne sont plus nécessaires après un "remove"
clean_requirements_on_remove=True
# Supprime les versions précédentes des paquets du cache pour libérer de l'espace
minrate=30k
timeout=30

# --- Expérience Utilisateur (UI) ---
color=always
# Affiche une barre de progression plus moderne lors de l'installation
showdupesfromrepos=False
# Très pratique : affiche la taille totale du téléchargement et l'espace disque requis
ip_resolved=IPv4

# --- Stabilité & Résolution ---
# Force DNF à utiliser la meilleure version disponible (parfois strict, mais propre)
best=True
# Évite de bloquer toute la transaction si un dépôt est temporairement hors ligne
skip_if_unavailable=True
install_weak_deps=True
gpgcheck=True

# --- Optimisation Base de Données ---
# On rafraîchit les métadonnées moins souvent pour gagner du temps au lancement
metadata_expire=6h

