import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_start_pack/lobby/view_component/ui_lobby_screen/lobby_main_content.dart';

/// 로그인 후 가장 먼저 진입하는 메인 화면 (BottomNavigationBar 포함)
class LobbyScreen extends ConsumerStatefulWidget {
  static String get routeName => 'lobby';

  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  /// BottomNavigationBar 선택 인덱스
  int lobbyPageIndex = 0;

  void _onPageChanged(int index) {
    FocusScope.of(context).unfocus(); // 탭 이동 시 키보드 숨기기
    setState(() => lobbyPageIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LobbyMainContent(
      lobbyPageIndex: lobbyPageIndex,
      onPageChanged: _onPageChanged,
    );
  }
}
