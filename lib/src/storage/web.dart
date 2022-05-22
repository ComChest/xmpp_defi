// web.dart
import 'package:drift/web.dart';
import 'database.dart';

///This is the pure Dart implementation:
SharedDatabase constructDb() {
  return SharedDatabase(WebDatabase('db'));
  //Web worker example: github.com/simolus3/drift/blob/develop/examples/web_worker_example/web/worker.dart
  //return SharedDatabase(WebDatabase.withStorage(await DriftWebStorage.indexedDbIfSupported('db')));
}

/*
///This is the Flutter app implementation:
@DriftDatabase( include: {'src/tables.drift'})
class SharedDatabase extends _$SharedDatabase {
  // here, "app" is the name of the database - you can choose any name you want
  MyDatabase() : super(WebDatabase('app'));

}

*/

