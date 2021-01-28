import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_translate/global.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/Maps/UI/location_page.dart';
import 'package:user/NewParcel/orders.dart';
import 'package:user/NewParcel/senderAddress.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/constantfile.dart';
import 'package:user/baseurlp/baseurl.dart';
import 'package:user/NewParcel/pharmacybean/parceladdress.dart';
import 'package:user/NewParcel/receiveraddress.dart';
import 'package:user/bean/resturantbean/address_data.dart';

class AddressFrom extends StatefulWidget {

  AddressFrom();

  @override
  State<StatefulWidget> createState() {
    return AddressFromState();
  }
}

class AddressFromState extends State<AddressFrom> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController houseNumberController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController detailsAddressController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController mainStreetController = TextEditingController();
  TextEditingController secondaryStreetController = TextEditingController();
  

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);

  AddressData _addressSender;
  SenderAddress senderAddress;

  bool isFetchStore = false;

  double lat = 0.0;
  double lng = 0.0;

  String currentAddress = '';
  SharedPreferences prefs;

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text =  prefs.getString('user_name');
      phoneController.text =  prefs.getString('user_phone');
    });

  }

  void _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
          await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double lat = position.latitude;
        double lng = position.longitude;
        final coordinates = new Coordinates(lat, lng);
        await Geocoder.local
            .findAddressesFromCoordinates(coordinates)
            .then((value) {
          for (int i = 0; i < value.length; i++) {
            if (value[i].locality != null && value[i].locality.length > 1) {
              setState(() {
                cityController.text = value[i].locality;
                pinCodeController.text = value[i].postalCode;
              });
              break;
            }
          }
        });
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation();
          } else {
            Toast.show('Location permission is required!', context,
                duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          Toast.show('Location permission is required!', context,
              duration: Toast.LENGTH_SHORT);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation();
      } else {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation();
      }).catchError((e) {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.0),
        child: AppBar(
          backgroundColor: kWhiteColor,
          titleSpacing: 0.0,
          title: Text(
            'REMITENTE',
            style: TextStyle(
                fontSize: 18, color: black_color, fontWeight: FontWeight.w400),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10.0, top: 10, bottom: 10.0),
              child: Text(
                translate('sender_address'),
                style: TextStyle(
                    fontSize: 18,
                    color: black_color,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(300),
                onTap: () async {
                  LocationResult result = await showLocationPicker(
                    context,
                    apiKey,
                    initialCenter: LatLng(lat ?? 0, lng ?? 0),
                    //automaticallyAnimateToCurrentLocation: true,
                    //mapStylePath: 'assets/mapStyle.json',
                    myLocationButtonEnabled: true,
                    //resultCardAlignment: Alignment.bottomCenter,
                    // requiredGPS: true,
                    layersButtonEnabled: true,
                    // countries: ['AE', 'NG']

//                      resultCardAlignment: Alignment.bottomCenter,
                  );
                  setState(() {
                    _addressSender = new AddressData.fromJSON({
                      'address': result.address,
                      'latitude': result.latLng.latitude,
                      'longitude': result.latLng.longitude,
                    });
                    lat = result.latLng.latitude;
                    lng = result.latLng.longitude;
                    _getCameraMoveLocation(
                        LatLng(lat, lng), result.address);
                  });
                  //print("result = $result");
                  // Navigator.of(widget.scaffoldKey.currentContext).pop();
                },
                child:
                  Card(
                    elevation: 2,
                    color: kMainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.all(10.0),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child:
                      Row( mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Text(
                        _addressSender != null ?
                        _addressSender.address : 'Dirección en el mapa',
                        style: TextStyle(fontSize: 18, color: kWhiteColor),),),
                        Icon(
                          Icons.location_pin,
                          color: kWhiteColor,
                          size: 28,
                        ),])
                    ),
                  ),

              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      translate('sender_name'),
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: translate('sender_name'),
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      translate( "sender_phone"),
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: 'Teléfono del emisor',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      translate('references'),
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 5,
                        controller: detailsAddressController,
                        decoration: InputDecoration(
                          hintText: 'Indica detalles de referencia',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                  /*
                  GestureDetector(
                    onTap: () {
                      getPlaces(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Card(
                      elevation: 2,
                      color: kWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(left: 10.0),
                        child: TextFormField(
                          maxLines: 5,
                          controller: detailsAddressController,
                          enabled: (detailsAddressController.text.length == 0) ? false : true,
                          decoration: InputDecoration(
                            hintText: 'Indica detalles de referencia',
                            hintStyle: TextStyle(fontSize: 15),
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if(value.length==1){
                              getPlaces(context);
                            }
                          },
                          onTap: () {},
                        ),
                      ),
                    ),
                  )
                  */

                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      translate('main_street'),
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: mainStreetController,
                        decoration: InputDecoration(
                          hintText: translate('main_street'),
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      translate('secondary_street'),
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: secondaryStreetController,
                        decoration: InputDecoration(
                          hintText: translate('secondary_street'),
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Número de Casa',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: houseNumberController,
                        decoration: InputDecoration(
                          hintText: 'Número de casa o Piso',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                'Código Postal',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: black_color,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Card(
                              elevation: 2,
                              color: kWhiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  maxLines: 1,
                                  enabled: false,
                                  controller: pinCodeController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Código Postal',
                                    hintStyle: TextStyle(fontSize: 15),
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                translate('city'),
                                style: TextStyle(
                                    fontSize: 15,
                                    color: black_color,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Card(
                              elevation: 2,
                              color: kWhiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  maxLines: 1,
                                  controller: cityController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'City',
                                    enabled: false,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 15),
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),

            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: GestureDetector(
                onTap: () {
                  if (houseNumberController.text != null && houseNumberController.text.isNotEmpty &&
                      pinCodeController.text != null && pinCodeController.text.isNotEmpty &&
                      cityController.text != null && cityController.text.isNotEmpty &&
                      detailsAddressController.text != null && detailsAddressController.text.isNotEmpty &&
                      secondaryStreetController.text != null && secondaryStreetController.text.isNotEmpty &&
                      mainStreetController.text != null && mainStreetController.text.isNotEmpty &&
                      phoneController.text != null && phoneController.text.isNotEmpty &&
                      nameController.text != null && nameController.text.isNotEmpty &&
                      lat != null && lat != 0.0 &&
                      lng != null && lng != 0.0) {
                    senderAddress = SenderAddress(lat, lng,
                        houseNumberController,
                        pinCodeController,
                        cityController,
                        detailsAddressController,
                        secondaryStreetController,
                        mainStreetController,
                        phoneController,
                        nameController);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OrdersWidget(senderAddress)));
                  } else {
                    Toast.show('Llene todos los datos para continuar!', context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OrdersWidget(senderAddress)));
                  }
                },
                child: Card(
                  elevation: 2,
                  color: kMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    height: 52,
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Continuar',
                      style: TextStyle(fontSize: 18, color: kWhiteColor),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaces(context) async {
    PlacesAutocomplete.show(
      context: context,
      apiKey: apiKey,
      mode: Mode.fullscreen,
      sessionToken: Uuid().generateV4(),
      onError: (response) {
        print('${response.errorMessage}');
      },
      language: "en",
    ).then((value) {
      displayPrediction(value);
    }).catchError((e) {
      print(e);
    });
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      _getCameraMoveLocation(
          LatLng(lat, lng), '${detail.result.formattedAddress}');
    }
  }

  void _getCameraMoveLocation(LatLng data, addressd) async {
    setState(() {
      lat = data.latitude;
      lng = data.longitude;
      currentAddress = '${addressd}';
    });
    final coordinates = new Coordinates(lat, lng);
    await Geocoder.local
        .findAddressesFromCoordinates(coordinates)
        .then((value) {
      for (int i = 0; i < value.length; i++) {
        print('${value[i].locality}');
        if (value[i].locality != null && value[i].locality.length > 1) {
          setState(() {
            cityController.text = value[i].locality;
            pinCodeController.text = value[i].postalCode;
            currentAddress =
                currentAddress.replaceAll('${value[i].locality},', '');
            currentAddress = currentAddress.replaceAll('${pinCodeController.text},', '');
            currentAddress =
                currentAddress.replaceAll('${value[i].locality}', '');
            currentAddress = currentAddress.replaceAll('${pinCodeController.text}', '');
            currentAddress =
                currentAddress.replaceAll('${value[i].countryName}', '');
            detailsAddressController.text = currentAddress;
          });
          break;
        }
      }
    });
  }

}
