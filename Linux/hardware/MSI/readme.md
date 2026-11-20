# Configuration Matérielle et Automatisations

Ce dossier contient les scripts et configurations spécifiques à cette machine sous Fedora, notamment pour l'optimisation du stockage (partitionnement NVMe / SSD / HDD) et la gestion du cycle de vie des données.

---

## 📂 Structure du dossier

- `scripts/`
  - `archiver.sh` : Script Bash intelligent qui scanne les dossiers personnels (`Documents`, `Pictures`, `Music`, `Videos`) sur le NVMe et déplace automatiquement vers le HDD (`/mnt/HDD/Medias`) les fichiers inactifs depuis plus de 180 jours.
- `system.d/`
  - Sous-dossier `archive/` : Fichiers de configuration du service et du timer systemd utilisateur.

---

## 🛠️ Le Service d'Archivage Automatique

### Objectif et Justification
L'objectif est d'optimiser l'espace de stockage du NVMe principal (réservé au système, au code et aux notes) en déchargeant le contenu froid (médias, documents peu consultés) vers un HDD de stockage de masse.

Le script utilise l'option `--ignore-existing` de rsync pour garantir qu'aucun fichier existant sur le HDD ne soit écrasé par mégarde.

### Installation et Activation du Systemd Timer

Pour que le système exécute cet archivage mensuellement de manière persistante (et rattrape la tâche au prochain démarrage si le PC était éteint à l'heure prévue) :

1. **Créer les liens symboliques vers l'environnement utilisateur systemd :**

```bash
   mkdir -p ~/.config/systemd/user
   ln -sf $(pwd)/system.d/archive/archiver.service ~/.config/systemd/user/archiver.service
   ln -sf $(pwd)/system.d/archive/archiver.timer ~/.config/systemd/user/archiver.timer
```

# Consulter le dernier log d'archivage généré :
cat /home/meta/Logs/archive/archive-*.log | tail -n 50
