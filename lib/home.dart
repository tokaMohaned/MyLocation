import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
 // const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  Set<Marker> markers={};//it is empty set to add markers here

   CameraPosition currentLocation =
  CameraPosition(
    target: LatLng(37.42796133580664,-122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    //bearing it is change the postion of camera hirozontly
    //i can change until 360
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
     //يحرك الكامرا فوق و تحت راسيا معايا الى 90 درجه
      tilt: 59.440717697143555,

      zoom: 19.151926040649414);
  @override
  void initState()
  {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    subscription!.cancel(); //it is close lisner when i close the screen
  }
  //AIzaSyAIijbvOtJgjA1v0OuUFaxo7J7ZSW6jglY

int count =0;
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("GPS"),
      ),
      body:
      locationData==null?Center(
          child: CircularProgressIndicator()):
      GoogleMap(
        mapType: MapType.hybrid,

        //marker is set لا بوجد فيها تكرار
        markers:markers ,
        
        onTap: (argument){
          markers.add(Marker(markerId: MarkerId("new$count"),
          position: argument) );
          //i add this count to can
          count++;
        setState(() {

        });
          },


        initialCameraPosition: currentLocation,//position
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: updateMyLocation,
          label: const Text('My Location'),
          icon: const Icon(Icons.home),
        ),

    );


  }

  Future<void> updateMyLocation() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.
    newCameraPosition(CameraPosition(
        zoom: 18,
        target: LatLng(locationData!.latitude!,
        locationData!.longitude!))));

  }
  Location location=Location();
  PermissionStatus? permissionStatus;
  bool isServiceEnable=false;
  LocationData? locationData;
  StreamSubscription<LocationData>?subscription;

  void  getCurrentLocation() async
  {
    bool permission=await  isPermissionGranted();
    if(!permission) return; //if permision is flse go outside the function
    bool service=await isServiceEnabled();
    if(!service) return;
    locationData =await location.getLocation();

    //the id will not change becuase it is entered the Set
    markers.add( Marker(
        markerId: MarkerId("myLocation"),
       position: LatLng(locationData!.latitude!,
        locationData!.longitude!)));

    currentLocation =
        CameraPosition(
          target: LatLng(locationData!.latitude! ,locationData!.longitude!),
          zoom: 18.4746,
        );

//i need to listen every change in location so i have
// to make and update event
    subscription= location.onLocationChanged.listen((event) {
      locationData = event;
//انا كتبته تاني عشان يتحرك معايا لما اغير اللوكيشن
      markers.add( Marker(
          markerId: MarkerId("myLocation"),
          position: LatLng(event.latitude!,
              event.longitude!)));
      updateMyLocation();

      setState(() {

});

      print("latitude: ${locationData!.latitude},"
          "long: ${locationData!.latitude}");

    });
    location.changeSettings(accuracy: LocationAccuracy.high);//accuricy  location
  setState(() {

  });

  }

//it is used when i close the gps in my phone
//so it is alert the user to open it
  Future<bool> isServiceEnabled() async //هل الخدمه متاحه
      {
    isServiceEnable=await location.serviceEnabled();
    if(!isServiceEnable)//if it is false
        {
      isServiceEnable=await location.requestService();
    }
    return isServiceEnable;
  }



//هل تم اخذ الاذن بترجع true or flase
//it is used when i download the app it is only one time to take the permission to open the location
  Future<bool> isPermissionGranted() async//this for make user accept open location
      {
    permissionStatus=await location.hasPermission();
    if(permissionStatus==PermissionStatus.denied)//it is mean i don't have permission
        {
      permissionStatus=await  location.requestPermission();
      //اطلب الاذن مره اخرى
      return permissionStatus==PermissionStatus.granted;
      //if the user give granted it will be true if not it will be false and the function will stop
      //and if the user give permssion i will return the persmission status
    }
    return permissionStatus==PermissionStatus.granted;

    //and if the user give permssion i will return the persmission status



  }


}

