import 'package:flutter/material.dart';
import 'package:user/NewParcel/models/OrderDetails.dart';
import 'package:user/Themes/colors.dart';


// ignore: must_be_immutable
class DeliveryAddressesItemWidget extends StatelessWidget {
  String heroTag;
  final OrderDetails orderDetails;


  DeliveryAddressesItemWidget({Key key, this.orderDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return buildItem(context);
  }

  InkWell buildItem(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: Theme.of(context).accentColor),
                  child: Icon(Icons.place,
                    color: Theme.of(context).primaryColorLight,
                    size: 38,
                  ),
                ),
              ],
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          orderDetails.location.address,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(color: white_color,)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
