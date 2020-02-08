import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/Screens/home.dart';
import 'package:spinner/Screens/pre_made.dart';

Widget menu(BuildContext context) {
  return SafeArea(
    child: Column(
      children: <Widget>[
        Divider(
          height: 50.0,
          color: Colors.transparent,
        ),
        ListTile(
          title: Text('Home'),
          trailing: Icon(Icons.home),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          },
        ),
        Divider(
          height: 10.0,
          color: Colors.black,
          indent: 15.0,
          endIndent: 15.0,
        ),
        ListTile(
          title: Text('Pre-Made'),
          trailing: Icon(Icons.star),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreMadeList(),
              ),
            );
          },
        ),
        Divider(
          height: 10.0,
          color: Colors.black,
          indent: 15.0,
          endIndent: 15.0,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ListTile(
              title: Text('Close'),
              trailing: Icon(Icons.cancel),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    ),
  );
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight + 1;
    final double trackLeft = offset.dx + 10;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 1.5;
    final double trackWidth = parentBox.size.width - 20;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class WheelShape extends CustomClipper<Path> {
  final double angle;

  WheelShape(this.angle);

  @override
  Path getClip(Size size) {
    Path _path = Path();
    Offset _center = size.center(Offset.zero);
    Rect _rect = Rect.fromCircle(center: _center, radius: size.width / 2);
    _path.moveTo(_center.dx, _center.dy);
    _path.arcTo(_rect, -pi / 2 - angle / 2, angle, false);
    _path.close();
    return _path;
  }

  @override
  bool shouldReclip(WheelShape oldClipper) {
    return angle != oldClipper.angle;
  }
}

class TimeDuration {
  int seconds;
  String name;
  TimeDuration(this.seconds, this.name);

  static List<TimeDuration> time() {
    return <TimeDuration>[
      TimeDuration(1, "1 Second"),
      TimeDuration(2, "2 Seconds"),
      TimeDuration(3, "3 Seconds"),
      TimeDuration(5, "4 Seconds"),
      TimeDuration(6, "5 Seconds"),
      TimeDuration(7, "6 Seconds"),
      TimeDuration(9, "7 Seconds"),
      TimeDuration(10, "8 Seconds"),
      TimeDuration(12, "9 Seconds"),
      TimeDuration(14, "10 Seconds"),
    ];
  }
}

class SpinType {
  String name;
  SpinType(this.name);

  static List<SpinType> spin() {
    return <SpinType>[
      SpinType("Standard"),
      SpinType("Bounce"),
      SpinType("Ease In"),
      SpinType("Reverse Start"),
      SpinType("Elastic"),
      SpinType("Slow Middle"),
      SpinType("Steady"),
    ];
  }
}

class ItemsModel {
  int id;
  String name;
  String backColor;
  String textColor;

  ItemsModel({this.id, this.name, this.backColor, this.textColor});

  ItemsModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.name = map['name'];
    this.backColor = map['backColor'];
    this.textColor = map['textColor'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'name': this.name,
      'backColor': this.backColor,
      'textColor': this.textColor,
    };
  }
}

class SpinnerModel {
  int id;
  String title;
  String getItemPath;
  String imageByte;
  int textSize;

  SpinnerModel({this.id, this.title, this.getItemPath, this.imageByte, this.textSize});

  SpinnerModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.title = map['title'];
    this.getItemPath = map['getItemPath'];
    this.imageByte = map['imageByte'];
    this.textSize = map['textSize'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'title': this.title,
      'getItemPath': this.getItemPath,
      'imageByte': this.imageByte,
      'textSize': this.textSize,
    };
  }
}

class ItemsCard extends StatelessWidget {
  const ItemsCard({
    this.itemData,
    this.onTapAction,
    Key key,
  }) : super(key: key);

  final ItemsModel itemData;
  final Function(ItemsModel noteData) onTapAction;

  Color hexToColorBackground(String hexString) {
    return Color(int.parse(hexString.replaceFirst('#', '0xFF')));
  }

  Color hexToColorText(String hexString) {
    return Color(int.parse(hexString.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTapAction(itemData);
        },
        child: Card(
          color: hexToColorBackground(itemData.backColor),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "${itemData.name}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: hexToColorText(itemData.textColor),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ));
  }
}
