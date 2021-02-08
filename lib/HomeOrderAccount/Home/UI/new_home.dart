import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/global.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
import 'package:user/Components/card_content.dart';
import 'package:user/Components/custom_appbar.dart';
import 'package:user/Components/reusable_card.dart';
import 'package:user/HomeOrderAccount/Home/UI/Stores/stores.dart';
import 'package:user/Maps/UI/location_page.dart';
import 'package:user/NewParcel/fromtoaddress.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurlp/baseurl.dart';
import 'package:user/bean/bannerbean.dart';
import 'package:user/bean/latlng.dart';
import 'package:user/bean/venderbean.dart';
import 'package:user/databasehelper/dbhelper.dart';
import 'package:user/parcel/parcalstorepage.dart';
import 'package:user/parcel/parcel_details.dart';
import 'package:user/parcel/parcel_details_empty.dart';
import 'package:user/pharmacy/pharmastore.dart';
import 'package:user/restaturantui/ui/resturanthome.dart';

class NewHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NewHome();
  }

}

class NewHome extends StatefulWidget {
  @override
  _NewHomeState createState() => _NewHomeState();
}

class _NewHomeState extends State<NewHome> {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  String firebaseToken = '';

  String cityName = 'NO LOCATION SELECTED';
  var lat = 0.0;
  var lng = 0.0;
  List<BannerDetails> listImage = [];
  List<VendorList> nearStores = [];
  List<VendorList> nearStoresShimmer = [
    VendorList("", "", "", ""),
    VendorList("", "", "", ""),
    VendorList("", "", "", ""),
    VendorList("", "", "", "")
  ];
  List<String> listImages = ['', '', '', '', ''];
  bool isCartCount = false;
  int cartCount = 0;
  bool isFetch = true;

  @override
  void initState() {
    super.initState();
    _getLocation(context);
    firebaseMessagingListner();
    listImage = [new BannerDetails(1, 'slides/slide 2.jpeg', 1)];
  }

  void _getLocation(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
      await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        // double lat = position.latitude;
        double lat = -0.160233;
        // double lng = position.longitude;
        double lng = -78.473443;
        prefs.setString("lat", lat.toStringAsFixed(8));
        prefs.setString("lng", lng.toStringAsFixed(8));
        final coordinates = new Coordinates(lat, lng);
        await Geocoder.local
            .findAddressesFromCoordinates(coordinates)
            .then((value) {
          if (value[0].locality != null && value[0].locality.isNotEmpty) {
            setState(() {
              this.lat = lat;
              this.lng = lng;
              String city = '${value[0].locality}';
              cityName = '${city.toUpperCase()}';
            });
          } else if (value[0].subAdminArea != null &&
              value[0].subAdminArea.isNotEmpty) {
            this.lat = lat;
            this.lng = lng;
            String city = '${value[0].subAdminArea}';
            cityName = '${city.toUpperCase()}';
          }
        }).catchError((e) {});
        hitService();
        hitBannerUrl();
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation(context);
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
        _getLocation(context);
      } else {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation(context);
      }).catchError((e) {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      });
    }
  }

  void getCartCount() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowBothCount().then((value) {
      setState(() {
        if (value != null && value > 0) {
          cartCount = value;
          isCartCount = true;
        } else {
          cartCount = 0;
          isCartCount = false;
        }
      });
    });
  }

  void getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currencyUrl = currencyuri;
    var client = http.Client();
    client.get(currencyUrl).then((value) {
      var jsonData = jsonDecode(value.body);
      if (value.statusCode == 200 && jsonData['status'] == "1") {
        preferences.setString(
            'curency', '${jsonData['data'][0]['currency_sign']}');
      }
    }).catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child:
            AppBar(title: Text('Freinar Express'), backgroundColor: kMainColor,)

          /* CustomAppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Icon(
                Icons.location_on,
                color: kMainColor,
              ),
            ),
            titleWidget: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return LocationPage(lat, lng);
                })).then((value) {
                  if (value != null) {
                    print('${value.toString()}');
                    BackLatLng back = value;
                    getBackResult(back.lat, back.lng);
                  }
                }).catchError((e) {
                  print(e);
                });
              },
              child: Text(
                '${cityName}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: kWhiteColor),
              ),
            ),
          ), */
        ),
        body: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 16.0, left: 24.0, right: 24.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Nosotros",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                "lo llevamos por ti",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyText1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                        (!isFetch && listImage.length == 0) ? false : true,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 5),
                          child: CarouselSlider(
                              options: CarouselOptions(
                                height: 285.0,
                                autoPlay: true,
                                initialPage: 0,
                                viewportFraction: 0.9,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                scrollDirection: Axis.horizontal,
                              ),
                              items: (listImage != null && listImage.length > 0)
                                  ? listImage.map((e) {
                                return Builder(
                                  builder: (context) {
                                    return InkWell(
                                      onTap: () {},
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),
                                        child: Material(
                                          elevation: 5,
                                          borderRadius:
                                          BorderRadius.circular(20.0),
                                          clipBehavior: Clip.hardEdge,
                                          child: Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width *
                                                0.90,
//                                            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                                            decoration: BoxDecoration(
                                              color: white_color,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20.0),
                                            ),
                                            child:Image.asset('images/'+e.banner_image, fit: BoxFit.fill,)
                                            /* Image.network(
                                              imageBaseUrl +
                                                  e.banner_image,
                                              fit: BoxFit.fill,
                                            ),

                                             */
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList()
                                  : listImages.map((e) {
                                return Builder(builder: (context) {
                                  return Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width *
                                        0.90,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                    ),
                                    child: Shimmer(
                                      duration: Duration(seconds: 3),
                                      //Default value
                                      color: Colors.white,
                                      //Default value
                                      enabled: true,
                                      //Default value
                                      direction:
                                      ShimmerDirection.fromLTRB(),
                                      //Default Value
                                      child: Container(
                                        color: kTransparentColor,
                                      ),
                                    ),
                                  );
                                });
                              }).toList()),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddressFrom()));
                            print("pressed");
                          },
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/delivery_man.png",
                                  height: 150,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                RaisedButton(
                                  elevation: 1,
                                  highlightElevation: 3,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 7, bottom: 7),
                                    child: Text(
                                      translate("Nuevo Pedido"),
                                      style: TextStyle(
                                          color: kWhiteColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  color: kMainColor,
                                  highlightColor: kMainColor,
                                  focusColor: kMainColor,
                                  splashColor: kMainColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddressFrom()));
                                  },
                                ),
                              ],
                            ),
                          ))
                    ]))));
  }

  void firebaseMessagingListner() async {
    if (Platform.isIOS) iosPermission();
    firebaseMessaging.getToken().then((value) {
      setState(() {
        firebaseToken = value;
      });
      registerDevice(value);
    });
  }

  void iosPermission() {
    firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered.listen((event) {});
  }


  registerDevice(String firebaseTokenR) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = deviceToken;
    http.post(url, body: {
      'device_token': firebaseTokenR,
    }, headers: {'Accept': 'Application/json',
    'Authorization': 'Bearer ' + prefs.getString('api_token')
    }).then((value) {
      print(value);
      prefs.setString('device_token', firebaseTokenR);
    });
  }

  void hitService() async {
    var url = vendorUrl;
    var response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<VendorList> tagObjs = tagObjsJson
              .map((tagJson) => VendorList.fromJson(tagJson))
              .toList();
          setState(() {
            nearStores.clear();
            nearStores = tagObjs;
          });
        }
      }
    } on Exception catch (_) {
      Timer(Duration(seconds: 5), () {
        hitService();
      });
    }
  }

  void hitBannerUrl() async {
    setState(() {
      isFetch = true;
    });
    var url = bannerUrl;
    http.get(url).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          if (tagObjs.isNotEmpty) {
            setState(() {
              listImage.clear();
              listImage = tagObjs;
            });
          } else {
            setState(() {
              isFetch = false;
            });
          }
        } else {
          setState(() {
            isFetch = false;
          });
        }
      } else {
        setState(() {
          isFetch = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isFetch = false;
      });
    });
  }

  void hitNavigator(context, category_name, ui_type, vendor_category_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (ui_type == "grocery" || ui_type == "Grocery" || ui_type == "1") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StoresPage(category_name, vendor_category_id)));
    } else if (ui_type == "resturant" ||
        ui_type == "Resturant" ||
        ui_type == "2") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Restaurant("Urbanby Resturant")));
    } else if (ui_type == "pharmacy" ||
        ui_type == "Pharmacy" ||
        ui_type == "3") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StoresPharmaPage('${category_name}', vendor_category_id)));
    } else if (ui_type == "parcal" || ui_type == "Parcal" || ui_type == "4") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => ParcalStoresPage('${vendor_category_id}')));
              builder: (context) => ParcalStoresPage()));
    }
  }

  void getBackResult(latss, lngss) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("lat", latss.toStringAsFixed(8));
    prefs.setString("lng", lngss.toStringAsFixed(8));
    double lats = double.parse(prefs.getString('lat'));
    double lngs = double.parse(prefs.getString('lng'));
    final coordinates = new Coordinates(lats, lngs);
    await Geocoder.local
        .findAddressesFromCoordinates(coordinates)
        .then((value) {
      if (value[0].locality != null && value[0].locality.isNotEmpty) {
        setState(() {
          this.lat = lat;
          this.lng = lng;
          String city = '${value[0].locality}';
          cityName = '${city.toUpperCase()} (${value[0].subLocality})';
        });
      } else if (value[0].subAdminArea != null &&
          value[0].subAdminArea.isNotEmpty) {
        this.lat = lat;
        this.lng = lng;
        String city = '${value[0].subAdminArea}';
        cityName = '${city.toUpperCase()}';
      }
      hitService();
      hitBannerUrl();
    });
  }
}
