import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../view model/maps_provider.dart';

class Maps extends StatelessWidget {
  const Maps({super.key});

  @override
  Widget build(BuildContext context) {
    final mapsProvider = context.watch<MapsProvider>();
    return Scaffold(
      body: mapsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: mapsProvider.currentMapType,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: mapsProvider.currentLocation ??
                        mapsProvider.defaultIndiaLocation,
                    zoom: mapsProvider.currentLocation != null ? 15 : 4,
                  ),
                  onMapCreated: mapsProvider.onMapCreated,
                  markers: Set.from(mapsProvider.markers),
                  polygons: mapsProvider.rectanglePolygon != null
                      ? {mapsProvider.rectanglePolygon!}
                      : {},
                ),

                // 📍 Map type selector
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.05,
                  right: 5,
                  child: Column(
                    children:
                        List.generate(mapsProvider.mapTypes.length, (index) {
                      return ChoiceChip(
                        avatar: Icon(
                          mapsProvider.mapTypeIcons[index],
                          color: Colors.black,
                        ),
                        label: const SizedBox.shrink(),
                        selected: mapsProvider.currentMapType ==
                            mapsProvider.mapTypes[index],
                        onSelected: (_) => mapsProvider.changeMapType(index),
                        selectedColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        backgroundColor: Colors.grey.shade300,
                        shape: const CircleBorder(),
                        labelPadding: EdgeInsets.zero,
                      );
                    }),
                  ),
                ),
                // 🎯 Location button
                Positioned(
                  right: 10,
                  bottom: MediaQuery.of(context).size.height * 0.2,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: FloatingActionButton(
                          shape: const CircleBorder(),
                          onPressed: mapsProvider.centerToCurrentLocation,
                          child: const Icon(Icons.my_location),
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
