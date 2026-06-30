# BadWallet Consumer - Application Mobile

Application mobile orientée client final pour la gestion de portefeuille (BadWallet).
Conçue avec Flutter, elle offre une interface moderne inspirée de Wave et Orange Money.

## Fonctionnalités

1. **Authentification & Onboarding** : Connexion via numéro de téléphone (persistant via `flutter_secure_storage`).
2. **Tableau de bord (Dashboard)** : Affichage du solde avec option de masquage, accès rapide aux actions et historique récent.
3. **Transferts d'argent** : Envoi de fonds à un autre utilisateur via un pavé numérique ergonomique.
4. **Paiement de factures** : Liste des factures impayées et paiement multiple par sélection de cases à cocher.
5. **Historique** : Suivi des transactions avec code couleur (rouge pour les débits, vert pour les crédits).

## Architecture 

Le projet suit une architecture **Feature-First** pour une meilleure modularité :
- `lib/core/` : Configurations (Thème, Couleurs, Client API HTTP).
- `lib/models/` : Modèles de données (Transaction, Facture, Balance).
- `lib/providers/` : State Management (`WalletProvider` gérant l'état de l'application et les appels API).
- `lib/features/` : Modules fonctionnels (`auth`, `dashboard`, `transfers`, `bills`, `history`).

## Dépendances clés

- `provider` : State management.
- `http` : Communication avec l'API.
- `intl` : Formatage monétaire et dates.
- `google_fonts` : Typographie moderne (Inter).
- `flutter_secure_storage` : Sauvegarde sécurisée du numéro de téléphone.

## Captures d'écran

Les captures d'écran de l'application (toutes les pages) sont regroupées dans un fichier PDF disponible dans le dépôt.

> 📄 **Voir le fichier PDF joint dans le dépôt** pour l'ensemble des captures d'écran de l'application.

## APK - Fichier installable Android

Un fichier APK prêt à l'emploi est disponible directement dans le dépôt :

```
build/app/outputs/flutter-apk/app-release.apk
```

> 📦 **Taille** : ~48.7 MB  
> 📱 **Compatible** : Android uniquement (non compatible iPhone/iOS)  
> ⚠️ Activez **"Sources inconnues"** dans les paramètres Android avant installation.

## Déploiement (recompilation)

Pour regénérer l'APK depuis les sources :

```bash
flutter build apk --release
```

Le fichier sera disponible sous : `build/app/outputs/flutter-apk/app-release.apk`.
