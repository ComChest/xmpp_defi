import 'package:drift/drift.dart';

class DefaultColumns extends Table {
  IntColumn get id => integer().unique()(); // Random UInt - n^2 max table size
  DateTimeColumn get timestamp => dateTime()(); // Record Creation time
  TextColumn get description => text()();
}

class Contacts extends DefaultColumns {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 4, max: 32)();
  TextColumn get domain => text().named('body')();
  /// jid_type can be SID, MID or FID
  TextColumn get jidType => integer().nullable()();
}

class Messages  extends DefaultColumns {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  IntColumn get category => integer().nullable()();
}
