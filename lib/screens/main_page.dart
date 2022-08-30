import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final Completer<GoogleMapController> _controller = Completer();
  late BitmapDescriptor customIcon;

  void _zoomToCurrentLocation() async {
    var status = await Permission.locationWhenInUse.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      var newStatus = await Permission.locationWhenInUse.request();
      if (newStatus.isDenied || status.isPermanentlyDenied) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text('Location Required'),
                content: Text(
                    'Location permission is required to use this feature. Would you like to change your decision in the settings?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () => openAppSettings(),
                    child: Text('Yes'),
                  ),
                ],
              );
            });
      }
    }
    if (status.isGranted) {
      GoogleMapController controller = await _controller.future;
      Position postition = await Geolocator.getCurrentPosition();
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(postition.latitude, postition.longitude),
          zoom: 17,
        ),
      ));
    }
  }

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/customPin2.png',
    ).then((value) => customIcon = value);
    _loadAndDisplayData();
    super.initState();
  }

  void _loadAndDisplayData() async {
    final _rawData = await rootBundle.loadString("assets/locations.csv");
    List<List<dynamic>> _listData =
        const CsvToListConverter().convert(_rawData);

    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    for (List list in _listData) {
      MarkerId id = MarkerId(list.hashCode.toString());
      String title = list[0] as String;
      double latitude = list[1] as double;
      double longitude = list[2] as double;
      Marker marker = Marker(
        icon: customIcon,
        markerId: id,
        position: LatLng(list[1] as double, list[2] as double),
        infoWindow: InfoWindow(
            title: title,
            snippet: 'Click to navigate',
            onTap: () async {
              final Uri uri = Uri.https('maps.apple.com', '',
                  {'ll': '$latitude,$longitude', 'q': title});

              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.platformDefault,
                ).catchError(
                  (error) {
                    print(error);
                    return false;
                  },
                );
              }
            }),
      );

      markers[id] = marker;
    }

    setState(() {
      _markers = markers;
    });

    final GoogleMapController controller = await _controller.future;
  }

  // Center of PEI
  static const CameraPosition _peiLocationCenterPoint = CameraPosition(
    target: LatLng(46.34285942966604, -63.40507666941847),
    zoom: 10.5,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PEI Poutine'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: Icon(Icons.settings),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'PEI',
            backgroundColor: Color(0xffD2AE99),
            onPressed: () async {
              _controller.future.then((value) => value.animateCamera(
                  CameraUpdate.newCameraPosition(_peiLocationCenterPoint)));
            },
            child: FaIcon(FontAwesomeIcons.expand),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            onPressed: () => _zoomToCurrentLocation(),
            child: Icon(
              Icons.location_pin,
            ),
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) =>
            _controller.complete(controller),
        mapType: MapType.normal,
        initialCameraPosition: _peiLocationCenterPoint,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        markers: _markers.values.toSet(),
      ),
    );
  }
}
