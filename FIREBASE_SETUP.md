# Configuration Firebase pour QuizEdam

## Étapes de configuration

### 1. Créer un projet Firebase
1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet
3. Activez Authentication et Firestore

### 2. Configuration Android
1. Dans Firebase Console, ajoutez une app Android
2. Téléchargez le fichier `google-services.json`
3. Copiez le contenu dans `android/app/google-services.json`
4. Utilisez `android/app/google-services.json.example` comme modèle

### 3. Configuration Web
1. Dans Firebase Console, ajoutez une app Web
2. Copiez la configuration Firebase
3. Remplacez les valeurs dans `web/firebase-config.js`
4. Utilisez `web/firebase-config.js.example` comme modèle

### 4. Fichiers à ne pas commiter
Les fichiers suivants contiennent des clés sensibles et ne doivent PAS être commitées :
- `android/app/google-services.json`
- `web/firebase-config.js` (si il contient de vraies clés)

### 5. Variables d'environnement
Pour la production, utilisez des variables d'environnement pour stocker les clés API.

## Sécurité
- Ne jamais commiter les vraies clés API
- Utiliser les fichiers .example comme modèles
- Configurer les restrictions d'API dans Firebase Console
