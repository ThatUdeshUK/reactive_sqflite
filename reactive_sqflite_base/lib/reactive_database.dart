import 'package:sqflite/sqflite.dart';
import 'package:rxdart/rxdart.dart';

class ReactiveDatabase {
  static const String _TAG = "ReactiveDatabase";

  final Database _db;
  final Subject<Set<String>> _trigger = PublishSubject();
  final bool logging;

  ReactiveDatabase.from(Database database, {this.logging = false})
      : this._db = database;

  void notifyTrigger(Set<String> tables) {
    if (_trigger.isClosed) {
      if (logging)
        print(
            "$_TAG: Reactive database already closed! Datasource changed, but won't notify");
    } else {
      if (logging)
        print("$_TAG: Notifing observables subcribed to ${tables.toString()}");
      _trigger.add(tables);
    }
  }

  /// Insert a row into a table, where the keys of [values] correspond to
  /// column names
  ///
  /// Returns the last inserted record id
  ///
  Future<int> insert(String table, Map<String, dynamic> values,
      {String nullColumnHack, ConflictAlgorithm conflictAlgorithm}) {
    return _db
        .insert(table, values,
            nullColumnHack: nullColumnHack,
            conflictAlgorithm: conflictAlgorithm)
        .then((_) {
      notifyTrigger([table].toSet());
    });
  }

  /// Convenience method for updating rows in the database.
  ///
  /// Update [table] with [values], a map from column names to new column
  /// values. null is a valid value that will be translated to NULL.
  ///
  /// [where] is the optional WHERE clause to apply when updating.
  /// Passing null will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  ///
  Future<int> update(String table, Map<String, dynamic> values,
      {String where, List whereArgs, ConflictAlgorithm conflictAlgorithm}) {
    return _db
        .update(table, values,
            where: where,
            whereArgs: whereArgs,
            conflictAlgorithm: conflictAlgorithm)
        .then((_) {
      notifyTrigger([table].toSet());
    });
  }

  /// Convenience method for deleting rows in the database.
  ///
  /// Delete from [table]
  ///
  /// [where] is the optional WHERE clause to apply when updating. Passing null
  /// will update all rows.
  ///
  /// You may include ?s in the where clause, which will be replaced by the
  /// values from [whereArgs]
  ///
  /// [conflictAlgorithm] (optional) specifies algorithm to use in case of a
  /// conflict. See [ConflictResolver] docs for more details
  ///
  /// Returns the number of rows affected if a whereClause is passed in, 0
  /// otherwise. To remove all rows and get a count pass "1" as the
  /// whereClause.
  ///
  Future<int> delete(String table, {String where, List whereArgs}) {
    return _db
        .delete(table, where: where, whereArgs: whereArgs)
        .then((_) {
      notifyTrigger([table].toSet());
    });
  }

  /// Helper to query a table
  ///
  /// @param distinct true if you want each row to be unique, false otherwise.
  /// @param table The table names to compile the query against.
  /// @param columns A list of which columns to return. Passing null will
  ///            return all columns, which is discouraged to prevent reading
  ///            data from storage that isn't going to be used.
  /// @param where A filter declaring which rows to return, formatted as an SQL
  ///            WHERE clause (excluding the WHERE itself). Passing null will
  ///            return all rows for the given URL.
  /// @param groupBy A filter declaring how to group rows, formatted as an SQL
  ///            GROUP BY clause (excluding the GROUP BY itself). Passing null
  ///            will cause the rows to not be grouped.
  /// @param having A filter declare which row groups to include in the cursor,
  ///            if row grouping is being used, formatted as an SQL HAVING
  ///            clause (excluding the HAVING itself). Passing null will cause
  ///            all row groups to be included, and is required when row
  ///            grouping is not being used.
  /// @param orderBy How to order the rows, formatted as an SQL ORDER BY clause
  ///            (excluding the ORDER BY itself). Passing null will use the
  ///            default sort order, which may be unordered.
  /// @param limit Limits the number of rows returned by the query,
  /// @param offset starting index,
  ///
  /// @return the items found
  ///
  Observable<List<Map>> query(String table,
      {bool distinct,
      List<String> columns,
      String where,
      List whereArgs,
      String groupBy,
      String having,
      String orderBy,
      int limit,
      int offset}) {
    return _trigger
        .where((Set<String> tables) => tables.contains(table))
        .startWith(Set.of([table]))
        .flatMap((_) {
      return _db
          .query(table,
              distinct: distinct,
              columns: columns,
              where: where,
              whereArgs: whereArgs,
              groupBy: groupBy,
              having: having,
              orderBy: orderBy,
              limit: limit,
              offset: offset)
          .asStream();
    });
  }

  /// Close the database. Cannot be access anymore
  void close() {
    _trigger.close();
  }
}
