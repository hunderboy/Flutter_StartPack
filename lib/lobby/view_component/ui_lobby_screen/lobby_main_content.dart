import 'package:flutter/material.dart';

import 'package:flutter_start_pack/lobby/view/home_tab.dart';
import 'package:flutter_start_pack/lobby/view/my_page_tab.dart';
import 'package:flutter_start_pack/lobby/view/search_tab.dart';

/// Lobby 화면의 본문 + BottomNavigationBar
/// IndexedStack 을 사용하여 탭 전환 시에도 각 탭의 상태(스크롤 위치 등)를 유지한다.
class LobbyMainContent extends StatelessWidget {
  final int lobbyPageIndex;
  final ValueChanged<int> onPageChanged;

  const LobbyMainContent({
    super.key,
    required this.lobbyPageIndex,
    required this.onPageChanged,
  });

  /// 탭 구성 : 탭을 추가/삭제할 때 이 목록만 수정하면 된다.
  static const List<_LobbyTab> _tabs = [
    _LobbyTab(label: '홈', icon: Icons.home_outlined, activeIcon: Icons.home_rounded, page: HomeTab()),
    _LobbyTab(label: '검색', icon: Icons.search_outlined, activeIcon: Icons.search_rounded, page: SearchTab()),
    _LobbyTab(label: '마이', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, page: MyPageTab()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: lobbyPageIndex,
        children: _tabs.map((tab) => tab.page).toList(),
      ),
      // 배경 / 선택 색상은 AppTheme.bottomNavigationBarTheme 에서 지정
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        currentIndex: lobbyPageIndex,
        onTap: onPageChanged,
        items: _tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}

class _LobbyTab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;

  const _LobbyTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });
}
