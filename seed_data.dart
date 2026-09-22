import 'db_helper.dart';
import '../models/drug_models.dart';

/// بيانات تجريبية توضح البنية: اسم علمي واحد -> عدة أسماء تجارية
Future<void> seedSampleData() async {
  final db = DBHelper.instance;
  final existing = await db.allGenerics();
  if (existing.isNotEmpty) return; // لا تكرر البذر

  final amoxId = await db.insertGeneric(GenericDrug(
    nameEn: 'Amoxicillin',
    nameAr: 'أموكسيسيلين',
    system: 'مضادات العدوى',
    atcCode: 'J01CA04',
    introduction: 'مضاد حيوي واسع الطيف من مجموعة البنسلينات.',
    mechanismOfAction: 'يثبط تصنيع جدار الخلية البكتيرية.',
    drugInteractions: 'قد يقلل من فعالية بعض موانع الحمل الفموية.',
  ));
  await db.insertTrade(TradeProduct(
    genericId: amoxId,
    brandName: 'Amoxil',
    manufacturer: 'GlaxoSmithKline',
    country: 'United Kingdom',
    strength: '500 mg',
    dosageForm: 'Capsule',
    source: 'بيانات تجريبية',
    verificationStatus: 'تمت مراجعته',
  ));
  await db.insertTrade(TradeProduct(
    genericId: amoxId,
    brandName: 'Moxatag',
    manufacturer: 'MiddleBrook Pharmaceuticals',
    country: 'USA',
    strength: '775 mg',
    dosageForm: 'Tablet',
    source: 'بيانات تجريبية',
    verificationStatus: 'تمت مراجعته',
  ));

  final paraId = await db.insertGeneric(GenericDrug(
    nameEn: 'Paracetamol',
    nameAr: 'باراسيتامول',
    system: 'مسكنات وخافضات حرارة',
    atcCode: 'N02BE01',
    introduction: 'مسكن للألم وخافض للحرارة شائع الاستخدام.',
    mechanismOfAction: 'يثبط إنزيم السيكلوأوكسيجيناز في الجهاز العصبي المركزي.',
    drugInteractions: 'يزيد خطر تسمم الكبد مع الكحول أو الجرعات الزائدة.',
  ));
  await db.insertTrade(TradeProduct(
    genericId: paraId,
    brandName: 'Panadol',
    manufacturer: 'GlaxoSmithKline',
    country: 'Saudi Arabia',
    strength: '500 mg',
    dosageForm: 'Tablet',
    source: 'بيانات تجريبية',
    verificationStatus: 'تمت مراجعته',
  ));
  await db.insertTrade(TradeProduct(
    genericId: paraId,
    brandName: 'Tylenol',
    manufacturer: 'Johnson & Johnson',
    country: 'USA',
    strength: '650 mg',
    dosageForm: 'Caplet',
    source: 'بيانات تجريبية',
    verificationStatus: 'تمت مراجعته',
  ));
}
