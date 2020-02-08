import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spinner/Screens/pre_made_spinner.dart';
import 'package:spinner/UI/widgetsAndClasses.dart';

class PreMadeList extends StatefulWidget {
  @override
  _PreMadeListState createState() => _PreMadeListState();
}

class PreItems {
  final Color color;
  final String name;
  PreItems(this.color, this.name);
}

class PreSpinner {
  final String title;
  final List<PreItems> items;
  final String spinnerImage;
  final double textSize;
  PreSpinner(this.title, this.items, this.spinnerImage, this.textSize);
}

class _PreMadeListState extends State<PreMadeList> {
  List<PreSpinner> spinnerList = [];

  List<PreItems> yesNo = [
    PreItems(Colors.green, "Yes"),
    PreItems(Colors.red, "No"),
    PreItems(Colors.green, "Yes"),
    PreItems(Colors.red, "No"),
    PreItems(Colors.green, "Yes"),
    PreItems(Colors.red, "No"),
    PreItems(Colors.green, "Yes"),
    PreItems(Colors.red, "No"),
    PreItems(Colors.green, "Yes"),
    PreItems(Colors.red, "No"),
  ];

  List<PreItems> food = [
    PreItems(Colors.accents[0], "Pizza 🍕"),
    PreItems(Colors.accents[3], "Straberries 🍓"),
    PreItems(Colors.accents[5], "Tacos 🌮"),
    PreItems(Colors.accents[7], "Salad 🥗"),
    PreItems(Colors.accents[9], "Chinese 🥡"),
    PreItems(Colors.accents[11], "Doughnuts 🍩"),
    PreItems(Colors.accents[13], "Grapes 🍇"),
    PreItems(Colors.accents[15], "Hot Dog 🌭"),
    PreItems(Colors.accents[2], "Italian 🍝"),
    PreItems(Colors.accents[4], "Soup 🥣"),
    PreItems(Colors.accents[6], "Pancakes 🥞"),
    PreItems(Colors.accents[8], "Watermelon 🍉"),
    PreItems(Colors.accents[10], "Sandwich 🥪"),
    PreItems(Colors.accents[12], "BBQ 🍖"),
    PreItems(Colors.accents[14], "Sushi 🍣"),
    PreItems(Colors.accents[0], "Hamburger 🍔"),
    PreItems(Colors.accents[3], "Apples 🍎"),
    PreItems(Colors.accents[5], "Ice Cream 🍦"),
    PreItems(Colors.accents[7], "Coffee ☕"),
    PreItems(Colors.accents[9], "Steak 🥩"),
    PreItems(Colors.accents[11], "Bananas 🍌"),
  ];

  List<PreItems> activity = [
    PreItems(Colors.accents[0], "Movie"),
    PreItems(Colors.accents[3], "Watch TV"),
    PreItems(Colors.accents[6], "Make Food"),
    PreItems(Colors.accents[9], "Workout"),
    PreItems(Colors.accents[12], "Video Games"),
    PreItems(Colors.accents[15], "Go out"),
    PreItems(Colors.accents[1], "Read"),
    PreItems(Colors.accents[2], "Board Games"),
    PreItems(Colors.accents[8], "Sleep"),
    PreItems(Colors.accents[10], "Party"),
  ];

  Size get size => Size(MediaQuery.of(context).size.width * .4,
      MediaQuery.of(context).size.width * .4);
  double itemRotate(int index) => (index / yesNo.length) * 2 * pi;

  PreSpinner currentSpinner;

  @override
  void initState() {
    super.initState();
    spinnerList.add(
        PreSpinner("Yes - No Spinner", yesNo, "assets/yes_no.png", 30));
    spinnerList
        .add(PreSpinner("Food Spinner", food, "assets/food.png", 15));
    spinnerList
        .add(PreSpinner("Activities", activity, "assets/activity.png", 22));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: AppBar(
          title: Text("Pre-Made Spinners"),
          backgroundColor: Colors.blueGrey,
        ),
      ),
      endDrawer: Drawer(
        child: menu(context),
      ),
      body: ListView(
        children: <Widget>[
          for (var spinners in spinnerList) ...{spinnerCards(spinners)},
        ],
      ),
    );
  }

  Widget spinnerCards(PreSpinner spinnerData) {
    return RawMaterialButton(
      onPressed: () {
        setState(() {
          currentSpinner = PreSpinner(spinnerData.title, spinnerData.items,
              spinnerData.spinnerImage, spinnerData.textSize);
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreMadeSpinner(
              itemsList: spinnerData.items,
              currentSpinner: currentSpinner,
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
              ],
            ),
            Container(
              child: Image(
                image: AssetImage(spinnerData.spinnerImage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
