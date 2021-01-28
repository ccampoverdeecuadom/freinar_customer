
class SenderAddress {
  dynamic lat;
  dynamic lng;
  dynamic houseNumber;
  dynamic pinCode;
  dynamic city;
  dynamic detailsAddress;
  dynamic secondaryStreet;
  dynamic mainStreet;
  dynamic phone;
  dynamic nameController;

  SenderAddress(
      this.lat,
      this.lng,
      this.houseNumber,
      this.pinCode,
      this.city,
      this.detailsAddress,
      this.secondaryStreet,
      this.mainStreet,
      this.phone,
      this.nameController);

  @override
  String toString() {
    return 'SenderAddress{lat: $lat, lng: $lng, houseNumber: $houseNumber, pinCode: $pinCode, city: $city, detailsAddress: $detailsAddress, secondaryStreet: $secondaryStreet, mainStreet: $mainStreet, phone: $phone, nameController: $nameController}';
  }
}