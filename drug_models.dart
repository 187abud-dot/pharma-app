/// الاسم العلمي (المادة الفعالة) - العنصر الرئيسي في العرض
class GenericDrug {
  final int? id;
  final String nameEn; // الاسم العلمي بالإنجليزية (يُنطق)
  final String nameAr; // الاسم العلمي بالعربية (لا يُنطق)
  final String system; // الجهاز الدوائي
  final String atcCode; // تصنيف ATC
  final String introduction; // مقدمة عن الدواء
  final String mechanismOfAction; // آلية العمل
  final String drugInteractions; // التداخل الدوائي

  GenericDrug({
    this.id,
    required this.nameEn,
    required this.nameAr,
    this.system = '',
    this.atcCode = '',
    this.introduction = '',
    this.mechanismOfAction = '',
    this.drugInteractions = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name_en': nameEn,
        'name_ar': nameAr,
        'system': system,
        'atc_code': atcCode,
        'introduction': introduction,
        'mechanism_of_action': mechanismOfAction,
        'drug_interactions': drugInteractions,
      };

  factory GenericDrug.fromMap(Map<String, dynamic> m) => GenericDrug(
        id: m['id'] as int?,
        nameEn: m['name_en'] ?? '',
        nameAr: m['name_ar'] ?? '',
        system: m['system'] ?? '',
        atcCode: m['atc_code'] ?? '',
        introduction: m['introduction'] ?? '',
        mechanismOfAction: m['mechanism_of_action'] ?? '',
        drugInteractions: m['drug_interactions'] ?? '',
      );
}

/// الاسم التجاري - منتج مرتبط بالاسم العلمي (علاقة واحد لعدة)
class TradeProduct {
  final int? id;
  final int genericId; // ربط بالاسم العلمي
  final String brandName; // الاسم التجاري (يُنطق بالإنجليزية)
  final String manufacturer; // الشركة المصنعة
  final String country; // الدولة
  final String strength; // القوة/التركيز
  final String dosageForm; // الشكل الصيدلاني
  final String imagePath; // مسار أو رابط الصورة
  final String source; // مصدر البيانات
  final String verificationStatus; // حالة التوثيق

  TradeProduct({
    this.id,
    required this.genericId,
    required this.brandName,
    this.manufacturer = '',
    this.country = '',
    this.strength = '',
    this.dosageForm = '',
    this.imagePath = '',
    this.source = '',
    this.verificationStatus = 'مستورد آليًا',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'generic_id': genericId,
        'brand_name': brandName,
        'manufacturer': manufacturer,
        'country': country,
        'strength': strength,
        'dosage_form': dosageForm,
        'image_path': imagePath,
        'source': source,
        'verification_status': verificationStatus,
      };

  factory TradeProduct.fromMap(Map<String, dynamic> m) => TradeProduct(
        id: m['id'] as int?,
        genericId: m['generic_id'] as int,
        brandName: m['brand_name'] ?? '',
        manufacturer: m['manufacturer'] ?? '',
        country: m['country'] ?? '',
        strength: m['strength'] ?? '',
        dosageForm: m['dosage_form'] ?? '',
        imagePath: m['image_path'] ?? '',
        source: m['source'] ?? '',
        verificationStatus: m['verification_status'] ?? '',
      );
}
