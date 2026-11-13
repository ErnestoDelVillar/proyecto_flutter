import 'package:drift/drift.dart';

/// Estado de actualización por recurso
@DataClassName('SyncMetadataRow')
class SyncMetadata extends Table {
  TextColumn get resourceKey => text()();
  DateTimeColumn get lastSuccessAt => dateTime().nullable()();

  /// 'idle' | 'in_progress' | 'success' | 'failed'
  TextColumn get status => text().withDefault(const Constant('idle'))();

  /// Próximo offset a pedir. Permite reanudar una sync interrumpida.
  IntColumn get nextOffset => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {resourceKey};
}