import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/Screens/home.dart';
import 'package:spinner/Screens/spinner.dart';
import 'package:spinner/Services/database.dart';
import 'package:spinner/UI/widgetsAndClasses.dart';
import 'package:spinner/UI/arrow_view.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SpinnerEdits extends StatefulWidget {
  final bool isNew;
  final bool isImageNew;
  final SpinnerModel existingSpinner;

  SpinnerEdits({this.isNew, this.existingSpinner, this.isImageNew});

  @override
  _SpinnerEditsState createState() =>
      _SpinnerEditsState(isNew, existingSpinner, isImageNew);
}

class _SpinnerEditsState extends State<SpinnerEdits>
    with SingleTickerProviderStateMixin {
  _SpinnerEditsState(this.isSpinnerNew, this.currentSpinner, this.isImageNew);

  bool isSpinnerNew = false;
  bool isImageNew = false;
  bool spinnerStillNew = false;
  bool isItemNew = true;
  bool isDirty = false;
  bool exitSave = false;
  bool editItemChanged = false;
  bool isLoaded = false;
  bool backColorChanged = false;
  bool textColorChanged = false;

  double angle = 0;
  double current = 0;
  double initial;
  double distance;
  double newAngle = .1;
  bool touchSpin = false;
  bool backwardSpin = false;

  static Color backgroundColor =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
  static Color textColor =
      Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);

  String hexBackground = '#${backgroundColor.value.toRadixString(16)}';
  String hexText = '#${textColor.value.toRadixString(16)}';

  Color hexToColorBackground(String hexString) {
    return Color(int.parse(hexString.replaceFirst('#', '0xFF')));
  }

  Color hexToColorText(String hexString) {
    return Color(int.parse(hexString.replaceFirst('#', '0xFF')));
  }

  ItemsModel currentItem;
  List<ItemsModel> itemsList = [];
  SpinnerModel currentSpinner;

  AnimationController animationController;
  Animation animation;
  var _duration = Duration(seconds: 5);
  var _curve = Curves.fastLinearToSlowEaseIn;

  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();

  TextEditingController titleController = TextEditingController();
  TextEditingController itemTitleController = TextEditingController();

  static double textSize = 15;
  int textSizeX = 15;

  @override
  void initState() {
    super.initState();

    ItemsDatabase.db.setPath(currentSpinner);
    setItemsFromDB();

    currentItem =
        ItemsModel(name: '', backColor: hexBackground, textColor: hexText);
    titleController.text = currentSpinner.title;
    textSize = currentSpinner.textSize.toDouble();

    animationController = AnimationController(vsync: this, duration: _duration);
    animation = CurvedAnimation(parent: animationController, curve: _curve);
    textSizeX = textSize.round();
  }

  void setItemsFromDB() async {
    if (!isLoaded) {
      Future.delayed(Duration(milliseconds: 200), () async {
        var fetchedItems = await ItemsDatabase.db.getItemsFromDB();
        setState(() {
          itemsList = fetchedItems;
          isLoaded = true;
        });
      });
    } else {
      var fetchedItems = await ItemsDatabase.db.getItemsFromDB();
      setState(() {
        itemsList = fetchedItems;
        isLoaded = true;
      });
    }
  }

  Size get size => Size(MediaQuery.of(context).size.width * .45,
      MediaQuery.of(context).size.width * .45);

  double itemRotate(int index) => (index / itemsList.length) * 2 * pi;

  @override
  Widget build(BuildContext context) {
    final double itemHeight = (size.height - kToolbarHeight - 24) / 1.8;
    final double itemWidth = size.width / 2;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: AppBar(
            backgroundColor: Colors.blueGrey,
            leading: ButtonTheme(
              minWidth: 5,
              child: FlatButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  checkIfSaved();
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
            actions: <Widget>[
              AnimatedContainer(
                margin: EdgeInsets.only(left: 10),
                duration: Duration(milliseconds: 200),
                width: isDirty ? 125 : 0,
                height: 42,
                curve: Curves.decelerate,
                child: RaisedButton.icon(
                  color: Colors.green[400],
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100),
                          bottomLeft: Radius.circular(100))),
                  icon: Icon(Icons.done),
                  label: Text(
                    'SAVE',
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    exitSave = true;
                    saveAlert();
                    saveSpinner();
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              )
            ],
          ),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              height: 50,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                focusNode: titleFocus,
                controller: titleController,
                autofocus: isSpinnerNew,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 1,
                onSubmitted: (text) {
                  //Title
                },
                onChanged: (value) {
                  markAsDirty(value);
                },
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    hintText: 'Title',
                    hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 28,
                        fontWeight: FontWeight.w600),
                    border: InputBorder.none,
                    suffixIcon: Icon(
                      Icons.edit,
                      color: Colors.black,
                    )),
              ),
            ),
            Container(
              height: 255,
              width: 190,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Preview",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Divider(
                    height: 3,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: isLoaded,
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onPanStart: (DragStartDetails details) {
                          if (!animationController.isAnimating) {
                            touchSpin = true;
                            initial = details.globalPosition.dx;
                          }
                        },
                        onPanUpdate: (DragUpdateDetails details) {
                          distance = details.globalPosition.dx - initial;
                          setState(() {
                            if (1 < distance || distance < 1) {
                              newAngle = -(distance) * 2 * pi / 300;
                            }
                          });
                        },
                        onPanEnd: (DragEndDetails details) {
                          touchSpin = false;
                          initial = 0.0;

                          if (distance > 90) {
                            backwardSpin = false;
                            _animation();
                          } else if (distance < -90) {
                            backwardSpin = true;
                            _animation();
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              height: size.height + 8,
                              width: size.width + 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                                //boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black54)],
                              ),
                            ),
                            AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                final _value = animation.value;
                                final _angle = _value * angle;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Transform.rotate(
                                      angle: !touchSpin
                                          ? -(current + _angle) * 2 * pi
                                          : newAngle,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          for (var items in itemsList) ...{
                                            _buildColor(items)
                                          },
                                          for (var items in itemsList) ...{
                                            _buildText(items)
                                          },
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 140,
                                      width: 20,
                                      padding: EdgeInsets.only(top: 45),
                                      child: ArrowView(),
                                    ),
                                    _spin(),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Item List",
                            style: TextStyle(fontSize: 22),
                          ),
                          ButtonTheme(
                            minWidth: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            )),
                            child: FlatButton.icon(
                              onPressed: () {
                                itemNew(currentItem);
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                itemTitleController.clear();
                              },
                              color: Colors.blueGrey,
                              label: Text(
                                'Add Item',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              icon: Icon(
                                Icons.add,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 250,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 4),
              margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: (itemWidth / itemHeight),
                children: <Widget>[
                  ...buildItemsCard(),
                  //Text(itemsList.length.toString())
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              children: <Widget>[
                Container(
                  height: 130,
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 5),
                      Text(
                        "$textSizeX",
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500),
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          trackShape: CustomTrackShape(),
                        ),
                        child: Slider(
                          onChanged: (double newTextSize) {
                            setState(() {
                              textSize = newTextSize;
                              textSizeX = textSize.round();
                            });
                            markAsDirty(newTextSize.toString());
                          },
                          value: textSize,
                          min: 1,
                          max: 25,
                          activeColor: Colors.blueGrey,
                          inactiveColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Text Size",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildItemsCard() {
    List<Widget> itemComponentsList = [];

    itemsList.forEach((item) {
      itemComponentsList.add(
        ItemsCard(itemData: item, onTapAction: itemEdit),
      );
    });
    if (isSpinnerNew) {
      itemComponentsList.removeAt(0);
      if (itemsList.length == 3) {
        deleteItem(itemsList.first);
        isSpinnerNew = false;
        spinnerStillNew = true;
      }
    }

    return itemComponentsList;
  }

  deleteItem(ItemsModel itemData) async {
    await ItemsDatabase.db.deleteItemsInDB(itemData);
    setItemsFromDB();
  }

  itemNew(ItemsModel itemData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          content: Container(
            height: 400,
            child: Column(
              children: <Widget>[
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    "New Item",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 50,
                  width: 210,
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: itemTitleController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 1,
                    onSubmitted: (text) {
                      //Title
                    },
                    onChanged: (value) {
                      markAsDirty(value);
                    },
                    cursorColor: textColor,
                    cursorWidth: 3,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                        hintText: "Type Here",
                        hintStyle: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w400),
                        contentPadding: EdgeInsets.all(0),
                        border: InputBorder.none,
                        suffixIcon: Icon(
                          Icons.edit,
                          color: Colors.black,
                        )),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Text(
                        "Background Color",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    RawMaterialButton(
                      fillColor: backgroundColor,
                      shape: CircleBorder(),
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        width: 30,
                      ),
                      onPressed: () {
                        colorPicker(true, false, itemData);
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                  color: Colors.black,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Text(
                        "Text Color",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    RawMaterialButton(
                      fillColor: textColor,
                      shape: CircleBorder(),
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        width: 30,
                      ),
                      onPressed: () {
                        colorPicker(false, false, itemData);
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                  color: Colors.black,
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      color: Colors.orange[400],
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        isItemNew = true;
                        isDirty = true;
                        _saveItem(itemData);
                        setItemsFromDB();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      color: Colors.green[400],
                      child: Text(
                        "Add",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  itemEdit(ItemsModel itemData) {
    if (editItemChanged) {
      itemTitleController.text = itemTitleController.text;
      itemData.backColor = hexBackground;
      itemData.textColor = hexText;
    } else {
      itemTitleController.text = itemData.name;
      currentItem = ItemsModel(
          name: itemData.name,
          backColor: itemData.backColor,
          textColor: itemData.textColor);
    }
    // if (!isSpinnerNew) {
    //   currentItem = ItemsModel(
    //       name: itemData.name, backColor: itemData.backColor, textColor: itemData.textColor);
    // }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          content: Container(
            height: 400,
            child: Column(
              children: <Widget>[
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Edit Item",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 50,
                  width: 210,
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: editItemChanged
                        ? backgroundColor
                        : hexToColorBackground(itemData.backColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: itemTitleController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 1,
                    onSubmitted: (text) {
                      //Title
                    },
                    onChanged: (value) {
                      markAsDirty(value);
                    },
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: editItemChanged
                          ? textColor
                          : hexToColorText(itemData.textColor),
                    ),
                    decoration: InputDecoration(
                        hintText: itemData.name,
                        hintStyle: TextStyle(
                            color: editItemChanged
                                ? textColor
                                : hexToColorText(itemData.textColor),
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                        contentPadding: EdgeInsets.all(0),
                        border: InputBorder.none,
                        suffixIcon: Icon(
                          Icons.edit,
                          color: Colors.black,
                        )),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Text(
                        "Background Color",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    RawMaterialButton(
                      fillColor: editItemChanged
                          ? backgroundColor
                          : hexToColorBackground(itemData.backColor),
                      shape: CircleBorder(),
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        width: 30,
                      ),
                      onPressed: () {
                        colorPicker(true, true, itemData);
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                  color: Colors.black,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Text(
                        "Text Color",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    RawMaterialButton(
                      fillColor: editItemChanged
                          ? textColor
                          : hexToColorText(itemData.textColor),
                      shape: CircleBorder(),
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        width: 30,
                      ),
                      onPressed: () {
                        colorPicker(false, true, itemData);
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                  color: Colors.black,
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        editItemChanged = false;
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      color: Colors.orange[400],
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        isItemNew = false;
                        editItemChanged = false;
                        isDirty = true;
                        _saveItem(itemData);
                        setItemsFromDB();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      color: Colors.green[400],
                      child: Text(
                        "Confirm",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  onPressed: () {
                    if (itemsList.length <= 2) {
                      deleteSpinner();
                    } else {
                      handleDelete(itemData);
                      editItemChanged = false;
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  color: Colors.red[400],
                  child: Text(
                    "Delete",
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

  _saveItem(ItemsModel itemData) async {
    if (isItemNew) {
      setState(() {
        currentItem.name = itemTitleController.text;
        currentItem.backColor = hexBackground;
        currentItem.textColor = hexText;
      });

      var latestItem = await ItemsDatabase.db.addItemsInDB(currentItem);
      setState(() {
        currentItem = latestItem;
      });

      await ItemsDatabase.db.updateItemsInDB(currentItem);
    } else if (!isItemNew) {
      if (backColorChanged == true || textColorChanged == true) {
        setState(() {
          itemData.name = itemTitleController.text;
          if (backColorChanged) {
            itemData.backColor = hexBackground;
          } else if (textColorChanged) {
            itemData.textColor = hexText;
          }
          backColorChanged = false;
          textColorChanged = false;
        });
      } else {
        itemData.name = itemTitleController.text;
        itemData.backColor = currentItem.backColor;
        itemData.textColor = currentItem.textColor;
      }

      await ItemsDatabase.db.updateItemsInDB(itemData);
    }
  }

  changeBackgroundColor(Color color) {
    setState(() {
      backgroundColor = color;
      hexBackground = '#${backgroundColor.value.toRadixString(16)}';
      backColorChanged = true;
    });
  }

  changeTextColor(Color color) {
    setState(() {
      textColor = color;
      hexText = '#${textColor.value.toRadixString(16)}';
      textColorChanged = true;
    });
  }

  colorPicker(bool backGround, bool edit, ItemsModel itemData) {
    if (edit) {
      if (!editItemChanged) {
        if (backGround) {
          backgroundColor = hexToColorBackground(itemData.backColor);
        }
        if (backGround == false) {
          textColor = hexToColorText(itemData.textColor);
        }
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ColorPicker(
                  pickerColor: backGround ? backgroundColor : textColor,
                  onColorChanged:
                      backGround ? changeBackgroundColor : changeTextColor,
                  colorPickerWidth: 500,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: true,
                  displayThumbColor: true,
                  enableLabel: false,
                  paletteType: PaletteType.hsv,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      color: Colors.red[400],
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          if (edit) {
                            if (backGround) {
                              backgroundColor =
                                  hexToColorBackground(itemData.backColor);
                            }
                            if (backGround == false) {
                              textColor = hexToColorText(itemData.textColor);
                            }
                          }
                        });
                      },
                      child: Text("Cancel"),
                    ),
                    FlatButton(
                      color: Colors.green[400],
                      onPressed: () {
                        if (edit == false) {
                          setState(() {
                            if (backGround) {
                              backgroundColor = backgroundColor;
                            }
                            if (backGround == false) {
                              textColor = textColor;
                            }
                          });
                          Navigator.pop(context);
                          Navigator.pop(context);
                          itemNew(itemData);
                        } else if (edit == true) {
                          editItemChanged = true;
                          setState(() {
                            if (backGround) {
                              backgroundColor = backgroundColor;
                            }
                            if (backGround == false) {
                              textColor = textColor;
                            }
                          });
                          Navigator.pop(context);
                          Navigator.pop(context);
                          itemEdit(itemData);
                        }
                      },
                      child: Text("Confirm"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  checkIfSaved() {
    if (isDirty == false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Spinner(
            existingSpinner: currentSpinner,
            newImage: isImageNew,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: <Widget>[
                Text(
                  "The Spinner isn't saved!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  "Do you want to save before exiting?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Spinner(
                            existingSpinner: currentSpinner,
                            newImage: isImageNew,
                          ),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    color: Colors.red[400],
                    child: Text(
                      "No",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      exitSave = true;
                      saveAlert();
                      saveSpinner();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    color: Colors.green[400],
                    child: Text(
                      "Yes",
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

  deleteSpinner() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: <Widget>[
              Text(
                "You can't have less than two items!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                "Would you like to delete this Spinner?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
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
                    SpinnerDatabase.db.deleteSpinnerInDB(currentSpinner);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Home(),
                      ),
                    );
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

  markAsDirty(String title) {
    setState(() {
      isDirty = true;
    });
  }

  saveAlert() {
    var alert = AlertDialog(
      title: Text(
        "Successfully Saved",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      backgroundColor: Colors.grey[300],
    );
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.pop(context);
        });
        return alert;
      },
    );
  }

  saveSpinner() async {
    if (exitSave) {
      setState(() {
        currentSpinner.title = titleController.text;
        currentSpinner.textSize = textSize.toInt();
        if (itemsList.length <= 1) {
          FocusScope.of(context).requestFocus(FocusNode());
        } else {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Spinner(
                  existingSpinner: currentSpinner,
                  newImage: isImageNew,
                ),
              ),
            );
          });
        }
      });
      if (itemsList.length <= 1) {
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        // if (spinnerStillNew) {
        //   var latestSpinner =
        //       await SpinnerDatabase.db.addSpinnerInDB(currentSpinner);
        //   setState(() {
        //     currentSpinner = latestSpinner;
        //   });
        //   spinnerStillNew = false;
        // }

        await SpinnerDatabase.db.updateSpinnerInDB(currentSpinner);
      }
    } else {}
    setState(() {
      isDirty = false;
    });
  }

  handleDelete(ItemsModel itemData) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: <Widget>[
              Text(
                "This Item will be DELETED!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
          content: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    deleteItem(itemData);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  color: Colors.red[400],
                  child: Text(
                    "DELETE",
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
                  color: Colors.green[100],
                  child: Text(
                    "CANCEL",
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

  _buildColor(ItemsModel items) {
    var _rotate = itemRotate(itemsList.indexOf(items));
    var _angle = 2 * pi / itemsList.length;
    return Transform.rotate(
      angle: _rotate,
      child: ClipPath(
        clipper: WheelShape(_angle),
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                hexToColorBackground(items.backColor),
                hexToColorBackground(items.backColor).withOpacity(0)
              ])),
        ),
      ),
    );
  }

  _buildText(ItemsModel items) {
    var _rotate = itemRotate(itemsList.indexOf(items));
    return Transform.rotate(
      angle: _rotate,
      child: Container(
        height: size.height / 1.4,
        width: size.width,
        alignment: Alignment.topCenter,
        child: RotationTransition(
          turns: AlwaysStoppedAnimation(90 / 360),
          child: Text(items.name,
              style: TextStyle(
                fontSize: textSizeX.toDouble(),
                fontWeight: FontWeight.w600,
                color: hexToColorText(items.textColor),
              )),
        ),
      ),
    );
  }

  _spin() {
    return RawMaterialButton(
        fillColor: Colors.white,
        shape: CircleBorder(),
        child: Container(
          alignment: Alignment.center,
          height: 30,
          width: 30,
          child: Text(
            "SPIN",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        onPressed: () {
          _animation();
        });
  }

  _animation() {
    if (!animationController.isAnimating) {
      var _random = Random().nextDouble();
      if (backwardSpin) {
        angle = -10 + Random().nextInt(10) + _random;
      } else {
        angle = 10 + Random().nextInt(10) + _random;
      }
      animationController.forward(from: 0.0).then((_) {
        current = (current + _random);
        current = current - current ~/ 1;
        animationController.reset();
      });
    }
  }
}
