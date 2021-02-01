import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/NewParcel/models/Destination.dart';
import 'package:user/NewParcel/models/originDetail.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurlp/baseurl.dart';
import 'package:user/bean/paymentstatus.dart';
import 'package:user/NewParcel/parcelpaymentpage.dart';
import 'package:user/NewParcel/pharmacybean/parceladdress.dart';
import 'package:user/NewParcel/pharmacybean/parceldetail.dart';

import 'DeliveryAddressesItemWidget.dart';

class ParcelCheckOut extends StatefulWidget {
  final OriginDetail originAddress;
  final List<Destination> destinationsList;

  ParcelCheckOut(this.originAddress, this.destinationsList);

  @override
  State<StatefulWidget> createState() {
    return ParcelCheckoutState();
  }
}

class ParcelCheckoutState extends State<ParcelCheckOut> {
  dynamic currency = '';
  bool _isSenderCheck = false;

  TextEditingController senderPayValueController = new TextEditingController();
  List<TextEditingController> payDestinationsControllers;
  List<bool> payDestinationsCheck;

  double total;
  double sum;
  bool _isReadyToPay;

  @override
  void initState() {
    getCurrency();
    super.initState();
    getPayDestinationsValues();
    senderPayValueController.text = '0';
    total = 30;
    calculateCosts();
  }

  calculateCosts() {
    sum = double.parse(senderPayValueController.text);
    payDestinationsControllers.forEach((element) {
      sum = sum + double.parse(element.text);
    });
    _isReadyToPay = total == sum;
  }

  getPayDestinationsValues() {
    payDestinationsControllers = new List<TextEditingController>();
    payDestinationsCheck = new List();
    TextEditingController _payDestinationController;
    widget.destinationsList.forEach((destination) {
      _payDestinationController  = new TextEditingController();
      _payDestinationController.text = destination.payValue==null? '0' : destination.payValue.toString();
      payDestinationsControllers.add(_payDestinationController);
      payDestinationsCheck.add(true);
    });
  }

  void getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString('curency');
    });
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
            'Checkout',
            style: TextStyle(
                fontSize: 18, color: black_color, fontWeight: FontWeight.w400),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Pagos a realizar',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Container(
                color: kWhiteColor,
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width,
                padding:
                    EdgeInsets.only(top: 20.0, bottom: 20.0, left: 5, right: 10),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              "Emisor",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: _isSenderCheck
                                      ? Theme.of(context).accentColor
                                      : Theme.of(context).disabledColor),
                            ),
                            value: _isSenderCheck,
                            onChanged: (bool value) {
                              setState(() {
                                _isSenderCheck = value;
                                senderPayValueController.text = '0';
                              });
                            },
                            subtitle: new InkWell(
                              child: Text(
                                'Valor de cobro en el punto de recogida',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).disabledColor),
                              ),
                            ),
                          )),
                    ),
                    Expanded(child: Text('\$'),),
                    Expanded(
                        child: TextField(
                          onChanged: calculateCosts(),
                          keyboardType: TextInputType.number,
                      controller: senderPayValueController,
                      enabled: _isSenderCheck,
                    ))
                  ],
                )),
            SizedBox(
              height: 50,
            ),
          payDestinationsControllers==null || payDestinationsControllers.isEmpty ? Text('Sin Destinos'):
          ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 15),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: widget.destinationsList.length,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 15);
                },
                itemBuilder: (context, index) {
                  return Container(
                      color: kWhiteColor,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 5, right: 5),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 1.4,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: CheckboxListTile(
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(
                                    widget.destinationsList.elementAt(index).location.address,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: payDestinationsCheck.elementAt(index)
                                            ? Theme.of(context).accentColor
                                            : Theme.of(context).disabledColor),
                                  ),
                                  value: payDestinationsCheck.elementAt(index),
                                  onChanged: (bool value) {
                                    setState(() {
                                      payDestinationsCheck[index] = value;
                                      payDestinationsControllers[index].text = '0';
                                    });
                                  },
                                  subtitle: new InkWell(
                                    child: Text(
                                      'Valor de Cobro en este destino',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Theme.of(context).disabledColor),
                                    ),
                                  ),
                                )),
                          ),
                          Expanded(child: Text('\$'),),
                          Expanded(
                              child: TextField(
                                onChanged: calculateCosts(),
                            keyboardType: TextInputType.number,
                            controller: payDestinationsControllers.elementAt(index),
                            enabled: payDestinationsCheck.elementAt(index),
                          ))
                        ],
                      ));
                }),
            SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Costos de Envío',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Container(
              color: kWhiteColor,
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              padding:
                  EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20, right: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ingresado'),
                      Text('\$ $sum')
                      // Text('${currency} ${(double.parse('${double.parse('${widget.distanced}').toStringAsFixed(2)}') > 1) ? (double.parse('${double.parse('${widget.distanced}').toStringAsFixed(2)}') * double.parse('${widget.charges}')) : double.parse('${widget.charges}')}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total'),
                      Text('\$ $total')
                      // Text('${currency} ${(double.parse('${double.parse('${widget.distanced}').toStringAsFixed(2)}') > 1) ? (double.parse('${double.parse('${widget.distanced}').toStringAsFixed(2)}') * double.parse('${widget.charges}')) : double.parse('${widget.charges}')}'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: GestureDetector(
                onTap: () {
                  if(!_isReadyToPay){
                    Toast.show(
                        "Debe cubrir el total de envío", context,
                        gravity: Toast.BOTTOM);
                  }
                  showProgressDialog(
                      'please wait while we loading your request!', pr);
                  // getVendorPayment(widget.vendor_id, pr, context);
                },
                child: Card(
                  elevation: 2,
                  color: _isReadyToPay
                      ? Theme.of(context).accentColor
                      : kMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    height: 52,
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width - 100,
                    child: Text(
                      'Pagar en el lugar',
                      style: TextStyle(fontSize: 18,
                          color: kWhiteColor),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
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
}
