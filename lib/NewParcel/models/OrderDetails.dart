import 'dart:core';

import 'package:user/bean/resturantbean/address_data.dart';

class OrderDetails {
  dynamic nameReceiver;
  dynamic phoneReceiver;
  AddressData location;
  dynamic mainStreet;
  dynamic secondaryStreet;
  dynamic houseNumber;
  dynamic postalCode;
  dynamic city;
  List<dynamic> packages;

  OrderDetails(
      this.nameReceiver,
      this.phoneReceiver,
      this.location,
      this.mainStreet,
      this.secondaryStreet,
      this.houseNumber,
      this.postalCode,
      this.city,
      this.packages);
}