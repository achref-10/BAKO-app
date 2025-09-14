// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Instance singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Getters
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;

  // Role management
  String _userRole = 'user'; // Default role
  String get userRole => _userRole;
  bool get isAdmin => _userRole == 'admin';

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Public method to fetch user role - to be called from wrapper
  Future<String> fetchUserRole() async {
    if (currentUser != null) {
      await _fetchUserRole(currentUser!.uid);
    }
    return _userRole;
  }

  // Private method to fetch user role from Firestore
  Future<void> _fetchUserRole(String uid) async {
    try {
      // Check if user exists in users collection
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        _userRole = userData['role'] ?? 'user';
      } else {
        // Fallback: Check if email is admin email
        if (_auth.currentUser?.email == 'admin@gmail.com') {
          _userRole = 'admin';
          // Create user document with admin role
          await _firestore.collection('users').doc(uid).set({
            'email': _auth.currentUser?.email,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          _userRole = 'user';
        }
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      _userRole = 'user'; // Default to user role on error
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (result.user != null) {
        // Fetch user role from Firestore
        await _fetchUserRole(result.user!.uid);
        debugPrint('Connexion réussie pour: ${result.user?.email} avec rôle: $_userRole');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur Firebase Auth: ${e.code} - ${e.message}');
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Erreur lors de la connexion: $e');
      throw Exception('Erreur de connexion. Veuillez réessayer.');
    }
  }

  // Sign up with email and password
  Future<Map<String, dynamic>?> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    String role = 'user', // Default role for new users
  }) async {
    try {
      // Validation basique
      if (email.isEmpty || password.isEmpty || nom.isEmpty || prenom.isEmpty) {
        throw Exception('Tous les champs sont requis');
      }

      if (password.length < 6) {
        throw Exception('Le mot de passe doit contenir au moins 6 caractères');
      }

      if (!isValidEmail(email)) {
        throw Exception('Format d\'email invalide');
      }

      // Create user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (result.user != null) {
        // Set the user's display name
        await result.user!.updateDisplayName('$prenom $nom');
        
        // Determine role - admin@gmail.com always gets admin role
        String assignedRole = email.trim() == 'admin@gmail.com' ? 'admin' : role;
        
        // Store user data in Firestore with role
        await _firestore.collection('users').doc(result.user!.uid).set({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'fullName': '$prenom $nom',
          'role': assignedRole,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Set the role in the service
        _userRole = assignedRole;
        
        debugPrint('Inscription réussie pour: ${result.user?.email} avec rôle: $_userRole');
        
        // Return user data including role
        return {
          'id': result.user!.uid,
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'fullName': '$prenom $nom',
          'role': assignedRole,
        };
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur Firebase Auth: ${e.code} - ${e.message}');
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Erreur lors de l\'inscription: $e');
      throw Exception('Erreur d\'inscription. Veuillez réessayer.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _userRole = 'user'; // Reset role on sign out
      await _auth.signOut();
      debugPrint('Déconnexion réussie');
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      throw Exception('Erreur de déconnexion');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      if (!isValidEmail(email)) {
        throw Exception('Format d\'email invalide');
      }
      
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('Email de réinitialisation envoyé à: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erreur Firebase Auth: ${e.code} - ${e.message}');
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Erreur lors de la réinitialisation: $e');
      throw Exception('Erreur de réinitialisation');
    }
  }

  // Validation methods
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Error message handler
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'Format d\'email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'network-request-failed':
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
      default:
        return 'Une erreur s\'est produite. Veuillez réessayer.';
    }
  }
}
