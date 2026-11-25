import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_start_pack/common/dio/sample/sample_repository.dart';
import 'package:flutter_start_pack/common/layout/default_layout.dart';
import 'package:flutter_start_pack/common/theme/app_colors.dart';

/// 홈 탭
/// Dio + Retrofit + JsonSerializable 동작 확인용으로 샘플 API 목록을 보여준다.
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(samplePostsProvider);

    return DefaultLayout(
      title: '홈',
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(samplePostsProvider.future),
        child: posts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            children: [
              const SizedBox(height: 120),
              Icon(Icons.wifi_off_rounded, size: 48, color: context.colors.iconSubtle),
              const SizedBox(height: 12),
              const Center(child: Text('데이터를 불러오지 못했습니다.')),
              Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(samplePostsProvider),
                  child: const Text('다시 시도'),
                ),
              ),
            ],
          ),
          data: (items) => ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colors.surfaceSubtle,
                  child: Text('${item.id}', style: const TextStyle(fontSize: 12)),
                ),
                title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(item.content, maxLines: 2, overflow: TextOverflow.ellipsis),
              );
            },
          ),
        ),
      ),
    );
  }
}
