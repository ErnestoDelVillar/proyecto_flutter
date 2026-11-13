import 'package:drift/drift.dart';

/// Tipos en Pokemon (Fuego, agua, planta, etc).
@DataClassName('TypeRow')
class Types extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}