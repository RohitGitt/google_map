import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel>  with WidgetsBindingObserver{
  const HomeView({Key? key}) : super(key: key);

  // AppLifecycleState? currentAppLifeCycleState;

  @override
  void onViewModelReady(HomeViewModel viewModel) async{
    // GooglePlaceAutocompleteService().getPlaceSuggestions("mumbai");
     WidgetsBinding.instance.addObserver(this);
    // this permission should be asked on the onResume method of applifecycle with WidgetBindingObserver
    if(await viewModel.isLocationServiceEnabled()==true){
      if( await viewModel.doHaveLocationPermission() == true){
        viewModel.getCurrentLocation();
        viewModel.listenToLiveLocation();
      };
    }else{
      exit(0);
    }
    super.onViewModelReady(viewModel);
  }

  @override
  void onDispose(HomeViewModel viewModel) {
    WidgetsBinding.instance.removeObserver(this);
    super.onDispose(viewModel);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: context.screenWidth,
          height: context.screenHeight,
          child: Column(
            children: [
              GoogleMap(
            initialCameraPosition: CameraPosition(target: viewModel.currentLocation ?? const LatLng(28.514580, 77.377594) , zoom: 5),
            onMapCreated: (controller) {
              viewModel.setGoogleMapController(controller);
              viewModel.getCurrentLocation();
              viewModel.moveCameraTo(viewModel.currentLocation);
            },
            myLocationButtonEnabled: true,
            onTap: (selectedPosition) {
              print(selectedPosition);
              viewModel.setDestinationPostion(selectedPosition);
            },
            markers: viewModel.marker,
            polylines: viewModel.polylines,
          ).expand() ,
          SizedBox(height: 10,),
          Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.blue
            ),
            child: OutlinedButton(onPressed: (){
              viewModel.toogleIsTracking();
            }, child: Text( viewModel.isTracking == false ? "Track Live Location" : "Stop Live Tracking" , style: TextStyle(color: Colors.white),)
              
          ),
          )
            ],
          ),
        )
        
       
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
      
}


