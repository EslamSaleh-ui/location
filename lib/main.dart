// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<double> getLocation=await permission();
  runApp( MyApp(latitude:getLocation.first ,longitude: getLocation.last) );
}

class MyApp extends StatelessWidget{

  const MyApp({super.key, required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      home:MyHomePage(title: 'Location',latitude:latitude ,longitude: longitude) ,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  ValueNotifier<bool> show=ValueNotifier<bool>(true);
  final Completer<GoogleMapController> _completer=Completer();

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(widget.title),
      ),
      body:Stack(children: <Widget>[GoogleMap(initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude,widget.longitude),zoom: 14)
          ,onMapCreated: (c){
            _completer.complete(c);
          },
          onCameraMove: (p2){
            show.value=true;
          },
          circles:{Circle(circleId:const CircleId('1'),
              center: LatLng(widget.latitude,widget.longitude),
              visible: true,radius: 8,fillColor:Colors.blue.shade700,
              strokeColor: Colors.blue.shade300,strokeWidth: 2
          )} ,
          mapType: MapType.normal,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          myLocationEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          myLocationButtonEnabled: true),
      Center(child: Image.asset('assets/1.png',height: 50,width: 50))
      ])  ,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ValueListenableBuilder(
          valueListenable: show,
          builder: (context,value,child){
            if(show.value) {
              return ElevatedButton(onPressed: ()async{
                final GoogleMapController controller=await _completer.future;
                LatLngBounds visible=await controller.getVisibleRegion();
                double latitude =(visible.northeast.latitude+visible.southwest.latitude)/2;
                double longitude=(visible.northeast.longitude+visible.southwest.longitude)/2;
                List<Placemark> address=await placemarkFromCoordinates(latitude, longitude,localeIdentifier: 'en');
              show.value=false;
               showBottomSheet(context: context, builder: (_){
                 return Container(
                   width: MediaQuery.of(context).size.width,
                   height: MediaQuery.of(context).size.height/3,
                   decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(50),topRight:Radius.circular(50) ),
                   color: Colors.white),
                   alignment: Alignment.center,
                   padding: const EdgeInsets.all(5),
                   child: Text('${address.first.name} ${address.first.street} \n '
                       '${address.first.locality} ${address.first.country}',
                       style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold))
                 );
               });
              }, style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),)
                  ,backgroundColor: Colors.pink, minimumSize:  Size(MediaQuery.of(context).size.width/2, 50)
              ), child:  const Text('Confirm Pin Location',style: TextStyle(color: Colors.white)));
            } else {
              return Container();
            }
          }),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}

Future<List<double>> permission() async {
  final per=await Geolocator.checkPermission();
  if(per==LocationPermission.denied)
  { final p=await Geolocator.checkPermission();
  if(p==LocationPermission.denied) {
    return [30.0333,31.233334];
  }else
  {final currentPosition=await Geolocator.getCurrentPosition();
  return [currentPosition.latitude,currentPosition.longitude];
  }
  }
  return [];
}