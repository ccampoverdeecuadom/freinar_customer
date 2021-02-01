import 'dart:core';

import 'package:user/NewParcel/models/originDetail.dart';
import 'package:user/NewParcel/models/parcel.dart';
import 'package:user/bean/resturantbean/address_data.dart';

class Destination extends OriginDetail{
  AddressData location;
  bool delivered;
  String observation;
  int orderBy;
  List<Parcel> parcels;

  Destination(double lat, double lng, String houseNumber, String postalCode, String addressReferences, String secondaryStreet, String mainStreet, String phone, String name, int orderBy, List<Parcel> parcels, AddressData location) : super(lat, lng, houseNumber, postalCode, addressReferences, secondaryStreet, mainStreet, phone, name){
    this.orderBy = orderBy;
    this. parcels = parcels;
    this.location = location;
  }


}