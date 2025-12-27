import 'dart:async';

import 'package:flutter/services.dart';

import '../../config/app_logger.dart';
import '../constants/app_const.dart';
import '../translations/translations.dart';
import 'navigation.dart';

class NotificationService {
  // flutter_local_notifications and timezone packages removed due to compilation issues
  // TODO: Replace with an alternative notification service when needed
  
  static const MethodChannel _methodChannel =
      MethodChannel(AppStringConst.notificationMethodChannel);

  static Future<void> initialize({bool initSchedule = false}) async {
    // Placeholder: notification initialization disabled
    logger.i("NotificationService.initialize() - disabled (packages removed)");
  }

  static Future<void> _configureLocalTimeZone() async {
    // Placeholder: timezone configuration disabled
  }

  static get _notificationDetails => null;

  static Future showNotification({
    int id = 0,
    required String title,
    required String body,
    required dynamic payload,
  }) async {
    // Placeholder: notifications disabled
    logger.i("showNotification() disabled - title: $title, body: $body");
  }

  static Future showScheduleNotification({
    int id = 0,
    required String title,
    required String body,
    required dynamic payload,
    required DateTime scheduleDate,
  }) async {
    // Placeholder: scheduled notifications disabled
    logger.i("showScheduleNotification() disabled - title: $title");
  }

  static Future<void> cancelNotification({int id = 0}) async {
    logger.i("cancelNotification() disabled");
    Navigators().showMessage(
      LocaleKeys.setting_cancel_all_noti.tr(),
      type: MessageType.success,
    );
    // Notification cancellation disabled (packages removed)
  }
}
