import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_start_pack/common/const/colors.dart';
import 'package:flutter_start_pack/common/layout/default_layout.dart';
import 'package:flutter_start_pack/user/model/user_model.dart';
import 'package:flutter_start_pack/user/provider/user_me_provider.dart';

/// 마이 탭 : 로그인 유저 정보 + 로그아웃
class MyPageTab extends ConsumerWidget {
  const MyPageTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userMeProvider);

    return DefaultLayout(
      title: '마이',
      body: ListView(
        children: [
          if (user is UserModel)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: const CircleAvatar(
                radius: 26,
                backgroundColor: AppColor.Background_Gray,
                child: Icon(Icons.person_rounded, color: AppColor.Grey_60),
              ),
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${user.email} · ${user.loginType.name}'),
            ),
          const Divider(height: 1, color: AppColor.Grey_10),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: const Icon(Icons.logout_rounded, color: AppColor.Primary_Red),
            title: const Text('로그아웃', style: TextStyle(color: AppColor.Primary_Red)),
            // 상태만 null 로 변경하면 RouterGuardProvider 가 로그인 화면으로 이동시킨다.
            onTap: () => ref.read(userMeProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
