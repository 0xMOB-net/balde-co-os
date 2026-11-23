# Balde & Co OS V5 — base collaborative

## Installation
1. Supabase > SQL Editor : exécuter `schema.sql` **une seule fois**.
2. Supabase > Authentication > URL Configuration : Site URL `https://0xmob-net.github.io/balde-co-os/` et Redirect URLs autorisées pour cette même adresse.
3. Supabase > Authentication > Providers > Email : activer l'email et la confirmation d'adresse selon votre politique.
4. Créer un compte dans l'application et confirmer son adresse si demandé.
5. Dans SQL Editor, attribuer le rôle administrateur à ce compte (remplacer `YOUR_EMAIL`) :

```sql
begin;
alter table public.profiles disable trigger prevent_role_change;
update public.profiles set role='admin'
where id=(select id from auth.users where email='YOUR_EMAIL');
alter table public.profiles enable trigger prevent_role_change;
commit;
```

6. Déployer les fichiers de cette archive à la racine du dépôt GitHub Pages.
7. Pour créer un agent : l'agent s'inscrit, puis un administrateur du projet Supabase lui attribue le rôle `agent` en reprenant le script ci-dessus (en changeant le rôle).

## Fonctionnalités opérationnelles après configuration
- Comptes avec Supabase Auth et rôles `client`, `agent`, `admin`.
- Création de dossiers clients, suivi de statut et affectation de conseillers.
- Messagerie par dossier, notes internes cachées aux clients.
- Tâches et paiements consultables selon les droits.
- RLS appliquée côté base de données.

## Limites à connaître
- Pas d'IA connectée dans cette version : nécessite un backend/Edge Function et une clé secrète côté serveur.
- Pas de téléversement de pièces d'identité : nécessite un bucket privé et des politiques Storage.
- Les notifications temps réel nécessitent la configuration de la publication Realtime pour `messages`; sans cela, rouvrir un dossier pour actualiser les messages.
- L'interface ne fonctionne pas hors ligne pour les données Supabase. Le cache PWA ne concerne que la coque de l'application.
- L'URL et la clé publique Supabase sont intégrées au navigateur, ce qui est normal. Ne jamais y mettre de clé secrète.
- Le déploiement sur GitHub Pages ne remplace pas les vérifications de sécurité, la politique de confidentialité et les tests avant usage réel.
