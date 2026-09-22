import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';
import '../models/drug_models.dart';

/// قاعدة البيانات المحلية - تعمل بدون اتصال بالإنترنت بالكامل
class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pharma_encyclopedia.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE generic_drugs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name_en TEXT NOT NULL,
            name_ar TEXT NOT NULL,
            system TEXT,
            atc_code TEXT,
            introduction TEXT,
            mechanism_of_action TEXT,
            drug_interactions TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE trade_products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            generic_id INTEGER NOT NULL,
            brand_name TEXT NOT NULL,
            manufacturer TEXT,
            country TEXT,
            strength TEXT,
            dosage_form TEXT,
            image_path TEXT,
            source TEXT,
            verification_status TEXT,
            FOREIGN KEY (generic_id) REFERENCES generic_drugs (id) ON DELETE CASCADE
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_generic_name ON generic_drugs(name_en, name_ar)');
        await db.execute(
            'CREATE INDEX idx_brand_name ON trade_products(brand_name)');
      },
    );
  }

  // ---------- إضافة ----------
  Future<int> insertGeneric(GenericDrug g) async {
    final db = await database;
    return db.insert('generic_drugs', g.toMap()..remove('id'));
  }

  Future<int> insertTrade(TradeProduct t) async {
    final db = await database;
    return db.insert('trade_products', t.toMap()..remove('id'));
  }

  // ---------- بحث ----------
  /// يعيد قائمة الأدوية العلمية التي تطابق النص (اسم علمي أو تجاري)
  Future<List<GenericDrug>> search(String query) async {
    final db = await database;
    final q = '%$query%';
    final res = await db.rawQuery('''
      SELECT DISTINCT g.* FROM generic_drugs g
      LEFT JOIN trade_products t ON t.generic_id = g.id
      WHERE g.name_en LIKE ? OR g.name_ar LIKE ? OR t.brand_name LIKE ?
      ORDER BY g.name_en
    ''', [q, q, q]);
    return res.map((m) => GenericDrug.fromMap(m)).toList();
  }

  Future<List<TradeProduct>> tradesForGeneric(int genericId) async {
    final db = await database;
    final res = await db.query('trade_products',
        where: 'generic_id = ?', whereArgs: [genericId]);
    return res.map((m) => TradeProduct.fromMap(m)).toList();
  }

  Future<List<GenericDrug>> allGenerics() async {
    final db = await database;
    final res = await db.query('generic_drugs', orderBy: 'name_en');
    return res.map((m) => GenericDrug.fromMap(m)).toList();
  }

  Future<GenericDrug?> findGenericByNameEn(String nameEn) async {
    final db = await database;
    final res = await db.query('generic_drugs',
        where: 'name_en = ?', whereArgs: [nameEn], limit: 1);
    if (res.isEmpty) return null;
    return GenericDrug.fromMap(res.first);
  }

  // ---------- استيراد CSV ----------
  /// الأعمدة المتوقعة:
  /// generic_name_en, generic_name_ar, brand_name, manufacturer, country,
  /// strength, dosage_form, system, atc_code, introduction,
  /// mechanism_of_action, drug_interactions, image_path
  Future<int> importCsv(File file) async {
    final content = await file.readAsString();
    final rows = const CsvToListConverter(eol: '\n').convert(content, eol: '\n');
    if (rows.isEmpty) return 0;

    final header = rows.first.map((e) => e.toString().trim()).toList();
    int idx(String name) => header.indexOf(name);

    int imported = 0;
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < header.length) continue;

      String col(String name) {
        final j = idx(name);
        if (j == -1 || j >= row.length) return '';
        return row[j]?.toString().trim() ?? '';
      }

      final nameEn = col('generic_name_en');
      if (nameEn.isEmpty) continue;

      var generic = await findGenericByNameEn(nameEn);
      int genericId;
      if (generic == null) {
        genericId = await insertGeneric(GenericDrug(
          nameEn: nameEn,
          nameAr: col('generic_name_ar'),
          system: col('system'),
          atcCode: col('atc_code'),
          introduction: col('introduction'),
          mechanismOfAction: col('mechanism_of_action'),
          drugInteractions: col('drug_interactions'),
        ));
      } else {
        genericId = generic.id!;
      }

      final brandName = col('brand_name');
      if (brandName.isNotEmpty) {
        await insertTrade(TradeProduct(
          genericId: genericId,
          brandName: brandName,
          manufacturer: col('manufacturer'),
          country: col('country'),
          strength: col('strength'),
          dosageForm: col('dosage_form'),
          imagePath: col('image_path'),
          source: 'استيراد CSV',
          verificationStatus: 'مستورد آليًا - يحتاج مراجعة',
        ));
      }
      imported++;
    }
    return imported;
  }

  /// ربط صورة بمنتج تجاري موجود بعد الاستيراد (بحسب رقمه أو اسمه)
  Future<int> attachImageToTrade(int tradeId, String imagePath) async {
    final db = await database;
    return db.update('trade_products', {'image_path': imagePath},
        where: 'id = ?', whereArgs: [tradeId]);
  }
}
