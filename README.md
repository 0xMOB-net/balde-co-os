# Balde & Co OS V4 — PWA

Application installable via GitHub Pages, sans Play Store.

## Fonctionnalités
- Dossiers clients, parcours, notes internes par dossier, tâches, suivi documentaire et paiements.
- Impression de la fiche d’un dossier.
- Export et restauration de sauvegardes JSON dans Paramètres.
- PWA installable et mode hors ligne après premier chargement.

## Mise à jour d’un dépôt existant
Copier tous les fichiers à la racine du dépôt puis `git add . && git commit -m "Balde & Co OS V4" && git push`.

## Sécurité
Stockage local au navigateur (clé conservée `baldecoos_v2` pour préserver les données des versions précédentes). Pas de base de données distante, de connexion utilisateur, de messagerie multi-utilisateurs ou d’IA connectée. Ne pas enregistrer de données sensibles. Les fichiers de sauvegarde JSON ne sont pas chiffrés.
