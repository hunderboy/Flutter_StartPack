import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 로컬 알림 서비스 (flutter_local_notifications)
///
/// 사용 방법
///   main.dart        : await LocalNotificationService.instance.init();  (runApp 전 1회)
///   권한 요청        : await ref.read(localNotificationProvider).requestPermission();
///   즉시 알림        : ref.read(localNotificationProvider).show(title: '제목', body: '내용', payload: '/경로');
///   예약 알림        : ref.read(localNotificationProvider).schedule(title: ..., after: Duration(minutes: 10));
///
/// payload 에 GoRouter 경로('/...')를 넣으면 알림 탭 시 해당 화면으로 이동한다.
/// (이동 처리는 notification_tap_handler.dart)
final localNotificationProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService.instance;
});

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Android 8.0+ 알림 채널 (채널 id 는 한 번 만들면 설정 변경이 안 되므로 바꿀 땐 id 자체를 변경)
  static const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
    'default_channel',
    '기본 알림',
    description: '앱의 기본 알림 채널',
    importance: Importance.high,
  );

  static const NotificationDetails _defaultDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'default_channel',
      '기본 알림',
      channelDescription: '앱의 기본 알림 채널',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentSound: true,
      presentBadge: true,
    ),
  );

  /// 알림 탭 이벤트 (payload) : 앱이 실행 중일 때 탭한 경우
  final StreamController<String?> _tapController = StreamController<String?>.broadcast();
  Stream<String?> get onTap => _tapController.stream;

  /// 앱이 종료된 상태에서 알림을 탭해 실행된 경우의 payload (한 번 꺼내면 null)
  String? _launchPayload;
  String? consumeLaunchPayload() {
    final payload = _launchPayload;
    _launchPayload = null;
    return payload;
  }

  bool _initialized = false;
  int _nextId = 0;

  /// 초기화 : main() 에서 runApp 전에 1회 호출
  Future<void> init() async {
    if (_initialized) return;

    await _initTimezone();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // iOS 는 초기화 시점에 권한 팝업을 띄우지 않고, requestPermission() 에서 요청한다.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) => _tapController.add(response.payload),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);

    // 종료 상태에서 알림 탭으로 앱이 실행되었는지 확인
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _launchPayload = launchDetails!.notificationResponse?.payload;
    }

    _initialized = true;
  }

  /// 예약 알림을 위한 기기 시간대 설정
  Future<void> _initTimezone() async {
    tz.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ 시간대 조회 실패, UTC 사용 : $e');
    }
  }

  /// 알림 권한 요청 (Android 13+ / iOS). 허용 여부 반환
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }

    return false;
  }

  /// 즉시 알림. 생성된 알림 id 반환 (cancel 에 사용)
  Future<int> show({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    final notificationId = id ?? _generateId();
    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: _defaultDetails,
      payload: payload,
    );
    return notificationId;
  }

  /// 예약 알림 : [at] (특정 시각) 또는 [after] (지금부터 경과 시간) 중 하나 지정
  ///
  /// Android 는 정확한 알람 권한 없이 동작하는 inexact 모드를 사용한다. (수 분 오차 가능)
  /// 정확한 시각이 꼭 필요하면 SCHEDULE_EXACT_ALARM 권한 + AndroidScheduleMode.exactAllowWhileIdle 로 변경.
  Future<int> schedule({
    required String title,
    required String body,
    DateTime? at,
    Duration? after,
    String? payload,
    int? id,
  }) async {
    assert(at != null || after != null, 'at 또는 after 중 하나는 지정해야 합니다.');

    final scheduledDate = at != null
        ? tz.TZDateTime.from(at, tz.local)
        : tz.TZDateTime.now(tz.local).add(after!);

    final notificationId = id ?? _generateId();
    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _defaultDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
    return notificationId;
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();

  /// 알림 id : 32bit int 범위 내에서 겹치지 않게 생성
  int _generateId() {
    _nextId = (_nextId + 1) % 1000;
    return (DateTime.now().millisecondsSinceEpoch ~/ 1000 % 2000000) * 1000 + _nextId;
  }
}
