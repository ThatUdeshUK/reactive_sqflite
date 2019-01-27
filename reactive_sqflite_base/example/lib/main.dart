import 'package:flutter/material.dart';

import 'package:reactive_sqflite/reactive_sqflite.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Reactive database wrapped around the SQflite database
  ReactiveDatabase _db;

  /// SQflite database
  Database _database;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  /// Creates a dummy database and create a dummy table for the example.
  /// Contains columns id, name
  ///
  /// Returns opened writable database
  Future<Database> _getSQfliteDatabase() async {
    var databasesPath = await getDatabasesPath();
    _database = await openDatabase(databasesPath + "demo.db", version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)');
    });
    return _database;
  }

  @override
  void initState() {
    _getSQfliteDatabase().then((Database database) {
      /// Wraps the created SQflite database with a ReactiveDatabase for reactive support
      setState(() {
        _db = ReactiveDatabase.from(database, logging: true);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    /// Closes reactive database, so no notifications after this
    _db.close();

    // Clase SQflite database
    _database.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Reactive SQflite example app'),
        ),
        body: Center(
          /// Check whether the reactive database is created. Otherwise show a placeholder.
          child: _db != null
              ? Column(
                  children: <Widget>[
                    /// Query test table and subcribe to in using a stream builder.
                    StreamBuilder(
                      stream: _db.query("Test"),
                      builder: (context, AsyncSnapshot<List<Map>> snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data.toString());
                        } else {
                          return Text("No data");
                        }
                      },
                    ),
                    TextField(
                      controller: _idController,
                      decoration: InputDecoration(labelText: "ID"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("Insert"),
                          onPressed: () {
                            _db.insert("Test", {
                              "id": _idController.text,
                              "name": _nameController.text
                            });
                          },
                        ),
                        RaisedButton(
                          child: Text("Update"),
                          onPressed: () {
                            _db.update("Test", {"name": _nameController.text},
                                where: "id = ?",
                                whereArgs: [_idController.text]);
                          },
                        ),
                        RaisedButton(
                          child: Text("Delete"),
                          onPressed: () {
                            _db.delete("Test",
                                where: "id = ?",
                                whereArgs: [_idController.text]);
                          },
                        ),
                      ],
                    )
                  ],
                )
              : Placeholder(),
        ),
      ),
    );
  }
}
