import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/global.dart';
import 'package:user/NewParcel/checkoutparcel.dart';
import 'package:user/NewParcel/receiveraddress.dart';
import 'package:user/NewParcel/models/originDetail.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/bean/resturantbean/address_data.dart';

import 'DeliveryAddressesItemWidget.dart';
import 'floating_modal.dart';
import 'fromtoaddress.dart';
import 'models/Destination.dart';

class OrdersWidget extends StatefulWidget {
  final OriginDetail senderAddress;

  const OrdersWidget(this.senderAddress);

  @override
  State<OrdersWidget> createState() {
    return new _OrdersWidget();
  }
}

class _OrdersWidget extends State<OrdersWidget> {
  List<Destination> destinationList;

  @override
  void initState() {
    destinationList = new List<Destination>();
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
              'Destinos',
              style: TextStyle(
                  fontSize: 18,
                  color: black_color,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showFloatingModalBottomSheet(
              context: context,
              builder: (context) => NewAddressTo(
                  isEditing: false,
                  senderAddress: widget.senderAddress,
                  orderAdded: (orderDetail, isEditing) {
                    addNewOrderDetails(orderDetail, isEditing, -1);
                  }),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: kMainColor,
        ),
        body: Container(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 180,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 10),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        leading: Icon(
                          Icons.domain,
                          color: Theme.of(context).hintColor,
                        ),
                        title: Text(
                          'Destinos de Entrega',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        subtitle: Text(
                          'Agrega uno o mas destinos a los que desee entregar sus pedidos.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: destinationList == null
                          ? SizedBox(
                              height: 0,
                            )
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: destinationList.length,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 15);
                              },
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    child: DeliveryAddressesItemWidget(
                                        orderDetails:
                                            destinationList.elementAt(index)),
                                    onTap: () => showFloatingModalBottomSheet(
                                          context: context,
                                          builder: (context) => NewAddressTo(
                                            senderAddress: widget.senderAddress,
                                            orderAdded:
                                                (orderDetail, isEditing) {
                                              addNewOrderDetails(orderDetail,
                                                  isEditing, index);
                                            },
                                            isEditing: true,
                                            destination: destinationList
                                                .elementAt(index),
                                          ),
                                        ));
                              },
                            ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: RaisedButton(
                    elevation: 1,
                    highlightElevation: 3,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 8, bottom: 8, left: 12, right: 12),
                      child: Text(
                        translate("Revisar"),
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
                              builder: (context) => ParcelCheckOut(
                                  widget.senderAddress, destinationList)));
                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }

  addNewOrderDetails(Destination orderDetails, bool isEditing, int index) {
    setState(() {
      if (isEditing) {
        destinationList[index] = orderDetails;
      } else {
        destinationList.add(orderDetails);
      }
    });
  }
}
