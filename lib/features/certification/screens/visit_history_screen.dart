import 'package:flutter/material.dart';
import '../models/visit_model.dart';
import '../services/visit_service.dart';

class VisitHistoryScreen extends StatefulWidget {
  final String userId;

  const VisitHistoryScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  late VisitService _visitService;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _visitStats;

  @override
  void initState() {
    super.initState();
    _visitService = VisitService(userId: widget.userId);
    _loadVisitStats();
  }

  Future<void> _loadVisitStats() async {
    final stats = await _visitService.getVisitStats(
      startDate: _startDate,
      endDate: _endDate,
    );
    setState(() {
      _visitStats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방문 기록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_visitStats != null) _buildStatsHeader(),
          Expanded(
            child: _buildVisitList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '총 방문',
            _visitStats!['totalVisits'].toString(),
            Icons.place,
          ),
          _buildStatItem(
            '방문 장소',
            _visitStats!['uniquePlaces'].toString(),
            Icons.location_city,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildVisitList() {
    return FutureBuilder<List<Visit>>(
      future: _visitService.getVisits(
        startDate: _startDate,
        endDate: _endDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final visits = snapshot.data ?? [];
        if (visits.isEmpty) {
          return const Center(
            child: Text('방문 기록이 없습니다.'),
          );
        }

        return ListView.builder(
          itemCount: visits.length,
          itemBuilder: (context, index) {
            final visit = visits[index];
            return _buildVisitCard(visit);
          },
        );
      },
    );
  }

  Widget _buildVisitCard(Visit visit) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showVisitDetails(visit),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.place,
                    color: visit.isVerified ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      visit.placeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (visit.isVerified)
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '방문일: ${_formatDate(visit.visitedAt)}',
                style: const TextStyle(color: Colors.grey),
              ),
              if (visit.note != null) ...[
                const SizedBox(height: 8),
                Text(visit.note!),
              ],
              if (visit.photos.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: visit.photos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            visit.photos[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error_outline);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showVisitDetails(Visit visit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    visit.placeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem('방문일', _formatDate(visit.visitedAt)),
                  _buildDetailItem('인증 상태', visit.isVerified ? '인증됨' : '미인증'),
                  _buildDetailItem('인증 방법', visit.verificationType),
                  if (visit.note != null) _buildDetailItem('메모', visit.note!),
                  const SizedBox(height: 16),
                  if (visit.photos.isNotEmpty) ...[
                    const Text(
                      '사진',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: visit.photos.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showFullScreenImage(
                            context,
                            visit.photos[index],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              visit.photos[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error_outline);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Container(
            color: Colors.black,
            child: Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error_outline);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, DateTime?>>(
      context: context,
      builder: (context) {
        DateTime? tempStartDate = _startDate;
        DateTime? tempEndDate = _endDate;

        return AlertDialog(
          title: const Text('기간 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('시작일'),
                subtitle: Text(tempStartDate != null
                    ? _formatDate(tempStartDate)
                    : '선택하세요'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempStartDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    tempStartDate = date;
                  }
                },
              ),
              ListTile(
                title: const Text('종료일'),
                subtitle: Text(
                    tempEndDate != null ? _formatDate(tempEndDate) : '선택하세요'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempEndDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    tempEndDate = date;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'startDate': tempStartDate,
                  'endDate': tempEndDate,
                });
              },
              child: const Text('적용'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _startDate = result['startDate'];
        _endDate = result['endDate'];
      });
      _loadVisitStats();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
