# QuizEdam 🧠📱

Une application de quiz interactive développée avec Flutter et Firebase, offrant une expérience d'apprentissage engageante avec authentification utilisateur, effets sonores et interface multilingue.

## 🌟 Fonctionnalités

### 🔐 Authentification
- **Inscription/Connexion** avec Firebase Authentication
- **Mot de passe oublié** avec réinitialisation par email
- **Gestion de session** persistante
- **Déconnexion sécurisée**

### 🎯 Quiz Interactif
- **Questions à choix multiples** avec 4 options
- **Timer de 15 secondes** par question
- **Système de score** en temps réel
- **Résultats détaillés** à la fin du quiz
- **Historique des scores** personnalisé

### 🔊 Expérience Audio
- **Sons de feedback** (correct, incorrect, clic)
- **Support multi-formats** (MP3, WAV, OGG)
- **Contrôle du volume** dans les paramètres
- **Test audio** intégré

### 🌍 Internationalisation
- **Support multilingue** (Français, Anglais, Arabe)
- **Interface adaptative** selon la langue
- **Changement de langue** en temps réel

### ⚙️ Paramètres
- **Gestion du profil** utilisateur
- **Préférences audio** (volume, activation/désactivation)
- **Sélection de langue**
- **Déconnexion** sécurisée

## 🛠️ Technologies Utilisées

### Frontend
- **Flutter** 3.x - Framework de développement mobile
- **Dart** - Langage de programmation
- **Provider** - Gestion d'état
- **Material Design** - Interface utilisateur

### Backend & Services
- **Firebase Authentication** - Gestion des utilisateurs
- **Cloud Firestore** - Base de données NoSQL
- **Firebase Storage** - Stockage de fichiers

### Audio & Multimédia
- **audioplayers** - Lecture de fichiers audio
- **flutter_sound** - Enregistrement et lecture audio avancée

### Internationalisation
- **flutter_localizations** - Support multilingue
- **intl** - Formatage et localisation

## 📋 Prérequis

- **Flutter SDK** >= 3.0.0
- **Dart SDK** >= 2.17.0
- **Android Studio** / **VS Code** avec extensions Flutter
- **Compte Firebase** pour la configuration backend
- **Appareil Android** ou **Émulateur** pour les tests

## 🚀 Installation

### 1. Cloner le projet
```bash
git clone https://github.com/KammounEdam/quizedam.git
cd quizedam
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Configuration Firebase
Suivez le guide détaillé dans [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

**Fichiers de configuration requis :**
- `android/app/google-services.json` (Android)
- `web/firebase-config.js` (Web)

**Utilisez les fichiers d'exemple comme templates :**
- `android/app/google-services.json.example`
- `web/firebase-config.js.example`

### 4. Configuration Audio
Les fichiers audio sont inclus dans `assets/sounds/` :
- `correct.mp3` - Son de réponse correcte
- `wrong.ogg` - Son de réponse incorrecte
- `click.wav` - Son de clic

### 5. Lancer l'application
```bash
# Sur émulateur/appareil Android
flutter run

# Pour le web
flutter run -d chrome

# Pour iOS (macOS requis)
flutter run -d ios
```

## 📱 Plateformes Supportées

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11.0+)
- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🏗️ Architecture du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── quiz_models.dart     # Modèles pour les quiz
│   └── user_model.dart      # Modèle utilisateur
├── providers/               # Gestion d'état avec Provider
│   └── auth_provider.dart   # Provider d'authentification
├── screens/                 # Écrans de l'application
│   ├── auth/               # Écrans d'authentification
│   ├── home_screen.dart    # Écran d'accueil
│   ├── quiz_screen.dart    # Écran de quiz
│   └── settings_screen.dart # Écran des paramètres
├── services/               # Services et logique métier
│   ├── auth_service.dart   # Service d'authentification
│   ├── quiz_service.dart   # Service de quiz
│   └── audio_service.dart  # Service audio
├── utils/                  # Utilitaires
│   └── theme.dart         # Thème de l'application
└── widgets/               # Widgets réutilisables
    └── custom_widgets.dart
```

## 🎮 Guide d'Utilisation

### Première Utilisation
1. **Inscription** : Créez un compte avec email et mot de passe
2. **Connexion** : Connectez-vous avec vos identifiants
3. **Configuration** : Ajustez les paramètres audio et langue
4. **Premier Quiz** : Lancez votre premier quiz depuis l'écran d'accueil

### Fonctionnalités Principales
- **Démarrer un Quiz** : Bouton principal sur l'écran d'accueil
- **Voir les Scores** : Historique de vos performances
- **Paramètres** : Personnalisation de l'expérience
- **À Propos** : Informations sur l'application

## 🔧 Configuration Avancée

### Variables d'Environnement
Créez un fichier `.env` à la racine du projet :
```env
FIREBASE_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
```

### Configuration Audio
Ajoutez vos propres fichiers audio dans `assets/sounds/` :
- Formats supportés : MP3, WAV, OGG, AAC
- Taille recommandée : < 1MB par fichier
- Durée recommandée : < 3 secondes pour les effets

### Personnalisation du Thème
Modifiez `lib/utils/theme.dart` pour personnaliser :
- Couleurs principales
- Typographie
- Espacements
- Animations

## 🧪 Tests

### Tests Unitaires
```bash
flutter test
```

### Tests d'Intégration
```bash
flutter test integration_test/
```

### Tests sur Appareil
```bash
# Android
flutter run --release

# iOS
flutter run --release -d ios
```

## 📦 Build et Déploiement

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### iOS (macOS requis)
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🐛 Dépannage

### Problèmes Courants

**Erreur Firebase :**
```
[ERROR:flutter/runtime/dart_vm_initializer.cc] Unhandled Exception: [firebase_auth/unknown]
```
**Solution :** Vérifiez la configuration Firebase dans `google-services.json`

**Erreur Audio :**
```
[ERROR] AudioPlayer: Unable to load audio
```
**Solution :** Vérifiez que les fichiers audio sont dans `assets/sounds/` et déclarés dans `pubspec.yaml`

**Erreur de Build :**
```
Gradle build failed
```
**Solution :**
1. `flutter clean`
2. `flutter pub get`
3. `flutter run`

### Logs de Debug
```bash
flutter logs
```

## 🤝 Contribution

### Comment Contribuer
1. **Fork** le projet
2. **Créez** une branche feature (`git checkout -b feature/AmazingFeature`)
3. **Commitez** vos changements (`git commit -m 'Add some AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrez** une Pull Request

### Standards de Code
- Suivez les [conventions Dart](https://dart.dev/guides/language/effective-dart)
- Utilisez `flutter analyze` avant de commiter
- Ajoutez des tests pour les nouvelles fonctionnalités
- Documentez les fonctions publiques

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👨‍💻 Auteur

**Edam Kammoun**
- GitHub: [@KammounEdam](https://github.com/KammounEdam)
- Email: [votre-email@example.com](mailto:votre-email@example.com)

## 🙏 Remerciements

- **Flutter Team** pour le framework exceptionnel
- **Firebase** pour les services backend
- **Material Design** pour les guidelines UI/UX
- **Communauté Flutter** pour les packages et le support

## 📊 Statistiques du Projet

- **Langage Principal :** Dart (95%)
- **Lignes de Code :** ~2000+
- **Fichiers :** 25+
- **Dépendances :** 15+

## 🔄 Changelog

### Version 1.0.0 (2024)
- ✨ Première version stable
- 🔐 Authentification Firebase
- 🎯 Système de quiz complet
- 🔊 Support audio multi-format
- 🌍 Interface multilingue (FR, EN, AR)
- ⚙️ Écran de paramètres
- 📱 Support multi-plateforme

---

**⭐ Si ce projet vous plaît, n'hésitez pas à lui donner une étoile !**
