import 'package:isar/isar.dart';

part 'walk_session.g.dart';

@collection
class WalkSession {
  Id id = Isar.autoIncrement;

  String? title;

  @Index()
  late DateTime startTime;

  DateTime? endTime;

  double distanceMeters = 0;

  double elevationGainMeters = 0;

  double avgGradePercent = 0;

  double maxAltitude = 0;

  List<RoutePoint> points = [];

  @ignore
  int get durationSeconds =>
      endTime == null ? 0 : endTime!.difference(startTime).inSeconds;

  @ignore
  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) return title!;
    final h = startTime.hour;
    if (h >= 5 && h < 11) return 'Sabah Yürüyüşü';
    if (h >= 11 && h < 16) return 'Öğle Yürüyüşü';
    if (h >= 16 && h < 21) return 'Akşam Yürüyüşü';
    return 'Gece Yürüyüşü';
  }

  @ignore
  String get paceFormatted {
    if (distanceMeters <= 0 || durationSeconds <= 0) return '-';
    final paceSecPerKm = (durationSeconds / (distanceMeters / 1000)).round();
    final m = paceSecPerKm ~/ 60;
    final s = paceSecPerKm % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"/km";
  }

  @ignore
  double get caloriesEstimated {
    final km = distanceMeters / 1000;
    return (km * 55) + (elevationGainMeters * 0.1);
  }
}

@embedded
class RoutePoint {
  double lat = 0;
  double lng = 0;
  double altitude = 0;
  double altitudeAccuracy = 0;
  DateTime? time;

  RoutePoint();

  RoutePoint.of(
    this.lat,
    this.lng,
    this.time, [
    this.altitude = 0,
    this.altitudeAccuracy = 0,
  ]);
}
