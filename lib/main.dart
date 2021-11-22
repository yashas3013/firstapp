import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Park Assist',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: Homepage(),

    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  String location1 ='0';
  String location2 = '0';
  String location3 = '0';
  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
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
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
  Future<DocumentSnapshot> getData() async {
    await Firebase.initializeApp();
    return await FirebaseFirestore.instance
        .collection("users")
        .doc("docID")
        .get();
  }
  double PI = 3.141592653589793238;
  double deg2rad(double degree) {
    return degree * PI / 180;
  }
  double distance(lat1,lon1,lat2,lon2){
    var R = 6371;
    var dlat = deg2rad(lat1-lat2);
    var dlon = deg2rad(lon1-lon2);
    var a = sin(dlat/2) * sin(dlat/2) + cos(deg2rad(lat1)) * cos(deg2rad(lat1)) * sin(dlon/2) * sin(dlon/2);
    var c = 2 * atan2(sqrt(a),sqrt((1-a)));
    var Distance = R *c;
    return Distance;
  }
  
  Future<void> update(pincode,parkid,Data) async{
    CollectionReference data = FirebaseFirestore.instance.collection('parking');
    print(Data);
    return data
        .doc(pincode)
        .update(Data)
        .then((value) => print('data updated'))
        .catchError((error)=>print("$error"));

  }
  Future<void> Check_location(Position position)async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    getData();
    Placemark place = placemarks[0];
    String pincode = place.postalCode.toString();
    print(pincode);
    FirebaseFirestore.instance
        .collection('parking')
        .doc(pincode)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data()! as Map<
            String,
            dynamic>;
        for(String i in data.keys){
          GeoPoint cord1 = data[i][1];
          GeoPoint cord2 = data[i][2];
          GeoPoint cord3 = data[i][3];
          GeoPoint cord4 = data[i][4];
          var top = cord1.latitude;
          var left= cord3.longitude;
          var bottom = cord2.latitude;
          var right = cord4.longitude;
          print(left);
          print(right);
          print(position.latitude);
          print(position.longitude);
          if (top >= position.latitude && position.latitude >= bottom) {
            print(1);
            if (left <= right && left<=position.latitude&& position.longitude<=right){
              var k = data[i][5];
              data[i][5] = k+1;
              update(pincode, i, data);
              break;}
            if(left > right && (left <= position.longitude || position.longitude <= right)){
              // data[i][5] += 1;
              // print(data);
              var k = data[i][5];
              data[i][5] = k+1;
              // print(k);
              update(pincode, i, data);
              break;
            }
            }
          }
        }
      setState(()  {
      });
    });}
  Future<void> GetAddressFromLatLong(Position position)async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    getData();
    Placemark place = placemarks[0];
    String pincode = place.postalCode.toString();
    FirebaseFirestore.instance
    .collection('parking')
    .doc(pincode)
    .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data()! as Map<
            String,
            dynamic>;
        // print(data);
        var arr = [];
        // GeoPoint lat2 = data['001'][0];
        // print(lat2.)
        var map_cord = new Map();
        for (String i in data.keys) {
          if (data[i][5] != data[i][6]) {
            GeoPoint cord2 = data[i][0];
            var Dist = distance(
                position.latitude, position.longitude, cord2.latitude,
                cord2.longitude);
            arr.add(Dist);
            map_cord[Dist] = [cord2.latitude, cord2.longitude];
          }
        }
       arr.sort();
        print(position.latitude);
        print(position.longitude);
        // print(map_cord[arr[0]]);
        // print(arr[0]);
        // print(map_cord[arr[1]]);
        // print(arr[1]);
        // print(map_cord[arr[2]]);
        // print(arr[2]);
        location2  = 'https://www.google.com/maps/search/?api=1&query=${map_cord[arr[1]][0]}%2C${map_cord[arr[1]][1]}';
        location3  = 'https://www.google.com/maps/search/?api=1&query=${map_cord[arr[2]][0]}%2C${map_cord[arr[2]][1]}';
        location1  = 'https://www.google.com/maps/search/?api=1&query=${map_cord[arr[0]][0]}%2C${map_cord[arr[0]][1]}';
        print(location1);
      }else{
        print('doc does not exists');
      }
    });

    setState(()  {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ParkAssist',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,letterSpacing: 2.0))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
        child: new Text('Location 1',style: TextStyle(fontSize: 25,letterSpacing: 2.0,decoration: TextDecoration.underline,color: Colors.blue)),
            ),
        Container(
          child: new Text('Location 2',style: TextStyle(fontSize: 25,letterSpacing: 2.0,decoration: TextDecoration.underline,color: Colors.blue)),

        ),
            Container(
                child: new Text('Location 3',style: TextStyle(fontSize: 25,letterSpacing: 2.0,decoration: TextDecoration.underline,color: Colors.blue)),

            ),
            ElevatedButton(onPressed: () async{
              Position position = await _getGeoLocationPosition();
              // location ='Lat: ${position.latitude} , Long: ${position.longitude}';
              GetAddressFromLatLong(position);
            }, child: Text('Get Location', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.black) ),),
            ElevatedButton(onPressed: () async{
              Position position = await _getGeoLocationPosition();
              Check_location(position);
            }, child: Text('I have parked here',style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.red[600]) ),)
          ],
        ),
      ),
    );
  }
}