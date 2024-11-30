import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/search_service.dart';
import '../models/search_filter_model.dart';
import '../widgets/search_filter_dialog.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  final List<DocumentSnapshot> initialResults;

  const SearchResultsScreen({
    Key? key,
    required this.query,
    required this.initialResults,
  }) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late List<DocumentSnapshot> _results;
  final SearchService _searchService = SearchService();
  SearchFilter _filter = SearchFilter.empty();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _results = widget.initialResults;
  }

  Future<void> _applyFilter(SearchFilter newFilter) async {
    setState(() {
      _isLoading = true;
      _filter = newFilter;
    });

    try {
      final results = await _searchService.searchContent(
        query: widget.query,
        filter: _filter,
      );

      if (mounted) {
        setState(() {
          _results = results;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('필터 적용 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색 결과: ${widget.query}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final newFilter = await showDialog<SearchFilter>(
                context: context,
                builder: (context) => SearchFilterDialog(
                  currentFilter: _filter,
                ),
              );

              if (newFilter != null) {
                _applyFilter(newFilter);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? const Center(child: Text('검색 결과가 없습니다.'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final data = _results[index].data() as Map<String, dynamic>;
                    return SearchResultCard(data: data);
                  },
                ),
    );
  }
}

class SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const SearchResultCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(data['title'] ?? '제목 없음'),
        subtitle: Text(data['content'] ?? '내용 없음'),
        onTap: () {
          // TODO: 상세 페이지로 이동
        },
      ),
    );
  }
}
