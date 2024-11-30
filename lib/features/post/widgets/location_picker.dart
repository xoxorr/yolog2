import 'package:flutter/material.dart';
import '../models/location_model.dart';

class LocationPicker extends StatelessWidget {
  final LocationModel? selectedLocation;
  final Function(LocationModel?) onLocationSelected;

  const LocationPicker({
    Key? key,
    this.selectedLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('위치', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      // TODO: 위치 선택 구현
                      // 임시로 더미 데이터 추가
                      final location = LocationModel(
                        id: DateTime.now().toString(),
                        name: '서울시 강남구',
                        latitude: 37.5665,
                        longitude: 126.9780,
                      );
                      onLocationSelected(location);
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('위치 선택'),
                  ),
                  if (selectedLocation != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onLocationSelected(null),
                    ),
                  ],
                ],
              ),
              if (selectedLocation != null) ...[
                const SizedBox(height: 8),
                Text(selectedLocation!.name),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
