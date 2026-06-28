import 'package:isar/isar.dart';

part 'walk_session.g.dart';

@collection
class WalkSession {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime startTime;

  DateTime? endTime;

  double distanceMeters = 0;

  List<RoutePoint> points = [];

  @ignore
  int get durationSeconds =>
      endTime == null ? 0 : endTime!.difference(startTime).inSeconds;
}

@embedded
class RoutePoint {
  double lat = 0;
  double lng = 0;
  DateTime? time;

  RoutePoint();

  RoutePoint.of(this.lat, this.lng, this.time);
}
