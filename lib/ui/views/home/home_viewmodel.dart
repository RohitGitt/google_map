import 'package:flutter/material.dart';
import 'package:google_map/app/app.bottomsheets.dart';
import 'package:google_map/app/app.dialogs.dart';
import 'package:google_map/app/app.locator.dart';
import 'package:google_map/services/easyLoading/easyLoadingService.dart';
import 'package:google_map/ui/common/app_strings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {

  final currentLocationPolygonId = "currentLocationPolygonId";
  final destinationLocationPolygonId = "destinationLocationPolygonId";
  bool isTracking = false;
  late GoogleMapController _googleMapController;

  Location _location = Location();

  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  LatLng? _destinationLocation;
  LatLng? get destinationLocation => _destinationLocation;

  Marker? currentLocationMarker ;

  Marker? destinationLocationMarker ;

  Set<Marker> _markers = {
  };
  Set<Marker> get marker => _markers;

  Set<Polyline> _polylines = {};
  Set<Polyline> get polylines => isTracking == true ? _polylines : {};

  toogleIsTracking(){
    if(isTracking){
      _destinationLocation = null;
      _polylines.clear();
        isTracking = !isTracking;
    }else{
      if(destinationLocation != null){
        isTracking = !isTracking;
        updateMapData();
      }else{
        // when no destination is selected and user pressed track location
        locator<EasyLoadingService>().showSuccessToast(title: "Please select destination by clicking on map first");
        
      }
      
    }
    notifyListeners();
  }

  setMarkers(){
    _markers.clear();
    if(getCurrentLocationMarker() != null){

    _markers.add(getCurrentLocationMarker()!);
    }
    if(getDestinationLocationMarker() != null){
      _markers.add(getDestinationLocationMarker()!);

    }
    notifyListeners();

  }



  void setPolylines() {
    
    if ((currentLocation != null) && (destinationLocation != null)) {
      _polylines.clear();
      final polyline = Polyline(
          polylineId: PolylineId(currentLocationPolygonId),
          points: [currentLocation! , destinationLocation!],
          color: Colors.blue ,
          width: 5
          );
      _polylines.add(polyline);
    }
   
    notifyListeners();
  }

  setGoogleMapController(GoogleMapController controller) {
    _googleMapController = controller;
    notifyListeners();
  }

  setDestinationPostion(LatLng? position) {
    if (position != null) {
      _destinationLocation = position;
      updateMapData();
      notifyListeners();
    }
  }

  moveCameraTo(LatLng? position) {
    if (position != null) {
      _googleMapController.animateCamera(CameraUpdate.newLatLng(position));
      notifyListeners();
    }
  }

  Marker? getCurrentLocationMarker() {
    if (currentLocation != null) {
      _markers.add( Marker(
        markerId: MarkerId('currentLocationMarker'),
        position: currentLocation!,
        draggable: true,
        onDragEnd: (value) {
          _currentLocation = value; 
          updateMapData();
        },
        infoWindow: const InfoWindow(
            title: 'Current Location', snippet: 'Your Current Location'),
        // icon: add here marker to show custom marker icon like food , person etc 
      ));
      notifyListeners();
    }
  }

  Marker? getDestinationLocationMarker() {
    if (destinationLocation != null) {
      _markers.add(Marker(
        markerId: MarkerId('destinationLocationMarker'),
        position: destinationLocation!,
        draggable: true,
        onDragEnd: (value) {
          _destinationLocation = value ;
          updateMapData();
        },
        infoWindow: const InfoWindow(
            title: 'Destination Location', snippet: 'Destination Location'),
      ));
      notifyListeners();
    }
  }

  void getCurrentLocation() async {
    LocationData position = await _location.getLocation();
    
    if (position.latitude == null && position.longitude == null) {
      return;
    }
    _currentLocation = LatLng(position.latitude!, position.longitude!);
    setMarkers();
    notifyListeners();
  }

  void listenToLiveLocation() {
    _location.onLocationChanged.listen((LocationData newLocation) {
      _currentLocation = LatLng(newLocation.latitude!, newLocation.longitude!);
      updateMapData();
     
      notifyListeners();
    });
  }

  updateMapData(){
    setMarkers();
    setPolylines();
    notifyListeners();
  }

  Future<bool> isLocationServiceEnabled() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  Future<bool> doHaveLocationPermission() async {
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  Future<AssetMapBitmap> getUserMarkerIcon() async{
    return await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/marker_icon.png',
    );
  }
}
