import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_translate/global.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:user/Maps/UI/location_page.dart';
import 'package:user/NewParcel/models/Destination.dart';
import 'package:user/NewParcel/models/originDetail.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/constantfile.dart';
import 'package:user/baseurlp/baseurl.dart';
import 'package:user/NewParcel/parcel_details.dart';
import 'package:user/NewParcel/pharmacybean/chargelistuser.dart';
import 'package:user/NewParcel/pharmacybean/parceladdress.dart';
import 'package:user/bean/resturantbean/address_data.dart';

import 'models/parcel.dart';

class NewAddressTo extends StatefulWidget {
  final OriginDetail senderAddress;
  final void Function(Destination, bool) orderAdded;
  final bool isEditing;
  final Destination destination;


  NewAddressTo({Key key , this.senderAddress, this.orderAdded, this.isEditing, this.destination}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NewAddressToState();
  }
}

class NewAddressToState extends State<NewAddressTo> {
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: apiKey);
  TextEditingController houseNumberController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController receiverNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController mainStreetController = TextEditingController();
  TextEditingController secondaryStreetController = TextEditingController();
  TextEditingController detailsPackageController = TextEditingController();
  TextEditingController detailsAddressController = TextEditingController();


  String currentAddress = '';
  AddressData _addressSender;

  dynamic lat = 0.0;
  dynamic lng = 0.0;

  bool isFetch = false;

  dynamic distance = 0.0;
  dynamic charges = 0.0;
  dynamic city_id;

  int orderIncrement;

  @override
  void initState() {
    orderIncrement = 1;
    _getLocation();
    super.initState();
    loadDestinationData();
  }


  loadDestinationData() {
    if(!widget.isEditing) return;
    setState(() {
      _addressSender = widget.destination.location;
    houseNumberController.text = widget.destination.houseNumber;
    postalCodeController.text = widget.destination.postalCode;
    addressController.text = widget.destination.addressReferences;
    receiverNameController.text = widget.destination.name;
    phoneController.text = widget.destination.phone;
    mainStreetController.text = widget.destination.mainStreet;
    secondaryStreetController.text = widget.destination.secondaryStreet;
    detailsPackageController.text = widget.destination.parcels.length.toString();
    detailsAddressController.text = widget.destination.addressReferences;
    _getCameraMoveLocation(new LatLng(widget.destination.lat, widget.destination.lng), widget.destination.location.address);
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
            print('${value[i].locality}');
            if (value[i].locality != null && value[i].locality.length > 1) {
              setState(() {
                cityController.text = value[i].locality;
                postalCodeController.text = value[i].postalCode;
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
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.0),
        child: AppBar(
          backgroundColor: kWhiteColor,
          titleSpacing: 0.0,
          title: Text(
            'Detalles del receptor',
            style: TextStyle(
                fontSize: 18, color: black_color, fontWeight: FontWeight.w400),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),

            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10.0, top: 10, bottom: 10.0),
              child: Text(
                translate('receiver_address'),
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
                      translate('receiver_name'),
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
                        controller: receiverNameController,
                        decoration: InputDecoration(
                          hintText: 'Receiver Name',
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
                      'No. de Contacto',
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
                          hintText: 'Teléfono del receptor',
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
                            hintText: 'Indique detalles referenciales',
                            hintStyle: TextStyle(fontSize: 15),
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          )
                        ),
                      ),
                    ),
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
                      'Número de Casa/Piso',
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
                          hintText: 'No. Casa/Piso',
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
                                  controller: postalCodeController,
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
                  Destination orderDetails = new Destination(
                    lat, lng,
                      houseNumberController.text,
                      postalCodeController.text,
                      detailsAddressController.text,
                      secondaryStreetController.text,
                      mainStreetController.text,
                      phoneController.text,
                      receiverNameController.text,
                      orderIncrement,
                      [new Parcel("Zapatos", "Nike 54")],
                       _addressSender);
                      widget.orderAdded(orderDetails, widget.isEditing);
                      orderIncrement++;
                 Navigator.of(context).pop();
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
                      'Agregar',
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
      language: "es",
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
      currentAddress = '${addressd}';
      lat = data.latitude;
      lng = data.longitude;
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
            postalCodeController.text = value[i].postalCode;
            currentAddress =
                currentAddress.replaceAll('${value[i].locality},', '');
            currentAddress = currentAddress.replaceAll('${postalCodeController.text},', '');
            currentAddress =
                currentAddress.replaceAll('${value[i].locality}', '');
            currentAddress = currentAddress.replaceAll('${postalCodeController.text}', '');
            currentAddress =
                currentAddress.replaceAll('${value[i].countryName}', '');
            addressController.text = currentAddress;
          });
          break;
        }
      }
    });
  }

  showProgressDialog(String text, ProgressDialog pr) {
    pr.style(
        message: '${text}',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
  }

  /*
  void hitServiceCount(ProgressDialog pr, BuildContext context) async {
    pr.show();
    var chargeList = parcel_listcharges;
    var client = http.Client();
    client.post(chargeList, body: {'vendor_id': '${widget.vendor_id}'}).then(
        (value) {
      if (value.statusCode == 200) {
        print('${value.body}');
        pr.hide();
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var jsLst = jsonData['data'] as List;
          List<ChargeListBean> cityFetcjList =
              jsLst.map((e) => ChargeListBean.fromJson(e)).toList();
          if (cityFetcjList.length > 0) {
            for (int i = 0; i < cityFetcjList.length; i++) {
              if (cityFetcjList[i].city_name.toString().contains(city.text)) {
                double disForCharge = calculateDistance(
                    widget.senderAddress.lat,
                    widget.senderAddress.lng,
                    lat,
                    lng);
                setState(() {
                  city_id = '${cityFetcjList[i].city_id}';
                  charges = '${cityFetcjList[i].parcel_charge}';
                });
                if (houseno.text != null &&
                    pincode.text != null &&
                    city.text != null &&
                    landmark.text != null &&
                    address.text != null &&
                    state.text != null &&
                    lat != null &&
                    lng != null &&
                    sendercontact.text != null &&
                    sendername.text != null) {
                  ParcelAddress parcelAddress = ParcelAddress(
                      houseno.text,
                      pincode.text,
                      city.text,
                      landmark.text,
                      address.text,
                      state.text,
                      lat,
                      lng,
                      sendername.text,
                      sendercontact.text);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParcelDetails(
                              widget.senderAddress,
                              parcelAddress,
                              city_id,
                              charges,
                              disForCharge)));
                } else {
                  Toast.show('please enter all details to continue!', context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                }
                break;
              }
            }
          } else {
            Toast.show('we not provide service in this area!', context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
          }
        } else {
          Toast.show('we not provide service in this area!', context,
              duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        }
      }
    }).catchError((e) {
      pr.hide();
      print(e);
    });
  }

   */

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
