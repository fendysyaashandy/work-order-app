import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:work_order_app/core/widget/app_state_page.dart';

class LocationPicker extends StatefulWidget {
  final int? workOrderId;
  final Function(double, double) onLocationSelected;
  final bool isStatic;
  final bool isReadOnly;
  final double? longitude;
  final double? latitude;

  const LocationPicker({
    super.key,
    this.workOrderId,
    required this.onLocationSelected,
    required this.isStatic,
    this.isReadOnly = false,
    this.longitude,
    this.latitude,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends AppStatePage<LocationPicker> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(-7.250445, 112.768845);
  String locationInfo = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = (widget.latitude != null && widget.longitude != null)
        ? LatLng(widget.latitude!, widget.longitude!)
        : const LatLng(-7.250445, 112.768845);

    if (widget.latitude != null && widget.longitude != null) {
      locationInfo = "Lokasi dipilih";
    }
  }

  void _moveCamera(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14.0),
      ),
    );
  }

  /// Saat pengguna mengetuk peta.
  void _onTapped(LatLng position) {
    if (!widget.isStatic || widget.isReadOnly)
      return; // Jika dinamis, tidak perlu memilih lokasi
    setState(() {
      locationInfo = "Lokasi dipilih";
      _selectedLocation = position;
      _moveCamera(position);
    });
    widget.onLocationSelected(position.latitude, position.longitude);
  }

  @override
  Widget buildPage(BuildContext context) {
    // Jika locationTypeId adalah "dinamis", maka tidak perlu memilih lokasi
    if (!widget.isStatic) {
      // Misalkan ID 2 untuk Dinamis
      return const SizedBox();
    }
    return Column(
      children: [
        // Peta untuk memilih lokasi.
        SizedBox(
          height: 165,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation, // Default ke Surabaya
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _moveCamera(_selectedLocation);
            },
            onTap: widget.isReadOnly ? null : _onTapped,
            markers: {
              Marker(
                markerId: const MarkerId("selected"),
                position: _selectedLocation,
              ),
            },
          ),
        ),
        // Informasi lokasi dan pencarian.
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tampilan informasi lokasi.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      locationInfo,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            locationInfo.isNotEmpty
                                ? _selectedLocation.longitude.toString()
                                : "",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locationInfo.isNotEmpty
                                ? _selectedLocation.latitude.toString()
                                : "",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Field pencarian lokasi menggunakan Google Places Autocomplete.
              (widget.isReadOnly)
                  ? const SizedBox()
                  : GooglePlaceAutoCompleteTextField(
                      textEditingController: _searchController,
                      googleAPIKey: googleApiKey,
                      inputDecoration: InputDecoration(
                        hintText: "Cari Lokasi",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      debounceTime: 800,
                      countries: ["id"], // Membatasi pencarian di Indonesia
                      isLatLngRequired: true,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
