import 'package:flutter/material.dart';
import '../models/search_filter_model.dart';

class SearchFilterDialog extends StatefulWidget {
  final SearchFilter currentFilter;

  const SearchFilterDialog({
    Key? key,
    required this.currentFilter,
  }) : super(key: key);

  @override
  State<SearchFilterDialog> createState() => _SearchFilterDialogState();
}

class _SearchFilterDialogState extends State<SearchFilterDialog> {
  late SearchFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('검색 필터'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 날짜 범위
            ListTile(
              title: const Text('날짜 범위'),
              subtitle: Text(_filter.dateRange?.toString() ?? '날짜 선택'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _filter.dateRange,
                );
                if (dateRange != null) {
                  setState(() {
                    _filter = _filter.copyWith(dateRange: dateRange);
                  });
                }
              },
            ),
            const Divider(),

            // 최소 평점
            ListTile(
              title: const Text('최소 평점'),
              subtitle: Slider(
                value: _filter.minRating ?? 0,
                min: 0,
                max: 5,
                divisions: 10,
                label: (_filter.minRating ?? 0).toString(),
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(minRating: value);
                  });
                },
              ),
            ),
            const Divider(),

            // 사진 포함 여부
            SwitchListTile(
              title: const Text('사진 포함된 글만 보기'),
              value: _filter.includePhotosOnly,
              onChanged: (value) {
                setState(() {
                  _filter = _filter.copyWith(includePhotosOnly: value);
                });
              },
            ),
            const Divider(),

            // 정렬 기준
            ListTile(
              title: const Text('정렬 기준'),
              trailing: DropdownButton<String>(
                value: _filter.sortBy,
                items: const [
                  DropdownMenuItem(
                    value: 'createdAt',
                    child: Text('최신순'),
                  ),
                  DropdownMenuItem(
                    value: 'rating',
                    child: Text('평점순'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _filter = _filter.copyWith(sortBy: value);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _filter),
          child: const Text('적용'),
        ),
      ],
    );
  }
}
