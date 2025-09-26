// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyC6N1O6feQjTNhWqAIh3QZ71m7qvx9pqSE",
  authDomain: "gen-lang-client-0610030211.firebaseapp.com",
  projectId: "gen-lang-client-0610030211",
  storageBucket: "gen-lang-client-0610030211.firebasestorage.app",
  messagingSenderId: "961063588565",
  appId: "1:961063588565:web:0857f2508591e3f185c85c",
  measurementId: "G-Y2F39Q4BXM"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
