// lib/services/local_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/purchase_item.dart';
import 'dart:developer' as developer;

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1. 初始化通知设置
  Future<void> initialize() async {
    // Android 初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 初始化设置 (不需要特定的权限请求，但需要描述)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Windows 初始化设置
    // 假设您不需要自定义图标，默认使用应用图标

    // 综合初始化设置
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // 当应用在前台时点击通知的回调
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
            // TODO: 这里可以处理通知点击事件，例如跳转到 CalendarScreen
          },
    );
  }

  // 2. 排程通知方法
  Future<void> scheduleNotification({required PurchaseItem item}) async {
    // 确保时区已初始化且时间已转换
    final location = tz.local;
    final scheduledDate = tz.TZDateTime.from(item.notifyDate, location);

    // 定义通知详情
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'cooldown_channel_id', // 必须是唯一的
          '冷静期提醒',
          channelDescription: '冷静期到期提醒，提醒您决定是否购买。',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          // TODO: 可以在这里添加 Action Buttons (如 '已购买', '放弃')
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
      // Windows 平台默认使用通用细节
    );

    // 排程通知
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      item.id.hashCode, // 使用 Item ID 的哈希值作为通知 ID
      '冷静期到期：${item.name}',
      '价格: ${item.price ?? '未定'}。点击查看详情或决定是否购买。',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // 确保在 Doze 模式下尽量准确
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

    developer.debugger(message: '🕒 本地通知已排程: ${item.name} at $scheduledDate');
  }
}
