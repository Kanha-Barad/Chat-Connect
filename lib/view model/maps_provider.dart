import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/colors.dart';

// class MapsProvider with ChangeNotifier {
//   final Location _locationController = Location();

//   GoogleMapController? _mapController;
//   LatLng? _currentLocation;
//   MapType _currentMapType = MapType.normal;
//   StreamSubscription<LocationData>? _locationSubscription;

//   bool _isLoading = false;

//   Set<Marker> _markersSet = {};
//   Set<Marker> get markers => _markersSet;

//   Map<MarkerId, Marker> _markersMap = {};
//   Map<MarkerId, Marker> get getMarkersMap => _markersMap;

//   final List<IconData> mapTypeIcons = [
//     Icons.map,
//     Icons.satellite,
//     Icons.terrain,
//     Icons.layers,
//   ];

//   final List<MapType> mapTypes = [
//     MapType.normal,
//     MapType.satellite,
//     MapType.terrain,
//     MapType.hybrid,
//   ];

//   final LatLng defaultIndiaLocation = const LatLng(20.5937, 78.9629);

//   Polygon? rectanglePolygon;

//   LatLng? get currentLocation => _currentLocation;
//   MapType get currentMapType => _currentMapType;
//   GoogleMapController? get mapController => _mapController;
//   bool get isLoading => _isLoading;

//   // 📍 Initialize map and location
//   Future<void> initialize() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final bool hasPermission = await requestLocationPermissions();
//       if (!hasPermission) {
//         await openAppSettings();
//         return;
//       }

//       await _getLocationUpdates(); // Get user location
//       await centerToCurrentLocation(zoom: 14); // Adjust zoom
//     } catch (e) {
//       print("❌ Error initializing location: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ✅ Request permissions
//   Future<bool> requestLocationPermissions() async {
//     final status = await Permission.location.request();

//     if (status.isGranted) {
//       final backgroundStatus = await Permission.locationAlways.request();
//       return backgroundStatus.isGranted;
//     }
//     return false;
//   }

//   void onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//   }

//   void changeMapType(int index) {
//     _currentMapType = mapTypes[index];
//     notifyListeners();
//   }

//   // ✅ Get device location
//   Future<void> _getLocationUpdates() async {
//     bool serviceEnabled = await _locationController.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _locationController.requestService();
//       if (!serviceEnabled) return;
//     }

//     final location = await _locationController.getLocation();
//     _updateCurrentUserLocationInMap(
//       LatLng(location.latitude!, location.longitude!),
//     );
//   }

//   // ✅ Update and draw 2km rectangle
//   void _updateCurrentUserLocationInMap(LatLng location) {
//     _currentLocation = location;
//     rectanglePolygon = create2kmRectangle(location);
//     notifyListeners();
//   }

//   // ✅ Create 2km rectangle polygon
//   Polygon create2kmRectangle(LatLng center) {
//     const double earthRadius = 6378137.0;

//     // 1km offset to make a 2km x 2km square
//     double latOffset = (1000.0 / earthRadius) * (180 / pi);
//     double lngOffset =
//         (1000.0 / (earthRadius * cos(pi * center.latitude / 180))) * (180 / pi);

//     final LatLng northWest =
//         LatLng(center.latitude + latOffset, center.longitude - lngOffset);
//     final LatLng northEast =
//         LatLng(center.latitude + latOffset, center.longitude + lngOffset);
//     final LatLng southEast =
//         LatLng(center.latitude - latOffset, center.longitude + lngOffset);
//     final LatLng southWest =
//         LatLng(center.latitude - latOffset, center.longitude - lngOffset);

//     return Polygon(
//       polygonId: const PolygonId('2km_rectangle'),
//       points: [northWest, northEast, southEast, southWest, northWest],
//       strokeColor: primaryColor,
//       fillColor: primaryColor.withOpacity(0.2),
//       strokeWidth: 2,
//     );
//   }

//   // ✅ Animate camera to center and zoom level
//   Future<void> centerToCurrentLocation({double zoom = 14}) async {
//     if (_currentLocation != null && _mapController != null) {
//       await _mapController!.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(target: _currentLocation!, zoom: zoom),
//         ),
//       );
//     }
//   }

//   void stopTracking() {
//     _locationSubscription?.cancel();
//     _locationSubscription = null;
//     debugPrint("📴 Location tracking stopped");
//   }

//   @override
//   void dispose() {
//     _mapController?.dispose(); // Safe null check
//     _markersSet.clear();
//     _markersMap.clear();
//     stopTracking();
//     super.dispose();
//   }
// }

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class MapsProvider with ChangeNotifier {
  final Location _locationController = Location();

  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  MapType _currentMapType = MapType.normal;
  StreamSubscription<LocationData>? _locationSubscription;

  bool _isLoading = false;
  bool _isWeb = false;

  Set<Marker> _markersSet = {};
  Set<Marker> get markers => _markersSet;

  Map<MarkerId, Marker> _markersMap = {};
  Map<MarkerId, Marker> get getMarkersMap => _markersMap;

  final List<IconData> mapTypeIcons = [
    Icons.map,
    Icons.satellite,
    Icons.terrain,
    Icons.layers,
  ];

  final List<MapType> mapTypes = [
    MapType.normal,
    MapType.satellite,
    MapType.terrain,
    MapType.hybrid,
  ];

  final LatLng defaultIndiaLocation = const LatLng(20.5937, 78.9629);

  Polygon? rectanglePolygon;

  LatLng? get currentLocation => _currentLocation;
  MapType get currentMapType => _currentMapType;
  GoogleMapController? get mapController => _mapController;
  bool get isLoading => _isLoading;

  MapsProvider() {
    _isWeb = identical(0, 0.0); // Detect web platform
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final bool hasPermission = await requestLocationPermissions();
      if (!hasPermission) {
        if (!_isWeb) await openAppSettings();
        return;
      }

      await _getLocationUpdates();
      await centerToCurrentLocation(zoom: 14);
    } catch (e) {
      print("❌ Error initializing location: $e");
      if (_isWeb) {
        print(
            "Note: Web has limited location support. Ensure HTTPS and user grants permission.");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestLocationPermissions() async {
    if (_isWeb) {
      // Web has different permission handling
      try {
        final serviceEnabled = await _locationController.serviceEnabled();
        if (!serviceEnabled) {
          return false;
        }
        return true;
      } catch (e) {
        return false;
      }
    } else {
      // Mobile/desktop permission handling
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
      }
      return status.isGranted;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void changeMapType(int index) {
    _currentMapType = mapTypes[index];
    notifyListeners();
  }

  Future<void> _getLocationUpdates() async {
    try {
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
        if (!serviceEnabled) return;
      }

      final location = await _locationController.getLocation();
      if (location.latitude != null && location.longitude != null) {
        _updateCurrentUserLocationInMap(
          LatLng(location.latitude!, location.longitude!),
        );
      }
    } catch (e) {
      print("Location error: $e");
      if (_isWeb) {
        _currentLocation = defaultIndiaLocation;
        notifyListeners();
      }
    }
  }

  void _updateCurrentUserLocationInMap(LatLng location) {
    _currentLocation = location;
    rectanglePolygon = create2kmRectangle(location);
    notifyListeners();
  }

  Polygon create2kmRectangle(LatLng center) {
    const double earthRadius = 6378137.0;
    final double latOffset = (1000.0 / earthRadius) * (180 / pi);
    final double lngOffset =
        (1000.0 / (earthRadius * cos(pi * center.latitude / 180))) * (180 / pi);

    return Polygon(
      polygonId: const PolygonId('2km_rectangle'),
      points: [
        LatLng(center.latitude + latOffset, center.longitude - lngOffset),
        LatLng(center.latitude + latOffset, center.longitude + lngOffset),
        LatLng(center.latitude - latOffset, center.longitude + lngOffset),
        LatLng(center.latitude - latOffset, center.longitude - lngOffset),
        LatLng(center.latitude + latOffset, center.longitude - lngOffset),
      ],
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.2),
      strokeWidth: 2,
    );
  }

  Future<void> centerToCurrentLocation({double zoom = 14}) async {
    if (_currentLocation != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: zoom),
        ),
      );
    } else if (_isWeb) {
      // Fallback for web if location not available
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: defaultIndiaLocation, zoom: zoom),
        ),
      );
    }
  }

  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _markersSet.clear();
    _markersMap.clear();
    stopTracking();
    super.dispose();
  }
}
