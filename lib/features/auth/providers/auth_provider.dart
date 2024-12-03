import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _error;
  User? _user;
  String? _tempPassword;

  // 로그인 시도 제한을 위한 변수들 추가
  int _loginAttempts = 0;
  DateTime? _lastLoginAttempt;
  static const int maxLoginAttempts = 10; // 최대 시도 횟수
  static const int lockoutMinutes = 30; // 잠금 시간(분)

  User? get currentUser => _auth.currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  // 로그인 시도 가능 여부 확인 메서드
  bool _canAttemptLogin() {
    if (_loginAttempts >= maxLoginAttempts) {
      if (_lastLoginAttempt != null) {
        final timeDiff = DateTime.now().difference(_lastLoginAttempt!);
        if (timeDiff.inMinutes < lockoutMinutes) {
          final remainingMinutes = lockoutMinutes - timeDiff.inMinutes;
          throw '너무 많은 로그인 시도가 있었습니다. $remainingMinutes분 후에 다시 시도해주세요.';
        } else {
          // 잠금 시간이 지났으면 카운트 초기화
          _loginAttempts = 0;
          _lastLoginAttempt = null;
        }
      }
    }
    return true;
  }

  // 로그인 시도 횟수 증가
  void _incrementLoginAttempts() {
    _loginAttempts++;
    _lastLoginAttempt = DateTime.now();
  }

  // 로그인 성공 시 카운트 초기화
  void _resetLoginAttempts() {
    _loginAttempts = 0;
    _lastLoginAttempt = null;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 로그인 시도 가능 여부 확인
      _canAttemptLogin();

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
        _resetLoginAttempts(); // 로그인 성공 시 카운트 초기화
        return true;
      } else {
        await _auth.signOut();
        _error = '이메일 인증이 필요합니다. 이메일을 확인해주세요.';
        _incrementLoginAttempts(); // 실패 시 카운트 증가
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _incrementLoginAttempts(); // 실패 시 카운트 증가
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
      _incrementLoginAttempts(); // 실패 시 카운트 증가
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

      _tempPassword = password;

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
      _tempPassword = null;
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
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw '등록되지 않은 이메일입니다.';
        case 'invalid-email':
          throw '올바르지 않은 이메일 형식입니다.';
        default:
          throw '비밀번호 재설정 이메일 발송 중 오류가 발생했습니다.';
      }
    } catch (e) {
      throw '알 수 없는 오류가 발생했습니다.';
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

  Future<void> resendVerificationEmail(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 현재 로그인된 사용자가 있다면 로그아웃
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }

      // 이메일로 사용자 찾기
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) {
        throw '등록되지 않은 이메일입니다.';
      }

      // 임시 로그인하여 인증 메일 재발송
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: _tempPassword ?? '',
      );

      if (userCredential.user != null) {
        if (!userCredential.user!.emailVerified) {
          await userCredential.user!.sendEmailVerification();
        } else {
          throw '이미 인증된 이메일입니다.';
        }
      }

      // 재발송 후 로그아웃
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw '등록되지 않은 이메일입니다.';
        case 'wrong-password':
          throw '비밀번호가 변경되었습니다. 로그인 후 다시 시도해주세요.';
        case 'too-many-requests':
          throw '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
        case 'invalid-email':
          throw '유효하지 않은 이메일 형식입니다.';
        default:
          throw '인증 메일 재발송에 실패했습니다. (${e.code})';
      }
    } catch (e) {
      if (e is String) {
        throw e;
      }
      throw '인증 메일 재발송 중 오류가 발생했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 로그인 시도 횟수와 잠금 상태를 영구 저장하기 위한 메서드들
  Future<void> _saveLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loginAttempts', _loginAttempts);
    await prefs.setString(
        'lastLoginAttempt', _lastLoginAttempt?.toIso8601String() ?? '');
  }

  Future<void> _loadLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    _loginAttempts = prefs.getInt('loginAttempts') ?? 0;
    final lastAttemptStr = prefs.getString('lastLoginAttempt');
    _lastLoginAttempt = lastAttemptStr != null && lastAttemptStr.isNotEmpty
        ? DateTime.parse(lastAttemptStr)
        : null;
  }

  // 생성자에서 저장된 시도 횟수 로드
  AuthProvider() {
    _loadLoginAttempts();
  }
}
