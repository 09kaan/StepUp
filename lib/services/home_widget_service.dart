import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const _appGroupId = 'group.com.kaan.fitwalk';
  static const _iOSWidget = 'FitWalkWidget';
  static const _androidWidget = 'FitWalkWidgetProvider';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> update({required int steps, required int goal}) async {
    final progress = goal > 0 ? (steps / goal).clamp(0.0, 1.0) : 0.0;
    await HomeWidget.saveWidgetData<int>('steps', steps);
    await HomeWidget.saveWidgetData<int>('goal', goal);
    await HomeWidget.saveWidgetData<double>('progress', progress);
    
    await HomeWidget.updateWidget(
      iOSName: _iOSWidget,
      androidName: _androidWidget,
    );
  }
}
