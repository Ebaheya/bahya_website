import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnectionService {
  InternetConnectionService._();

  static final InternetConnectionService instance =
      InternetConnectionService._();

  Future<bool> hasInternet() async {
    final results = await Connectivity().checkConnectivity();

    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn);
  }
}
