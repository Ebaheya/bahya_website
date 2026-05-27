import 'package:flutter/foundation.dart';

class AuthNotifier extends ChangeNotifier {
  bool isLoggedIn = true;

  Future<void> forceLogout() async {
    isLoggedIn = false;
    notifyListeners();
  }
}

final authNotifier = AuthNotifier();
