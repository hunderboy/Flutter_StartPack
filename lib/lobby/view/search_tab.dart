import 'package:flutter/material.dart';

import 'package:flutter_start_pack/common/const/colors.dart';
import 'package:flutter_start_pack/common/layout/default_layout.dart';

/// 검색 탭 (예시 화면)
class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '검색',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColor.Background_Gray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('검색 결과가 여기에 표시됩니다.', style: TextStyle(color: AppColor.Grey_60)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
