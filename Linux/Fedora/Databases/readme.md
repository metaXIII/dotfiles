-- 1. Créer la base de données
CREATE DATABASE mon_projet 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

-- 2. Créer l'utilisateur (limité aux connexions locales)
CREATE USER 'dev_user'@'localhost' IDENTIFIED BY 'mot_de_passe_securise';

-- 3. Donner tous les droits sur cette base spécifique uniquement
GRANT ALL PRIVILEGES ON mon_projet.* TO 'dev_user'@'localhost';

-- 4. Appliquer les changements
FLUSH PRIVILEGES;

-- 5. Quitter
EXIT;

