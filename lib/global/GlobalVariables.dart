import 'package:flutter/material.dart';

/// Color Scheme of App
class AppColors {
  static const Color primaryColor = Color(0xFF607C3C);
  static const Color secondaryColor = Color(0xFFB7BF96);
}

/// Number of species per page
const pageSize = 20;

/// Number of day for each cache
const maxCacheDay = 3;

/// Currently selected region
/// Default, select based on the current region or the first region of the regionList[]
/// Manual selection, user can switch between regions manually and the value of this variable update based on selection
var selectedRegion = {};

/// List of regions available
List<dynamic> regionList = [];

// Currently selected region
// Default, select based on the current region or the first region of the regionList[]
// Manual selection, user can switch between regions manually and the value of this variable update based on selection
List<dynamic> speciesData = []; // List of species available from the server

int refreshedLists = 0;

/// Default cache manager
/// Refrence: flutter_cache_manager-3.3.1/lib/src/config/_config_io.dart
/// Confugration: {
///   stalePeriod: 30 days
///   maxNrOfCacheObjects: 200 objects
/// }