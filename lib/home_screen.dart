import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timepiece360/products.dart';
import 'package:timepiece360/profie_screen.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:easy_dialog/easy_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final List<Widget> _children = [_Screen(), Products(), ProfileScreen()];
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  _logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacementNamed(context, "/LoginScreen");
  }

  _itemChoice(String choice) {
    if (choice == 'Sign Out') {
      _logout();
    }
  }

  List<String> _popUpItemMenu = ['Sign Out'];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            title: Text('cart'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text('Profile'))
        ],
      ),
      body: _children[_currentIndex],
      appBar: AppBar(
        // to hide back arrow
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Container(margin: EdgeInsets.all(5), child: Icon(Icons.search)),
          Container(
              margin: EdgeInsets.all(5), child: Icon(Icons.shopping_cart)),
          PopupMenuButton<String>(
              onSelected: _itemChoice,
              itemBuilder: (BuildContext context) {
                return _popUpItemMenu.map((String choice) {
                  return PopupMenuItem<String>(
                      value: choice, child: Text(choice));
                }).toList();
              }),
        ],
        title: Text('MainScreen'),
      ),
    );
  }
}

class _Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyScreen();
  }
}

class _MyScreen extends State<_Screen> {
  String _currentUser;
  static final _tapList = <Image>[
    Image(
      fit: BoxFit.fill,
      image: AssetImage("images/21.jpg"),
    ),
    Image(
      fit: BoxFit.fill,
      image: AssetImage("images/22.png"),
    ),
    Image(
      fit: BoxFit.fill,
      image: AssetImage("images/23.png"),
    ),
    Image(
      fit: BoxFit.fill,
      image: AssetImage("images/24.png"),
    ),
    Image(
      fit: BoxFit.fill,
      image: AssetImage("images/25.png"),
    ),
    Image(
      fit: BoxFit.fill,
      image: AssetImage("images/26.png"),
    ),
    Image(
      fit: BoxFit.fill,
      image: AssetImage("images/27.png"),
    ),
  ];
  final _imagesList = <AssetImage>[
    AssetImage("images/1.jpg"),
    AssetImage("images/2.jpg"),
    AssetImage("images/3.jpg"),
    AssetImage("images/4.jpg"),
    AssetImage("images/5.jpg"),
    AssetImage("images/6.jpg"),
    AssetImage("images/7.jpg"),
    AssetImage("images/8.jpg"),
    AssetImage("images/9.jpg"),
    AssetImage("images/10.jpg"),
    AssetImage("images/11.jpg"),
    AssetImage("images/12.jpg"),
    AssetImage("images/13.jpg"),
    AssetImage("images/14.jpg"),
    AssetImage("images/15.jpg"),
    AssetImage("images/16.jpg"),
    AssetImage("images/17.jpg"),
    AssetImage("images/18.jpg"),
    AssetImage("images/19.jpg"),
    AssetImage("images/20.jpg"),
  ];
  final _listPrice = [
    4747,
    500,
    900,
    784,
    457,
    4582,
    1471,
    1231,
    14521,
    1457,
    145214,
    1478523,
    14587,
    14524,
    1452,
    1245,
    1478,
    14527,
    14527,
    2145,
  ];
  final _slider = Carousel(
    images: _tapList.map((i) {
      return Column(
        children: <Widget>[Expanded(child: Container(child: i))],
      );
    }).toList(),
    dotSize: 7.0,
    dotSpacing: 20.0,
    dotIncreaseSize: 2,
    dotColor: Colors.black,
    indicatorBgPadding: 8.0,
    dotBgColor: Colors.white30,
    borderRadius: true,
  );

  Widget title(String text) => Padding(
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

  final titleList = [
    'Brand',
    'Accessiory',
    'Buy',
    'Sell',
    'Repair',
    'ExChannge'
  ];

  _addToCart(String quantity, String imageName, int price) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentUser = prefs.getString('email').toString();
      String img = imageName.substring(7, 9);
      var total=price*int.parse(quantity)  ;

      try {
        print(img);
        await Firestore.instance
            .collection('users')
            .document('user')
            .collection(_currentUser)
            .document('cart')
            .collection("id")
            .document(img)
            .setData({
          "quantity": quantity.toString(),
          'imageName': imageName.toString(),
          'price': price.toString(),
          'total': total.toString()

        });
        setState(() {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text("product added to cart")));
        });
      } catch (e) {

        if (e != null) {
          setState(() {
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text("there are problem")));
          });
        }
      }
    } else {
      setState(() {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("no internet Connection")));
      });
    }
  }

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        color: Theme.of(context).accentColor,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: <Widget>[
            Container(height: 300, child: _slider),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Card(
                  color: Colors.green,
                  margin: EdgeInsets.only(left: 10),
                  child: title("OFFERS")),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      width: 105,
                      child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          elevation: 1.0,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                  child: GridTile(
                                child: Image(
                                  image: _imagesList[index],
                                  fit: BoxFit.fill,
                                ),
                              )),
                              Container(
                                color: Theme.of(context).backgroundColor,
                                height: 30,
                                child: Center(
                                  child: title(titleList[index]),
                                ),
                              )
                            ],
                          )));
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Card(
                  color: Colors.green,
                  margin: EdgeInsets.only(left: 10),
                  child: title('RECENT PRODUCTS')),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: GridView.builder(
                reverse: true,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _imagesList.length,
                itemBuilder: (BuildContext c, int index) {
                  return Container(
                      height: 150,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        elevation: 2.0,
                        child: Column(
                          children: <Widget>[
                            Container(
                                height: 160,
                                child: Image(
                                  image: _imagesList[index],
                                  fit: BoxFit.fill,
                                )),
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
                                  Text('${_listPrice[index]}   \$',
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Icon(Icons.add_shopping_cart),
                                      Text('Add To Cart')
                                    ],
                                  ),
                                  onPressed: () {
                                    EasyDialog(
                                        cornerRadius: 15.0,
                                        fogOpacity: 0.1,
                                        width: 300,
                                        height: 220,
                                        contentPadding:
                                            EdgeInsets.only(top: 12.0),
                                        // Needed for the button design
                                        contentList: [
                                          Container(
                                              color: Theme.of(context)
                                                  .backgroundColor,
                                              child: Card(
                                                  color: Colors.green,
                                                  child: title(
                                                      'Choose Quantity'))),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              width: 250,
                                              child: Row(
                                                children: <Widget>[
                                                  Flexible(
                                                    child: TextField(
                                                      controller:
                                                          _textController,
                                                      maxLines: 1,
                                                      maxLength: 5,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration: InputDecoration(
                                                          labelText:
                                                              'Enter your Quantity',
                                                          border: OutlineInputBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)))),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  FlatButton(
                                                      child: Card(
                                                          color: Theme.of(
                                                                  context)
                                                              .backgroundColor,
                                                          child:
                                                              title("Cancel")),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop()),
                                                  FlatButton(
                                                      child: Card(
                                                          color: Colors.green,
                                                          child: title("Save")),
                                                      onPressed: () {
                                                        if (_textController
                                                            .text.isNotEmpty) {
                                                          _addToCart(
                                                              _textController
                                                                  .text,
                                                              _imagesList[index]
                                                                  .assetName,
                                                              _listPrice[index]
                                                                  );
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]).show(context);
                                  },
                                  color: Theme.of(context).backgroundColor,
                                ))
                          ],
                        ),
                      ));
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 1.60),
                ),
              ),
            )
          ],
        ));
  }
}
