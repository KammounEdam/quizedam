// Firebase configuration for web
// Replace this with your actual Firebase config from Firebase Console

const firebaseConfig = {
  apiKey: "AIzaSyBySUpCbpmiSbTNiEIVLAu70LlQJH-nkKY",
  authDomain: "quiz-app-flutter-a070b.firebaseapp.com",
  projectId: "quiz-app-flutter-a070b",
  storageBucket: "quiz-app-flutter-a070b.firebasestorage.app",
  messagingSenderId: "921013274197",
  appId: "1:921013274197:web:33acd3f801cfb223a136dc",
  measurementId: "G-DGFDVQ53RQ"
};

// Initialize Firebase
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
