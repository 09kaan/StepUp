import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/// Cihazın adım sensöründen canlı veri sağlar.
class StepService {
  /// Android'de "fiziksel aktivite" iznini ister.
  /// iOS'ta hareket izni ilk akışta sistem tarafından otomatik istenir.
  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  /// Cihaz açılışından beri kümülatif adım sayısı akışı.
  Stream<StepCount> get stepCountStream => Pedometer.stepCountStream;

  /// Yürüyor / duruyor durumu akışı.
  Stream<PedestrianStatus> get pedestrianStatusStream =>
      Pedometer.pedestrianStatusStream;
}
