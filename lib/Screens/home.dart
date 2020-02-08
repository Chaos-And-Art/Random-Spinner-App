import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:spinner/Screens/pre_made.dart';
import 'package:spinner/UI/navigate.dart';
import 'package:flutter/material.dart';
import 'package:spinner/Screens/spinner.dart';
import 'package:spinner/Screens/spinner_edits.dart';
import 'package:spinner/Services/database.dart';
import 'package:spinner/UI/widgetsAndClasses.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/database.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Size get size => Size(MediaQuery.of(context).size.width * .38,
      MediaQuery.of(context).size.width * .38);

  double itemRotate(int index) => (index / itemsList.length) * 2 * pi;

  Color hexToColorBackground(String hexString) {
    return Color(int.parse(hexString.replaceFirst('#', '0xFF')));
  }

  Color hexToColorText(String hexString) {
    return Color(int.parse(hexString.replaceFirst('#', '0xFF')));
  }

  ItemsModel currentItem;
  List<ItemsModel> itemsList = [];
  SpinnerModel currentSpinner;
  List<SpinnerModel> spinnerList = [];

  Image setImage;
  Uint8List pngBytes;

  double defaultTextSize = 12;
  bool header = true;

  @override
  void initState() {
    //  SpinnerDatabase.db.deleteAllSpinner();
    //  ItemsDatabase.db.deleteAllItems();
    super.initState();
    SpinnerDatabase.db.init();
    setSpinnerFromDB();
    setItemsFromDB();
  }

  void setItemsFromDB() async {
    var fetchedItems = await ItemsDatabase.db.getItemsFromDB();
    setState(() {
      itemsList = fetchedItems;
    });
  }

  void setSpinnerFromDB() async {
    var fetchedSpinner = await SpinnerDatabase.db.getSpinnerFromDB();
    setState(() {
      spinnerList = fetchedSpinner;
    });
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    //  prefs.remove('spinnerCount');
  }

  @override
  Widget build(BuildContext context) {
    if (spinnerList.length >= 1) {
      header = false;
    } else if (spinnerList.length <= 0) {
      header = true;
    }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          title: Text("Random Spinner"),
          backgroundColor: Colors.blueGrey,
        ),
      ),
      endDrawer: Drawer(
        child: menu(context),
      ),
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: 200,
                child: FlatButton.icon(
                  onPressed: () {
                    ItemsDatabase.db.deleteAllItems();
                    createNewSpinner();
                    createTemp();
                    Future.delayed(Duration(milliseconds: 50), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpinnerEdits(
                            isNew: true,
                            existingSpinner: currentSpinner,
                            isImageNew: true,
                          ),
                        ),
                      );
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  color: Colors.green[400],
                  icon: Icon(Icons.add),
                  label: Text("New Spinner"),
                ),
              ),
              Container(
                width: 200,
                child: FlatButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreMadeList(),
                      ),
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  color: Colors.green[400],
                  icon: Icon(Icons.public),
                  label: Text("Pre-Made Spinners"),
                ),
              ),
            ],
          ),
          greeting(),
          for (var spinners in spinnerList) ...{spinnerCards(spinners)},
        ],
      ),
      floatingActionButton: Container(
        width: 80.0,
        height: 80.0,
        child: RawMaterialButton(
            shape: CircleBorder(),
            elevation: 0.0,
            fillColor: Colors.blueGrey,
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 40,
            ),
            onPressed: () {
              createNewSpinner();
              createTemp();
              Future.delayed(Duration(milliseconds: 50), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpinnerEdits(
                      isNew: true,
                      existingSpinner: currentSpinner,
                      isImageNew: true,
                    ),
                  ),
                );
              });
            }),
      ),
    );
  }

  createNewSpinner() async {
    addIntToSP();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int amount = prefs.getInt('spinnerCount') ?? 0;

    setState(() {
      currentSpinner =
          SpinnerModel(title: '', getItemPath: '', imageByte: '', textSize: 15);
      currentSpinner.getItemPath = 'spinner' + amount.toString() + '.db';
    });
    SpinnerDatabase.db.updateSpinnerInDB(currentSpinner);
    ItemsDatabase.db.setPath(currentSpinner);
  }

  addIntToSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int add = prefs.getInt('spinnerCount') ?? 0;
    add++;
    prefs.setInt('spinnerCount', add);
  }

  createTemp() async {
    Future.delayed(Duration(milliseconds: 50), () {
      currentItem = ItemsModel(name: '', backColor: "0xFF", textColor: "0xFF");
      ItemsDatabase.db.addItemsInDB(currentItem);

      ItemsDatabase.db.updateItemsInDB(currentItem);
    });
  }

  Widget greeting() {
    return Visibility(
      visible: header,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
          child: Column(
            children: <Widget>[
              Text(
                "You haven't created a Spinner yet! Press the + button to get started!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Or select 'Pre-Made Spinners' at the top of your screen to explore some of our Pre-Made Spinners.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              ButtonTheme(
                child: RaisedButton(
                  onPressed: () {
                    ItemsDatabase.db.deleteAllItems();
                    createNewSpinner();
                    createTemp();
                    Future.delayed(Duration(milliseconds: 50), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpinnerEdits(
                            isNew: true,
                            existingSpinner: currentSpinner,
                            isImageNew: true,
                          ),
                        ),
                      );
                    });
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget spinnerCards(SpinnerModel spinnerData) {
    return RawMaterialButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Spinner(
              existingSpinner: spinnerData,
              newImage: false,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
        height: 185,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    width: 150,
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(200),
                      ),
                    ),
                    child: Text(
                      spinnerData.title,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 0,
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            deleteSpinner(spinnerData);
                          });
                        },
                        child: Icon(Icons.delete),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(right: 5),
              child: setImage = Image.memory(
                pngBytes = base64Decode(spinnerData.imageByte),
                height: 175,
                width: 175,
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  deleteSpinner(SpinnerModel spinnerData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: <Widget>[
              Text(
                "Are you sure you want to delete this Spinner",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          content: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ItemsDatabase.db.setPath(spinnerData);
                    ItemsDatabase.db.deleteAllItems();
                    SpinnerDatabase.db.deleteSpinnerInDB(spinnerData);
                    Navigator.push(context, NoRoute(page: Home()));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  color: Colors.red[400],
                  child: Text(
                    "Yes",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  color: Colors.green[400],
                  child: Text(
                    "No",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
