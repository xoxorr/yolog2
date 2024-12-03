import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _error;
  User? _user;

  User? get currentUser => _auth.currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.reload();
      if (userCredential.user?.emailVerified == true) {
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'emailVerified': true});

        _user = userCredential.user;
        _error = null;
        return true;
      } else {
        await _auth.signOut();
        _error = '이메일 인증이 필요합니다. 이메일을 확인해주세요.';
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _error = '등록되지 않은 이메일입니다.';
          break;
        case 'wrong-password':
          _error = '잘못된 비밀번호입니다.';
          break;
        case 'user-disabled':
          _error = '비활성화된 계정입니다.';
          break;
        case 'too-many-requests':
          _error = '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
          break;
        default:
          _error = '로그인 중 오류가 발생했습니다.';
      }
      return false;
    } catch (e) {
      _error = '알 수 없는 오류가 발생했습니다.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      _error = '비밀번호가 일치하지 않습니다.';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.sendEmailVerification();

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      });

      await _auth.signOut();

      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _error = '이미 사용 중인 이메일입니다.';
          break;
        case 'invalid-email':
          _error = '유효하지 않은 이메일 형식입니다.';
          break;
        case 'weak-password':
          _error = '비밀번호가 너무 약합니다.';
          break;
        default:
          _error = '회원가입 중 오류가 발생했습니다.';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _error = '구글 로그인이 취소되었습니다.';
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_auth.currentUser?.providerData
              .any((info) => info.providerId == 'google.com') ??
          false) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      notifyListeners(); // 상태 변경을 알림
    } catch (e) {
      _error = e.toString();
      notifyListeners(); // 에러 상태를 알림
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      if (user.emailVerified) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'emailVerified': true});
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      _error = '인증 메일 발송 중 오류가 발생했습니다.';
      notifyListeners();
    }
  }
}
