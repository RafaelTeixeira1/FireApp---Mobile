import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  static const String _lembrarMeKey = 'lembrarMe';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool lembrarMe = false,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lembrarMeKey, lembrarMe);
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lembrarMeKey);
  }

  /// Mantém a sessão apenas se o usuário marcou "Lembrar-me" no último login.
  Future<void> restaurarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_lembrarMeKey) ?? false) return;
    await signOut();
  }
}
