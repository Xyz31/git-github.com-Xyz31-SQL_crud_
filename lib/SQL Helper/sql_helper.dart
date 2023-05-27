import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  // create a database table
  static Future<void> createTables(Database dbase) async {
    await dbase.execute(''' 
    CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    ''');
  }

  // Creating the DB and Naming the database.
  //   And Calling the Above Method to create table.
  static Future<Database> db() async {
    return openDatabase('khan.db', version: 1,
        onCreate: (Database dbase, int version) async {
      await createTables(dbase);
    });
  }

  // Read data and Store in the Tables
  static Future<int> createItem(String title, String? description) async {
    final db = await SQLHelper.db();

    // Converting item to mapp
    final data = {'title': title, 'description': description};
    // Add map to table
    final id = await db.insert(
        //To which table
        'items',
        //Data To Add to table
        data,
        // To avoid Duplicate
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  // To load All items During Launch or Reload
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    //To retrive item
    //Orderby : by which reference we have to retrieve.
    return db.query('items', orderBy: 'id');
  }

  //To Retrive data based on id
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items',
        //condition to retrieve
        where: 'id = ?',
        whereArgs: [id],
        //no of rows or item count
        limit: 1);
  }

  //to Update the item based on id
  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SQLHelper.db();
// convert data to map before adding to table
    final data = {
      'title': title,
      'description': description,
      'cretedAt': DateTime.now().toString(),
    };
// add new data
    final result =
        await db.update('items', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //Delete an item Based on id
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint('Something wen wrong');
    }
  }
}
