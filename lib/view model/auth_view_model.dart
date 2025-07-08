import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_models.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userData => _userModel;
  bool get isLoading => _isLoading;

  /// 🔄 Set loading and notify
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 🔐 REGISTER
  Future<void> registerWithDetails({
    required String email,
    required String password,
    required String userName,
    required String mobile,
    required String country,
    required BuildContext context,
  }) async {
    try {
      _setLoading(true);

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = credential.user;

      UserModel userModel = UserModel(
        uid: _user!.uid,
        email: email,
        userName: userName,
        mobile: mobile,
        country: country,
      );

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .set(userModel.toJson());

      await _saveFcmToken(_user!.uid);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', _user!.uid);

      _userModel = userModel;
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 🔓 LOGIN
  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      _setLoading(true);

      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = credential.user;

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(_user!.uid).get();

      if (!doc.exists) {
        throw Exception('User data not found');
      }

      _userModel = UserModel.fromJson(doc.data() as Map<String, dynamic>);

      await _saveFcmToken(_user!.uid);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', _user!.uid);

      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// 🔄 CHECK LOGIN STATUS
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString('uid');

    if (savedUid != null) {
      try {
        _user = _auth.currentUser;
        if (_user == null) return false;

        DocumentSnapshot doc =
            await _firestore.collection('users').doc(savedUid).get();
        if (!doc.exists) return false;

        _userModel = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners();
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint("Error in getUserByUid: $e");
      return null;
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    if (_user != null) {
      // Set FCM token to null instead of deleting the user or the token field
      await _firestore.collection('users').doc(_user!.uid).update({
        'fcmToken': null,
      });
    }

    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _user = null;
    _userModel = null;
    notifyListeners();
  }

  Future<void> _saveFcmToken(String uid) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(uid).update({'fcmToken': token});

      // ✅ Update locally if userData exists
      if (_userModel != null) {
        _userModel = UserModel(
          uid: _userModel!.uid,
          email: _userModel!.email,
          country: _userModel!.country,
          userName: _userModel!.userName,
          mobile: _userModel!.mobile,
          fcmToken: token,
        );
        notifyListeners();
      }
    }
  }
}
