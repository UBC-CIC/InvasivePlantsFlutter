import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'ioFileSystem.dart';

/// Number of species per page
const pageSize = 20;   

/// Number of day for each cache
const maxCacheDay = 3;

/// Currently selected region
/// Default, select based on the current regiont or the first region of the regionList[]
/// Mannual selection, user can switch between regions mannually and the value of this variable update based on selection
var selectedRegion = {};

/// List of region availabled
List<dynamic> regionList = [];

// Currently selected region
// Default, select based on the current regiont or the first region of the regionList[]
// Mannual selection, user can switch between regions mannually and the value of this variable update based on selection
List<dynamic> speciesData = []; // List of species available from the server

int refreshedLists = 0;

/// Default cache manager
/// Refrence: flutter_cache_manager-3.3.1/lib/src/config/_config_io.dart
/// Confugration: {
///   stalePeriod: 30 days
///   maxNrOfCacheObjects: 200 objects
/// }