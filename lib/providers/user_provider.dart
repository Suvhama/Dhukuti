import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhukuti/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  bool get isAdmin => _userModel?.isAdmin ?? false;
  bool get isLoading => _userModel == null && _errorMessage == null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _fetchUserDetails(user);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserDetails(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!, user.uid);
      } else {
        // Create new user doc if doesn't exist
        final newUser = UserModel(
          uid: user.uid,
          phone: user.phoneNumber ?? '',
          createdAt: DateTime.now(),
          isAdmin: user.phoneNumber == '+9779813629126', // Admin Check
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(newUser.toMap());
        _userModel = newUser;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({String? name, String? address, String? email}) async {
    if (_userModel == null) return;
    
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (address != null) updates['address'] = address;
      if (email != null) updates['email'] = email;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userModel!.uid)
          .update(updates);
      
      // Refresh local model
      _userModel = UserModel(
        uid: _userModel!.uid,
        phone: _userModel!.phone,
        name: name ?? _userModel!.name,
        address: address ?? _userModel!.address,
        email: email ?? _userModel!.email,
        photoUrl: _userModel!.photoUrl,
        isAdmin: _userModel!.isAdmin,
        createdAt: _userModel!.createdAt,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating profile: $e");
      rethrow;
    }
  }
}
