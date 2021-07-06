import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthentication {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _register(email, password);
      } else
        throw e;
    } catch (e) {
      throw e;
    }
  }

  void _register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw e;
    }
  }
}
