import 'package:flutter/material.dart';
import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';

class BookmarkScreen extends StatefulWidget {
  final String userId;

  const BookmarkScreen({
    super.key,
    required this.userId,
  });

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  List<BookmarkModel> _bookmarks = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bookmarks = await _bookmarkService.getUserBookmarks(widget.userId);
      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '북마크를 불러오는데 실패했습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchBookmarks(String query) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final bookmarks = await _bookmarkService.searchBookmarks(
        widget.userId,
        query,
      );
      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '북마크 검색에 실패했습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(String bookmarkId) async {
    try {
      await _bookmarkService.removeBookmark(bookmarkId);
      setState(() {
        _bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('북마크가 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('북마크 삭제에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('북마크'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '북마크 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadBookmarks();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchBookmarks(value);
                } else {
                  _loadBookmarks();
                }
              },
            ),
          ),
          Expanded(
            child: _buildBookmarkList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookmarks,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_bookmarks.isEmpty) {
      return const Center(
        child: Text('북마크가 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookmarks,
      child: ListView.builder(
        itemCount: _bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = _bookmarks[index];
          final content = bookmark.content;
          return Dismissible(
            key: Key(bookmark.id),
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
              _removeBookmark(bookmark.id);
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    if (bookmark.note != null && bookmark.note!.isNotEmpty) ...[
                      Text(
                        bookmark.note!,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      content.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: content.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
                onTap: () {
                  // TODO: Navigate to content detail screen
                },
                onLongPress: () async {
                  // 북마크 메모 편집
                  final note = await showDialog<String>(
                    context: context,
                    builder: (context) => _EditNoteDialog(
                      initialNote: bookmark.note ?? '',
                    ),
                  );

                  if (note != null) {
                    try {
                      final updatedBookmark = await _bookmarkService
                          .updateBookmarkNote(bookmark.id, note);
                      setState(() {
                        final index = _bookmarks
                            .indexWhere((b) => b.id == updatedBookmark.id);
                        if (index != -1) {
                          _bookmarks[index] = updatedBookmark;
                        }
                      });
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('메모 업데이트에 실패했습니다.')),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EditNoteDialog extends StatefulWidget {
  final String initialNote;

  const _EditNoteDialog({
    required this.initialNote,
  });

  @override
  State<_EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<_EditNoteDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('북마크 메모 편집'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: '메모를 입력하세요',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('저장'),
        ),
      ],
    );
  }
}
