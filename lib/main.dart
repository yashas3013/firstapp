import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
// import 'package:flutter_geo_hash/flutter_geo_hash.dart';
// import "package:dart_geohash/"
import 'package:url_launcher/url_launcher.dart';
import 'package:dart_geohash/dart_geohash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions .currentPlatform,);
  runApp(const MyApp());
}
class Pair<T1, T2> {
  final T1 a;
  final T2 b;

  Pair(this.a, this.b);
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Parkassist'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double _currentSliderValue = 4;
  int _counter = 0;
  String pkey = '';
  // Position position = {'Lat'};
  String _latitude = "Loading...";
  String _longitude = "Loading...";
  double latitude = 0;
  double longitude = 0;
  int no_parking = 0;
  var spots = [];
  GeoHasher geoHasher = GeoHasher();
  final geo = GeoFlutterFire();
  final _firestore = FirebaseFirestore.instance;
  // DatabaseReference ref = FirebaseDatabase.instance.ref("locations/2");
  Future<void> update_data(String key,int no_parking) async {
    print(key);
    if(key!=''){
    DatabaseReference ref = FirebaseDatabase.instance.ref("locations/$key");

    int parking = no_parking -1;
    await ref.update({
      "no_parking": parking,
    });}
}
  void parked_here() {
    update_data(pkey, no_parking);
  }
  Future<void> get_data() async {
    GeoFirePoint geoFirePoint = geo.point(
        latitude: latitude, longitude: longitude);
    DatabaseReference ref = FirebaseDatabase.instance.ref("locations/");
    String curr_loc = geoFirePoint.data['geohash'];
    final snapshot = await ref.child('/').get();
    Map<Object?, Object?> data =  snapshot.value as Map<Object?, Object?>;
    for (final key in data.keys) {
      print(data[key]);
      Map<dynamic, dynamic> innerMap = data[key] as Map<dynamic, dynamic>;
      int noParking = innerMap['no_parking'];
      String hash = innerMap['hash'];
      print(hash);
      print(noParking);
      if(curr_loc.substring(0,8)==hash){
        print("parking found in");
        if(noParking!=0){
          pkey = key.toString();
          no_parking = noParking;
          print(noParking);
          break;
        }
      }


        // Do something with noParking and hash
    }}
    void find_spots(int radius) async{
    print("hello");
    var pspots = [];
      GeoFirePoint geoFirePoint = geo.point(
          latitude: latitude, longitude: longitude);
      DatabaseReference ref = FirebaseDatabase.instance.ref("locations/");
      String curr_loc = geoFirePoint.data['geohash'];
      final snapshot = await ref.child('/').get();
      print(snapshot.value);
      Map<Object?, Object?> data =  snapshot.value as Map<Object?, Object?>;
      for (final key in data.keys) {
        Map<dynamic, dynamic> innerMap = data[key] as Map<dynamic, dynamic>;
        String hash = innerMap['hash'];
        print(curr_loc.substring(0,radius));
        print(hash);
        if(curr_loc.substring(0,radius)==hash.substring(0,radius)){
          print("matched");
           GeoHash phash = GeoHash(hash);
           pspots.add(Pair(phash.latitude(), phash.longitude()));
        }

      }setState(() {
      spots = pspots;
      _counter = 0;
    });

    }

    // for (final key in snapshot.value.keys) {

    // }
    // print(snapshot.value);
    // Map<String?, dynamic?> data = snapshot.value as Map<String, dynamic>;

    //   print(val);
    // }


    // await ref.set({
    //   "name": "John", 'position_lat': geoFirePoint.latitude, 'position_long': geoFirePoint.longitude
    // });
    // _firestore
    //     .collection('locations')
    //     .add({'name': 'random name', 'position': geoFirePoint.data}).then((_) {
    //   print('added ${geoFirePoint.hash} successfully');
    // });

 // void print_loc(){
 //    Future<Position> position = _getGeoLocationPosition();
 //    print(position);

  Future<Position?> _getGeoLocationPosition() async {
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
    print(permission);
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
    // return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        latitude = position.latitude;
        longitude = position.longitude;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your location is',
            ),
            Text(
              '$_latitude, $_longitude',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 50),
            FloatingActionButton.large(
              // shape: Rectangula,
              disabledElevation: 0,
              onPressed:  () async { _getGeoLocationPosition(); },
              child: Center(
                child: const Text('Get location'),
              ),
            ),
            SizedBox(height: 50),
            Text("    "),
            Text('Search Radius'),
            Slider(
            value: _currentSliderValue,
            max: 9,
            divisions: 9,
            label: ((_currentSliderValue.round())*100).toString(),
            onChanged: _longitude == "Loading..." ? null : (double value) {
            setState(() {
            _currentSliderValue = value;

            });
            spots = [];
            _counter = 0;
            print(_currentSliderValue);
            find_spots(9-_currentSliderValue.toInt());
            }),
          Text("Parking Locations are : "),
          Expanded(

          child: ListView.builder(
          itemCount: spots.length,
          itemBuilder: (context, index) {
          final spot = spots[index];

          print(spot);
          if(spot!=null){
            _counter = _counter+1;
            return ListTile(

            title: Container(
                child: InkWell(
                child: Text('Location ${_counter}',style: TextStyle(letterSpacing: 1.0,fontWeight: FontWeight.bold,decoration: TextDecoration.underline,color: Colors.blue)),
                onTap: () => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${spot.a}%2C${spot.b}'))),
            )

            );
            }
    else{
          _counter = 0;
          return Container(
            child:
            Text("No Empty Parking Spots Found")
          );

    }})),
            FloatingActionButton.large(
                disabledElevation: 0,
                onPressed: _longitude == "Loading..." ? null : ()async{get_data();update_data(pkey, no_parking);},
                child: Center(
                  child: const Text('Parked here'),)        ),
  ],
      ),)

      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
