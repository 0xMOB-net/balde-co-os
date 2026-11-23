# Balde & Co OS V6

## Installation sûre
1. Si V5 n'a jamais été configurée, exécuter `schema.sql` dans Supabase SQL Editor.
2. Exécuter ensuite `migration-v6.sql` dans Supabase SQL Editor.
3. Créer un compte via l'application, confirmer l'adresse e-mail, puis attribuer le rôle `admin` dans SQL Editor en suivant le guide V5. Ne jamais partager les clés secrètes.
4. Dans Authentication > URL Configuration, ajouter `https://0xmob-net.github.io/balde-co-os/` dans les URLs de redirection.
5. Publier les fichiers statiques (sans publier les fichiers SQL si possible) sur GitHub Pages.
6. Tester avec deux comptes clients distincts : chacun ne doit voir que ses propres dossiers, messages et documents. Tester aussi le compte agent et administrateur avant usage réel.

## V6
- Recherche de dossiers et indicateurs de suivi.
- Dépôt privé de PDF/JPG/PNG jusqu'à 10 Mo par dossier, accès via URL signée de courte durée.
- Réinitialisation du mot de passe par e-mail.
- Conservation des conversations, tâches, paiements, rôles et PWA de V5.

## Limites et précautions
- La V6 est une préversion à valider, pas un service audité ou certifié.
- Pas encore d'IA serveur opérationnelle : une fonction sécurisée et un fournisseur d'IA restent nécessaires. Ne jamais insérer une clé API secrète dans index.html.
- Les notifications push, paiements en ligne, contrats et factures officiels ne sont pas intégrés.
- Les fichiers sensibles ne doivent pas être chargés avant les tests RLS, l'information des clients, la définition de la durée de conservation, les sauvegardes et la conformité juridique applicable.
- La V6 ne migre pas automatiquement les données locales de V4.
- La messagerie se rafraîchit à l'ouverture d'un dossier; le temps réel dépend de la configuration Supabase Realtime.
