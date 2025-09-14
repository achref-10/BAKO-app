import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'connexion_screen.dart';
import 'client/DashboardScreen.dart';
import 'admin/AdminDashboard.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    try {
      if (_authService.currentUser != null) {
        // Fetch role for the current user using the public method
        await _authService.fetchUserRole();
      }
    } catch (e) {
      print("Error checking current user: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          
          if (user == null) {
            // User is not logged in
            return const ConnexionScreen();
          }
          
          // User is logged in, check role
          return FutureBuilder(
            future: _getRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.done) {
                if (_authService.isAdmin) {
                  return const AdminDashboard();
                } else {
                  return DashboardScreen(
                    username: user.displayName,
                    email: user.email,
                  );
                }
              }
              
              // Still determining role
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        }
        
        // Connection state is not active yet
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<String> _getRole() async {
    if (_authService.currentUser != null) {
      // Use the public method to fetch user role
      return await _authService.fetchUserRole();
    }
    return _authService.userRole;
  }
}
