import 'dart:math';
import 'package:drift/drift.dart';

part 'database.g.dart';


@DriftDatabase(tables: [ContactList])
class SharedDatabase extends _$MyDatabase {
  // we tell the database where to store the data with this constructor
  SharedDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return SharedDatabase(file);
  });
}