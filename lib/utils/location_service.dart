import 'package:location/location.dart';

class LocationService{

  Location _location = new Location();

  Future<bool> isServiceEnabled(){
    return _location.serviceEnabled();
  }

  Future<bool> requestService(){
    return _location.requestService();
  }

  Future<bool> isPermissionGranted(){
    return _location.hasPermission().then((value) => value == PermissionStatus.granted);
  }

  Future<bool> isDeniedForever(){
    return _location.hasPermission().then((value) => value == PermissionStatus.deniedForever);
  }

  Future<bool> requestPermission(){
    return _location.requestPermission().then((value) => value == PermissionStatus.granted);
  }

  Future<LocationData> getLocationData(){
    return _location.getLocation();
  }

}