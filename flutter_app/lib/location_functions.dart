import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Get the current province user locate
// Return a map with probince code and country
// On Error, isError = true and errorMsg = Error Message
Future<Map<String, dynamic>> getCurrentProvince() async{
  try{
    // Check if permission allow
    await _determinePermission();

    // App has permission to request for location

    // Request coordinate with long and lat
    Position currentCoordinate = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);


    // Convert coordinate into address
    List<Placemark> placemarks = await placemarkFromCoordinates(currentCoordinate.latitude, currentCoordinate.longitude);
    
    // Prepare output
    var output = {
      "isError": false,
      "regionCode": placemarks[0].administrativeArea,
      "countryFullname": placemarks[0].country
    };
    return output;

  } catch(error){
    print('Error while fetching location data: ${error.toString()}');
    return {
      "isError": true,
      "errorMsg": error.toString()
    };
  }
}
/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
/// On successful permission, throw no error
Future<void> _determinePermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
}