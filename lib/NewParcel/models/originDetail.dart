
class OriginDetail {
  double lat;
  double lng;
  String houseNumber;
  String postalCode;
  String addressReferences;
  String secondaryStreet;
  String mainStreet;
  String phone;
  String name;
  double payValue;


  OriginDetail(
      this.lat,
      this.lng,
      this.houseNumber,
      this.postalCode,
      this.addressReferences,
      this.secondaryStreet,
      this.mainStreet,
      this.phone,
      this.name);

  @override
  String toString() {

    return
        'Nombre: $name\n'
        'Calle Principal: $mainStreet\n'
        'Calle Secundaria: $secondaryStreet\n'
        'Casa: $houseNumber\n'
        'Teléfono: $phone';
  }
}