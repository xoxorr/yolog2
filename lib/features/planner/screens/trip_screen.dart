import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({Key? key}) : super(key: key);

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final TripService _tripService = TripService();
  final String _userId = 'current_user_id'; // Replace with actual user ID

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('여행 일정'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '예정된 여행'),
              Tab(text: '진행 중'),
              Tab(text: '완료된 여행'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddTripDialog(context),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildTripList(_tripService.getUpcomingTrips(_userId)),
            _buildTripList(_tripService.getOngoingTrips(_userId)),
            _buildTripList(_tripService.getCompletedTrips(_userId)),
          ],
        ),
      ),
    );
  }

  Widget _buildTripList(Stream<List<Trip>> tripsStream) {
    return StreamBuilder<List<Trip>>(
      stream: tripsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final trips = snapshot.data!;
        if (trips.isEmpty) {
          return const Center(child: Text('여행 일정이 없습니다.'));
        }

        return ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return _buildTripCard(trip);
          },
        );
      },
    );
  }

  Widget _buildTripCard(Trip trip) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    final duration = trip.getDuration();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _showTripDetails(context, trip),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      trip.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(trip),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                trip.destination,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$duration일',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (trip.participants.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.participants.length}명',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(Trip trip) {
    Color color;
    String label;

    if (trip.isUpcoming()) {
      color = Colors.blue;
      label = '예정';
    } else if (trip.isOngoing()) {
      color = Colors.green;
      label = '진행 중';
    } else {
      color = Colors.grey;
      label = '완료';
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _showAddTripDialog(BuildContext context) {
    // Implement add trip dialog
    // You can use a form to collect trip details
  }

  void _showTripDetails(BuildContext context, Trip trip) {
    // Implement trip details screen
    // Show full trip information and allow editing
  }
}
