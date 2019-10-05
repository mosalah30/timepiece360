import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Products extends StatefulWidget {
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String _currentUser, totalBill;
  int _overallBill = 0;

  Widget _titleText(String text) => Padding(
        padding: EdgeInsets.all(5),
        child: Text(
          text,
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: ListView(
        children: <Widget>[
          FutureBuilder(
            future: _getCurrentUserItemCard(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      return Column(
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.all(5),
                              width: MediaQuery.of(context).size.width,
                              child: Dismissible(
                                onDismissed: (dir) {
                                  setState(() {
                                    _removeItem(snapshot.data[index].data['id']);
                                    snapshot.data.removeAt(index);
                                    _getCurrentUserItemCard();


                                  });
                                  Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                    content: Text(
                                             'Item Removed'
                                           ),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      onPressed: () {},
                                    ),
                                  ));
                                },
                                child: Card(
                                  child: ListTile(
                                    title: _titleText('price  \$ ' +
                                        snapshot.data[index].data['price']),
                                    leading: Container(
                                      margin: EdgeInsets.all(5),
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(snapshot
                                            .data[index].data['imageName']),
                                      ),
                                    ),
                                    subtitle: _titleText('quantity  ' +
                                        snapshot.data[index].data['quantity']),
                                    trailing: Container(
                                      width: 90,
                                      child: Column(
                                        children: <Widget>[
                                          _titleText('Total'),
                                          Expanded(
                                              child: _titleText('\$ ' +
                                                  snapshot.data[index]
                                                      .data['total']))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                key:
                                    Key(snapshot.data[index].data['id']),
                                background: Container(
                                  padding: EdgeInsets.all(8),
                                  color: Colors.red,
                                  child: Icon(Icons.delete),
                                  alignment: Alignment.centerLeft,
                                ),secondaryBackground: Container(
                                color: Colors.red,
                                child: Icon(Icons.delete),
                                alignment: Alignment.centerRight,
                              ),
                              )),
                          Divider()
                        ],
                      );
                    },
                  ),
                );
              }
              return Center(
                child: Container(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ),
                ),
              );
            },
          ),
          Divider(),
          Container(
              child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(
                    height: 40,
                    child:
                        Card(child: Center(child: _titleText("Overall Bill")))),
              ),
              Expanded(
                  child: Container(
                      height: 40,
                      child: Card(
                          child: Center(
                              child: _titleText(
                                  '\$ ' + _overallBill.toString()))))),
            ],
          ))
        ],
      ),
    );
  }

  _removeItem(String nameItem) async {
    await Firestore.instance
        .collection('users')
        .document('user')
        .collection(_currentUser)
        .document('cart')
        .collection('id')
        .document(nameItem)
        .delete();
  }


  _getCurrentUserItemCard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser = prefs.getString('email').toString();
    });
    var documents = await Firestore.instance
        .collection('users')
        .document('user')
        .collection(_currentUser)
        .document('cart')
        .collection('id')
        .getDocuments();
    var _bill = 0;
    documents.documents.forEach((index) {
      _bill += int.parse(index.data['total']);
    });
    setState(() {
      _overallBill = _bill;
    });
    return documents.documents;
  }
}
