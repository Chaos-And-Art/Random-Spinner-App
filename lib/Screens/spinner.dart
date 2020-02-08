import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spinner/Screens/home.dart';
import 'package:spinner/Screens/spinner_edits.dart';

import 'package:spinner/Services/database.dart';
import 'package:spinner/UI/arrow_view.dart';

import 'package:spinner/UI/widgetsAndClasses.dart';

class Spinner extends StatefulWidget {
  final SpinnerModel existingSpinner;
  final bool newImage;

  Spinner({this.existingSpinner, this.newImage});

  @override
  _SpinnerState createState() => _SpinnerState(existingSpinner, newImage);
}

class _SpinnerState extends State<Spinner> with SingleTickerProviderStateMixin {
  _SpinnerState(this.currentSpinner, this.isImageNew);

  bool volume = true;
  bool isLoaded = false;
  bool isImageNew = true;

  AnimationController animationController;
  Animation animation;
  var _duration = Duration(seconds: 5);
  var _curve = Curves.fastLinearToSlowEaseIn;

  List<TimeDuration> _timeDuration = TimeDuration.time();
  List<DropdownMenuItem<TimeDuration>> _dropDownMenuItemTime;
  TimeDuration _selectedTime;

  List<SpinType> _spinType = SpinType.spin();
  List<DropdownMenuItem<SpinType>> _dropDownMenuItemSpin;
  SpinType _selectedSpin;

  double angle = 0;
  double current = 0;
  double initial;
  double distance;
  double newAngle = .1;
  bool touchSpin = false;
  bool backwardSpin = false;

  Size get size => Size(MediaQuery.of(context).size.width * .9,
      MediaQuery.of(context).size.width * .9);

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

  @override
  void initState() {
    super.initState();
    ItemsDatabase.db.setPath(currentSpinner);
    print(currentSpinner.getItemPath);
    setItemsFromDB();
    captureSpinner();

    animationController = AnimationController(vsync: this, duration: _duration);
    animation = CurvedAnimation(parent: animationController, curve: _curve);

    _dropDownMenuItemTime = buildDropdownMenuItemsTime(_timeDuration);
    _selectedTime = _dropDownMenuItemTime[4].value;
    _dropDownMenuItemSpin = buildDropdownMenuItemsSpin(_spinType);
    _selectedSpin = _dropDownMenuItemSpin[0].value;
  }

  void setItemsFromDB() async {
    var fetchedItems = await ItemsDatabase.db.getItemsFromDB();
    setState(() {
      itemsList = fetchedItems;
      isLoaded = true;
    });
  }

  GlobalKey globalKey = GlobalKey();
  Uint8List pngBytes;
  String base64;
  Image setImage;

  captureSpinner() {
    Future.delayed(Duration(milliseconds: 800), () async {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage();
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      pngBytes = byteData.buffer.asUint8List();
      base64 = base64Encode(pngBytes);
      currentSpinner.imageByte = base64;
      if (isImageNew) {
        SpinnerDatabase.db.addSpinnerInDB(currentSpinner);
        isImageNew = false;
      } else {
        SpinnerDatabase.db.updateSpinnerInDB(currentSpinner);
      }
    });
  }

  List<DropdownMenuItem<TimeDuration>> buildDropdownMenuItemsTime(List times) {
    List<DropdownMenuItem<TimeDuration>> items = List();
    for (TimeDuration timeDuration in times) {
      items.add(DropdownMenuItem(
        value: timeDuration,
        child: Text(timeDuration.name),
      ));
    }
    return items;
  }

  List<DropdownMenuItem<SpinType>> buildDropdownMenuItemsSpin(List spin) {
    List<DropdownMenuItem<SpinType>> items = List();
    for (SpinType spinType in spin) {
      items.add(DropdownMenuItem(
        value: spinType,
        child: Text(spinType.name),
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          leading: ButtonTheme(
            minWidth: 5,
            child: FlatButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: Colors.blueGrey,
          actions: <Widget>[
            ButtonTheme(
              minWidth: 75,
              child: FlatButton(
                color: Colors.grey[600],
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    bottomLeft: Radius.circular(100),
                  ),
                ),
                child: volume ? Icon(Icons.volume_up) : Icon(Icons.volume_off),
                onPressed: () {
                  setState(() {
                    if (volume == true) {
                      volume = false;
                    } else if (volume == false) {
                      volume = true;
                    }
                  });
                },
              ),
            ),
            Container(
              color: Colors.grey[600],
              child: ButtonTheme(
                minWidth: 0,
                child: RaisedButton.icon(
                  color: Colors.grey[700],
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100),
                          bottomLeft: Radius.circular(100))),
                  icon: Icon(Icons.history),
                  label: Text(
                    'HISTORY',
                    style: TextStyle(letterSpacing: 1),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Container(
              color: Colors.grey[700],
              child: RaisedButton.icon(
                color: Colors.grey[800],
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                        bottomLeft: Radius.circular(100))),
                icon: Icon(Icons.edit),
                label: Text(
                  'EDIT',
                  style: TextStyle(letterSpacing: 1),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpinnerEdits(
                        isNew: false,
                        existingSpinner: currentSpinner, isImageNew: false,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: theSpinner(),
          ),
          SizedBox(
            height: 55,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                    "Spin Duration",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey),
                  ),
                  DropdownButton(
                    value: _selectedTime,
                    items: _dropDownMenuItemTime,
                    onChanged: timeChange,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(
                    "Spin Type",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey),
                  ),
                  DropdownButton(
                    value: _selectedSpin,
                    items: _dropDownMenuItemSpin,
                    onChanged: spinChange,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget theSpinner() {
    return RepaintBoundary(
      key: globalKey,
      child: Visibility(
        visible: isLoaded,
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
                height: size.height + 15,
                width: size.width + 15,
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
                      _buildTitle(),
                      Transform.rotate(
                        angle: !touchSpin
                            ? -(current + _angle) * 2 * pi
                            : newAngle,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            for (var items in itemsList) ...[
                              _buildColor(items)
                            ],
                            for (var items in itemsList) ...[_buildText(items)],
                          ],
                        ),
                      ),
                      Container(
                        height: size.height,
                        width: size.width,
                        child: ArrowView(),
                      ),
                      _spin(),
                      _result(_value),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
                hexToColorBackground(items.backColor).withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildText(ItemsModel items) {
    var _rotate = itemRotate(itemsList.indexOf(items));
    return Transform.rotate(
      angle: _rotate,
      child: Container(
        height: size.height / 1.5,
        width: size.width,
        alignment: Alignment.topCenter,
        child: RotationTransition(
          turns: AlwaysStoppedAnimation(90 / 360),
          child: Text(
            items.name,
            style: TextStyle(
                fontSize: currentSpinner.textSize.toDouble() * 1.6,
                fontWeight: FontWeight.w600,
                color: hexToColorText(items.textColor)),
          ),
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
          height: 72,
          width: 72,
          child: Text(
            "SPIN",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  int spinIndex(value) {
    var select = (2 * pi / itemsList.length / 2) / (2 * pi);
    return (((select + value) % 1) * itemsList.length).floor();
  }

  _result(_value) {
    var _index = spinIndex(_value * angle + current);
    String _asset = itemsList[_index].name;
    return Container(
      margin: EdgeInsets.fromLTRB(0, 490, 0, 0),
      child: Text(
        _asset,
        style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900),
      ),
    );
  }

  _buildTitle() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 460),
      child: Text(
        currentSpinner.title,
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
      ),
    );
  }

  timeChange(TimeDuration selectedTime) {
    setState(() {
      _selectedTime = selectedTime;
      _duration = Duration(seconds: _selectedTime.seconds);
      animationController.duration = _duration;
    });
  }

  spinChange(SpinType selectedSpin) {
    setState(() {
      _selectedSpin = selectedSpin;
      var type = _selectedSpin.name;
      switch (type) {
        case 'Standard':
          _curve = Curves.fastLinearToSlowEaseIn;
          animation =
              CurvedAnimation(parent: animationController, curve: _curve);
          break;
        case 'Bounce':
          animation = CurvedAnimation(
              parent: animationController, curve: Curves.bounceInOut);
          break;
        case 'Ease In':
          _curve = Curves.easeIn;
          animation =
              CurvedAnimation(parent: animationController, curve: _curve);
          break;
        case 'Reverse Start':
          _curve = Curves.easeInBack;
          animation =
              CurvedAnimation(parent: animationController, curve: _curve);
          break;
        case 'Elastic':
          animation = CurvedAnimation(
              parent: animationController, curve: Curves.elasticIn);
          break;
        case 'Slow Middle':
          _curve = Curves.slowMiddle;
          animation =
              CurvedAnimation(parent: animationController, curve: _curve);
          break;
        case 'Steady':
          _curve = Curves.easeOutSine;
          animation =
              CurvedAnimation(parent: animationController, curve: _curve);
          break;

        default:
          _curve = Curves.fastLinearToSlowEaseIn;
          animation =
              CurvedAnimation(parent: animationController, curve: _curve);
      }
    });
  }
}
