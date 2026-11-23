# Balde & Co OS — PWA

Application statique installable depuis Chrome/Edge sur Android et ordinateur, et via Partager > Sur l’écran d’accueil sur iPhone (Safari).

## Publier avec GitHub Pages

1. Créez un dépôt GitHub **balde-co-os**.
2. Dans ce dossier :

```bash
git init
git add .
git commit -m "Balde & Co OS PWA"
git branch -M main
git remote add origin https://github.com/VOTRE_IDENTIFIANT/balde-co-os.git
git push -u origin main
```

3. GitHub > dépôt > Settings > Pages > Build and deployment : **Deploy from a branch**, branche **main**, dossier **/(root)**, Save.
4. Ouvrez `https://VOTRE_IDENTIFIANT.github.io/balde-co-os/` dans Chrome/Edge, puis **Installer** (ou menu > Installer l'application).

## Limitations importantes

- Les dossiers, paiements et conversations sont stockés **uniquement dans localStorage sur l'appareil et le navigateur utilisés**. Aucun compte, aucune synchronisation multi-appareils, aucune sauvegarde serveur.
- GitHub Pages héberge un site public. **Ne saisissez pas de données réelles sensibles, passeports, informations financières ou dossiers confidentiels** dans cette version de démonstration.
- Le module conversations contient des **notes internes locales**, pas une messagerie client en temps réel.
- Les analyses de l'assistant sont des règles locales, pas une IA connectée.
- Utilisez Exporter JSON régulièrement, et conservez les exports en lieu sûr.
- Pour une exploitation réelle, il faut authentification, base de données, contrôles d'accès, sauvegardes, journal d'audit et hébergement approprié.
