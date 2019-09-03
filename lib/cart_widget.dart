import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Cart extends StatelessWidget {
  final Widget image;
  final String price;
  final double height, width;


  Cart({this.image, this.height, this.width, this.price});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      child: Column(
        children: <Widget>[
          image,
          Container(
            color: Colors.green,
            height: 30,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Text("Price",
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    )),
                SizedBox(
                  width: 50,
                ),
                Text(price,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    )),
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: FlatButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(Icons.add_shopping_cart),
                    Text('Add To Cart')
                  ],
                ),
                onPressed: () {},
                color: Theme.of(context).backgroundColor,
              ))
        ],
      ),
    );
  }
}
