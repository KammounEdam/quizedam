# Guide de Contribution - QuizEdam

Merci de votre intérêt pour contribuer à QuizEdam ! 🎉

## 🚀 Comment Contribuer

### 1. Fork et Clone
```bash
# Fork le projet sur GitHub
# Puis clonez votre fork
git clone https://github.com/VOTRE_USERNAME/quizedam.git
cd quizedam
```

### 2. Configuration de l'Environnement
```bash
# Installez les dépendances
flutter pub get

# Vérifiez que tout fonctionne
flutter analyze
flutter test
```

### 3. Créer une Branche
```bash
git checkout -b feature/ma-nouvelle-fonctionnalite
# ou
git checkout -b fix/correction-bug
```

### 4. Développement
- Suivez les [conventions Dart](https://dart.dev/guides/language/effective-dart)
- Ajoutez des tests pour les nouvelles fonctionnalités
- Documentez votre code
- Testez sur différentes plateformes si possible

### 5. Tests
```bash
# Tests unitaires
flutter test

# Analyse du code
flutter analyze

# Formatage du code
dart format .
```

### 6. Commit et Push
```bash
git add .
git commit -m "feat: ajouter nouvelle fonctionnalité X"
git push origin feature/ma-nouvelle-fonctionnalite
```

### 7. Pull Request
- Créez une Pull Request sur GitHub
- Décrivez clairement vos changements
- Référencez les issues liées si applicable

## 📝 Standards de Code

### Conventions de Nommage
- **Classes** : PascalCase (`QuizScreen`)
- **Variables/Fonctions** : camelCase (`getUserScore`)
- **Constantes** : SCREAMING_SNAKE_CASE (`MAX_QUESTIONS`)
- **Fichiers** : snake_case (`quiz_screen.dart`)

### Structure des Commits
Utilisez les préfixes suivants :
- `feat:` - Nouvelle fonctionnalité
- `fix:` - Correction de bug
- `docs:` - Documentation
- `style:` - Formatage, pas de changement de code
- `refactor:` - Refactoring du code
- `test:` - Ajout ou modification de tests
- `chore:` - Maintenance

### Documentation
- Documentez les fonctions publiques
- Ajoutez des commentaires pour la logique complexe
- Mettez à jour le README si nécessaire

## 🐛 Signaler des Bugs

### Avant de Signaler
1. Vérifiez que le bug n'a pas déjà été signalé
2. Testez avec la dernière version
3. Reproduisez le bug de manière consistante

### Template de Bug Report
```markdown
**Description du Bug**
Description claire et concise du problème.

**Étapes pour Reproduire**
1. Aller à '...'
2. Cliquer sur '...'
3. Voir l'erreur

**Comportement Attendu**
Ce qui devrait se passer.

**Captures d'Écran**
Si applicable, ajoutez des captures d'écran.

**Environnement**
- OS: [ex. Android 12]
- Flutter Version: [ex. 3.16.0]
- Appareil: [ex. Pixel 6]
```

## 💡 Proposer des Fonctionnalités

### Template de Feature Request
```markdown
**Problème à Résoudre**
Description claire du problème que cette fonctionnalité résoudrait.

**Solution Proposée**
Description claire de ce que vous voulez qui se passe.

**Alternatives Considérées**
Autres solutions que vous avez envisagées.

**Contexte Additionnel**
Tout autre contexte ou captures d'écran.
```

## 🎯 Domaines de Contribution

### Priorités Actuelles
- 🔊 Amélioration du système audio
- 🌍 Ajout de nouvelles langues
- 🎨 Amélioration de l'UI/UX
- 📱 Optimisation des performances
- 🧪 Ajout de tests

### Idées de Contribution
- Nouvelles catégories de quiz
- Mode multijoueur
- Système de badges/achievements
- Mode hors ligne
- Thèmes personnalisés

## 📞 Contact

- **Issues GitHub** : Pour bugs et feature requests
- **Discussions** : Pour questions générales
- **Email** : [votre-email@example.com](mailto:votre-email@example.com)

## 🙏 Remerciements

Merci à tous les contributeurs qui rendent ce projet possible !

---

**Note** : En contribuant à ce projet, vous acceptez que vos contributions soient sous licence MIT.
