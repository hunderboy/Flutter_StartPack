// ignore_for_file: constant_identifier_names
import 'dart:io';

/// Secure Storage Key
const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

/// 로컬 서버 ip 주소 (localhost 테스트 용)
const emulatorIp = '10.0.2.2:3000';  // Android Emulator
const simulatorIp = '127.0.0.1:3000'; // iOS Simulator

/// 현재 내 ip 주소 (로컬 서버 돌릴 때 사용)
final ip = Platform.isIOS ? simulatorIp : emulatorIp;

/// 서버 주소
/// 기본 빌드      : flutter run
/// 서버 주소 주입 : flutter run --dart-define=SERVER_URL=https://api.example.com
const serverIP = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: 'https://api.example.com', // TODO: 실제 서버 주소로 변경
);

/// 샘플 API 주소 (Retrofit 동작 확인용 Fake REST API)
const sampleServerIP = 'https://jsonplaceholder.typicode.com';

/// Splash 화면 노출 시간
const splashDuration = Duration(seconds: 3);
