import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:project/utils/app_colors.dart';
import 'package:project/screens/home/pages/wilaya_chat_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  // Algeria center coordinates
  static const LatLng algeriaCenter = LatLng(28.0339, 1.6596);

  // Selected place data
  Map<String, dynamic>? _selectedPlace;

  // List of all 58 wilayas in Algeria
  List<Map<String, dynamic>> get _wilayas => [
    {'name': 'Adrar', 'lat': 27.8747, 'lng': -0.2933},
    {'name': 'Chlef', 'lat': 36.1650, 'lng': 1.3317},
    {'name': 'Laghouat', 'lat': 33.8060, 'lng': 2.8650},
    {'name': 'Oum El Bouaghi', 'lat': 35.8786, 'lng': 7.1100},
    {'name': 'Batna', 'lat': 35.5555, 'lng': 6.1744},
    {'name': 'Béjaïa', 'lat': 36.7500, 'lng': 5.0667},
    {'name': 'Biskra', 'lat': 34.8500, 'lng': 5.7333},
    {'name': 'Béchar', 'lat': 31.6333, 'lng': -2.2000},
    {'name': 'Blida', 'lat': 36.4700, 'lng': 2.8300},
    {'name': 'Bouira', 'lat': 36.3764, 'lng': 3.9014},
    {'name': 'Tamanrasset', 'lat': 22.7850, 'lng': 5.5228},
    {'name': 'Tébessa', 'lat': 35.4042, 'lng': 8.1242},
    {'name': 'Tlemcen', 'lat': 34.8828, 'lng': -1.3167},
    {'name': 'Tiaret', 'lat': 35.3711, 'lng': 1.3189},
    {'name': 'Tizi Ouzou', 'lat': 36.7167, 'lng': 4.0500},
    {'name': 'Algiers', 'lat': 36.7538, 'lng': 3.0588},
    {'name': 'Djelfa', 'lat': 34.6714, 'lng': 3.2633},
    {'name': 'Jijel', 'lat': 36.8206, 'lng': 5.7667},
    {'name': 'Sétif', 'lat': 36.1900, 'lng': 5.4100},
    {'name': 'Saïda', 'lat': 34.8300, 'lng': 0.1450},
    {'name': 'Skikda', 'lat': 36.8667, 'lng': 6.9000},
    {'name': 'Sidi Bel Abbès', 'lat': 35.1939, 'lng': -0.6414},
    {'name': 'Annaba', 'lat': 36.9000, 'lng': 7.7667},
    {'name': 'Guelma', 'lat': 36.4619, 'lng': 7.4258},
    {'name': 'Constantine', 'lat': 36.3650, 'lng': 6.6147},
    {'name': 'Médéa', 'lat': 36.2650, 'lng': 2.7533},
    {'name': 'Mostaganem', 'lat': 35.9333, 'lng': 0.0833},
    {'name': "M'Sila", 'lat': 35.7056, 'lng': 4.5419},
    {'name': 'Mascara', 'lat': 35.3983, 'lng': 0.1417},
    {'name': 'Ouargla', 'lat': 31.9500, 'lng': 5.3167},
    {'name': 'Oran', 'lat': 35.6970, 'lng': -0.6350},
    {'name': 'El Bayadh', 'lat': 33.6833, 'lng': 1.0167},
    {'name': 'Illizi', 'lat': 26.4833, 'lng': 8.4667},
    {'name': 'Bordj Bou Arréridj', 'lat': 36.0731, 'lng': 4.7608},
    {'name': 'Boumerdès', 'lat': 36.7667, 'lng': 3.4667},
    {'name': 'El Tarf', 'lat': 36.7667, 'lng': 8.3167},
    {'name': 'Tindouf', 'lat': 27.6750, 'lng': -8.1478},
    {'name': 'Tissemsilt', 'lat': 35.6067, 'lng': 1.8106},
    {'name': 'El Oued', 'lat': 33.3564, 'lng': 6.8633},
    {'name': 'Khenchela', 'lat': 35.4292, 'lng': 7.1453},
    {'name': 'Souk Ahras', 'lat': 36.2833, 'lng': 7.9500},
    {'name': 'Tipaza', 'lat': 36.5950, 'lng': 2.4444},
    {'name': 'Mila', 'lat': 36.4500, 'lng': 6.2614},
    {'name': 'Aïn Defla', 'lat': 36.2650, 'lng': 1.9667},
    {'name': 'Naâma', 'lat': 33.2667, 'lng': -0.3167},
    {'name': 'Aïn Témouchent', 'lat': 35.3069, 'lng': -1.1400},
    {'name': 'Ghardaïa', 'lat': 32.4900, 'lng': 3.6736},
    {'name': 'Relizane', 'lat': 35.7367, 'lng': 0.5592},
    {'name': 'Timimoun', 'lat': 29.2600, 'lng': 0.2311},
    {'name': 'Bordj Badji Mokhtar', 'lat': 21.3333, 'lng': 0.9500},
    {'name': 'Ouled Djellal', 'lat': 34.4167, 'lng': 5.0667},
    {'name': 'Béni Abbès', 'lat': 30.1333, 'lng': -2.1667},
    {'name': 'In Salah', 'lat': 27.1983, 'lng': 2.4606},
    {'name': 'In Guezzam', 'lat': 19.5667, 'lng': 5.7833},
    {'name': 'Touggourt', 'lat': 33.1000, 'lng': 6.0667},
    {'name': 'Djanet', 'lat': 24.5500, 'lng': 9.4833},
    {'name': 'El M\'Ghair', 'lat': 33.9500, 'lng': 5.9333},
    {'name': 'El Meniaa', 'lat': 30.5833, 'lng': 2.8833},
  ];

  @override
  void initState() {
    super.initState();
    // Set initial view to Algeria after map is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(algeriaCenter, 6.0);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: algeriaCenter,
              initialZoom: 6.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                // On map tap, clear selection
                setState(() {
                  _selectedPlace = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.project',
              ),
              MarkerLayer(
                markers: _wilayas.map((wilaya) {
                  return Marker(
                    point: LatLng(wilaya['lat']!, wilaya['lng']!),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlace = {
                            'title': wilaya['name'],
                            'address': '${wilaya['name']}, Algeria',
                            'rating': 4.5,
                            'reviews': 120,
                            'tags': ['Wilaya', 'Algeria'],
                            'image': 'images/OIP.jpg',
                          };
                        });
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF194CBF),
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top search bar and settings
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by name, city...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Settings functionality
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Settings')));
                    },
                    icon: const Icon(Icons.tune, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),

          // Bottom sheet card
          if (_selectedPlace != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomCard(_selectedPlace!),
            ),

          // Location and List buttons on map
          Positioned(
            bottom: _selectedPlace != null ? 180 : 80,
            right: 16,
            child: Column(
              children: [
                // Current location button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      _mapController.move(algeriaCenter, 6.0);
                    },
                    icon: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                // List view button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.list, size: 18, color: AppColors.textPrimary),
                      SizedBox(width: 4),
                      Text(
                        'List',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard(Map<String, dynamic> place) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    place['image'] ?? 'images/OIP.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: AppColors.grey100,
                        child: const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place['title'] ?? 'Location',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place['address'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < (place['rating'] ?? 0).floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${place['rating']} (${place['reviews']})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (place['tags'] as List<dynamic>?)
                                ?.map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      tag.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList() ??
                            [],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // View Details button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to details page
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('View details for ${place['title']}'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Join Chat button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WilayaChatPage(
                            wilayaName: place['title'] ?? '',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF194CBF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Join Chat',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
