import 'package:connectivity_plus/connectivity_plus.dart';

class InternetCheckService {
  final Connectivity _connectivity = Connectivity();

  // Internet connection ရှိမရှိစစ်မယ်
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        return false; // No internet
      }
      
      // WiFi/mobile data ရှိတယ်၊ but real internet ရှိမရှိထပ်စစ်မယ်
      return true;
    } catch (e) {
      return false; // Error occurred, assume no internet
    }
  }

  // Internet connection change ကိုနားထောင်မယ်
  Stream<bool> get onInternetStatusChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }
}