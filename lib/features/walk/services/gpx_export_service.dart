import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/walk_session.dart';

class GpxExportService {
  static String buildGpx(WalkSession session) {
    final sb = StringBuffer();
    final title = session.displayTitle;
    final timeStr = session.startTime.toUtc().toIso8601String();

    sb.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sb.writeln(
        '<gpx version="1.1" creator="FitWalk - StepUp" '
        'xmlns="http://www.topografix.com/GPX/1/1" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
        'http://www.topografix.com/GPX/1/1/gpx.xsd">');

    sb.writeln('  <metadata>');
    sb.writeln('    <name>$title</name>');
    sb.writeln('    <time>$timeStr</time>');
    sb.writeln('  </metadata>');

    sb.writeln('  <trk>');
    sb.writeln('    <name>$title</name>');
    sb.writeln('    <type>Walking</type>');
    sb.writeln('    <trkseg>');

    for (final p in session.points) {
      final pTime = (p.time ?? session.startTime).toUtc().toIso8601String();
      sb.writeln('      <trkpt lat="${p.lat}" lon="${p.lng}">');
      sb.writeln('        <ele>${p.altitude.toStringAsFixed(1)}</ele>');
      sb.writeln('        <time>$pTime</time>');
      sb.writeln('      </trkpt>');
    }

    sb.writeln('    </trkseg>');
    sb.writeln('  </trk>');
    sb.writeln('</gpx>');

    return sb.toString();
  }

  static Future<void> exportAndShare(WalkSession session) async {
    final gpxContent = buildGpx(session);
    final tempDir = await getTemporaryDirectory();

    final safeTitle = (session.title ?? session.displayTitle)
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');

    final fileName = 'FitWalk_${safeTitle}_${session.id}.gpx';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(gpxContent);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '${session.displayTitle} GPX',
      text: '${session.displayTitle} - FitWalk GPS Rotası (.gpx)',
    );
  }
}
