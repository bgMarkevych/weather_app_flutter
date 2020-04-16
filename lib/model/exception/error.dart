class ConnectionError implements Exception {
  String message = "No Intentet!";

  ConnectionError();
}

class PermissionNotGranted implements Exception {
  String message = "Enable permissions";

  PermissionNotGranted();
}

class ServiceNotEnabled implements Exception {
  String message = "Enable permissions";

  ServiceNotEnabled();
}
