import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';
import 'package:spinner/UI/widgetsAndClasses.dart';

class ItemsDatabase {
  ItemsDatabase._();

  static final ItemsDatabase db = ItemsDatabase._();

  Database _database;
  String spinnerPath;
  String thePath;

  Future<Database> get database async {
    if (_database != null) {
      if (!_database.path.contains(spinnerPath)) {
        _database = await init();
        return _database;
      } else {
        return _database;
      }
    }
    _database = await init();
    return _database;
  }

  setPath(SpinnerModel spinnerData) {
    spinnerPath = spinnerData.getItemPath;
  }

  init() async {
    if (spinnerPath == null) {
      spinnerPath = "spinner0.db";
      print(spinnerPath);
    }
    thePath = await getDatabasesPath();
    thePath = join(thePath, spinnerPath);

    return await openDatabase(thePath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Items (_id INTEGER PRIMARY KEY, name TEXT, backColor TEXT, textColor TEXT);');
    });
  }

  Future<List<ItemsModel>> getItemsFromDB() async {
    // print('$thePath GET Items');
    final db = await database;
    List<ItemsModel> itemsList = [];
    List<Map> maps = await db
        .query('Items', columns: ['_id', 'name', 'backColor', 'textColor']);
    if (maps.length > 0) {
      maps.forEach((map) {
        itemsList.add(ItemsModel.fromMap(map));
      });
    }
    return itemsList;
  }

  updateItemsInDB(ItemsModel updatedItem) async {
    // print('$thePath UPDATE Items');
    final db = await database;
    await db.update('Items', updatedItem.toMap(),
        where: '_id = ?', whereArgs: [updatedItem.id]);
  }

  deleteItemsInDB(ItemsModel itemToDelete) async {
    final db = await database;
    await db.delete('Items', where: '_id = ?', whereArgs: [itemToDelete.id]);
  }

  deleteAllItems() async {
    final db = await database;
    await db.delete('Items');
  }

  Future<ItemsModel> addItemsInDB(ItemsModel newItem) async {
    // print('$thePath ADD Items');
    final db = await database;
    if (newItem.name.trim().isEmpty) newItem.name = 'Untitled';
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into Items(name, backColor, textColor) VALUES ("${newItem.name}", "${newItem.backColor}", "${newItem.textColor}");');
    });
    newItem.id = id;

    return newItem;
  }
}

/////////////////////////////////////////////////////////////////////

class SpinnerDatabase {
  SpinnerDatabase._();

  static final SpinnerDatabase db = SpinnerDatabase._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await init();
    return _database;
  }

  init() async {
    String path = await getDatabasesPath();
    path = join(path, 'spinners.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Spinners (_id INTEGER PRIMARY KEY, title TEXT, getItemPath TEXT, imageByte TEXT, textSize INTEGER);');
    });
  }

  Future<List<SpinnerModel>> getSpinnerFromDB() async {
    final db = await database;
    List<SpinnerModel> spinnerList = [];
    List<Map> maps = await db.query('Spinners',
        columns: ['_id', 'title', 'getItemPath', 'imageByte', 'textSize']);
    if (maps.length > 0) {
      maps.forEach((map) {
        spinnerList.add(SpinnerModel.fromMap(map));
      });
    }
    return spinnerList;
  }

  updateSpinnerInDB(SpinnerModel updateSpinner) async {
    final db = await database;
    await db.update('Spinners', updateSpinner.toMap(),
        where: '_id = ?', whereArgs: [updateSpinner.id]);
  }

  deleteSpinnerInDB(SpinnerModel spinnerToDelete) async {
    final db = await database;
    await db
        .delete('Spinners', where: '_id = ?', whereArgs: [spinnerToDelete.id]);
  }

  deleteAllSpinner() async {
    final db = await database;
    await db.delete('Spinners');
  }

  Future<SpinnerModel> addSpinnerInDB(SpinnerModel newSpinner) async {
    final db = await database;
    if (newSpinner.title.trim().isEmpty) newSpinner.title = 'Untitled';
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into Spinners(title, getItemPath, imageByte, textSize) VALUES ("${newSpinner.title}", "${newSpinner.getItemPath}", "${newSpinner.imageByte}", "${newSpinner.textSize}");');
    });
    newSpinner.id = id;

    return newSpinner;
  }
}
