import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import '../models/content_model.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;

  const HistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ContentModel> _history = [];
  bool _isLoading = true;
  final String _historyKey = 'user_history_';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final historyJson =
          prefs.getStringList(_historyKey + widget.userId) ?? [];

      setState(() {
        _history = historyJson
            .map((json) => ContentModel.fromJson(jsonDecode(json)))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('히스토리를 불러오는데 실패했습니다.')),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey + widget.userId);
      setState(() {
        _history.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('히스토리가 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('히스토리 삭제에 실패했습니다.')),
        );
      }
    }
  }

  Future<void> _removeFromHistory(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history
          .where((_, i) => i != index)
          .map((content) => jsonEncode(content.toJson()))
          .toList();
      await prefs.setStringList(_historyKey + widget.userId, historyJson);
      setState(() {
        _history.removeAt(index);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('히스토리 항목 삭제에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시청 기록'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('시청 기록 삭제'),
                    content: const Text('모든 시청 기록을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('삭제'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  _clearHistory();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Text('시청 기록이 없습니다.'),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final content = _history[index];
                      return Dismissible(
                        key: Key(content.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          _removeFromHistory(index);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: content.thumbnailUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      content.thumbnailUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.image),
                            title: Text(
                              content.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      content.type == 'video'
                                          ? Icons.play_circle_outline
                                          : Icons.article_outlined,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      content.type == 'video'
                                          ? '${content.duration}초'
                                          : '읽기',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              // TODO: Navigate to content detail screen
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
