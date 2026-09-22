import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/db_helper.dart';
import '../models/drug_models.dart';

class AddTradeProductScreen extends StatefulWidget {
  final int genericId;
  const AddTradeProductScreen({super.key, required this.genericId});

  @override
  State<AddTradeProductScreen> createState() => _AddTradeProductScreenState();
}

class _AddTradeProductScreenState extends State<AddTradeProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _manufacturer = TextEditingController();
  final _country = TextEditingController();
  final _strength = TextEditingController();
  final _form = TextEditingController();
  String? _imagePath;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await DBHelper.instance.insertTrade(TradeProduct(
      genericId: widget.genericId,
      brandName: _brand.text.trim(),
      manufacturer: _manufacturer.text.trim(),
      country: _country.text.trim(),
      strength: _strength.text.trim(),
      dosageForm: _form.text.trim(),
      imagePath: _imagePath ?? '',
      source: 'إدخال يدوي',
      verificationStatus: 'تمت مراجعته',
    ));
    if (mounted) Navigator.pop(context);
  }

  Widget _field(TextEditingController c, String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة اسم تجاري')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Wrap(children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('التقاط صورة'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('اختيار من المعرض'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ]),
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null
                      ? const Icon(Icons.add_a_photo, size: 32)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _field(_brand, 'الاسم التجاري (بالإنجليزية)', required: true),
            _field(_manufacturer, 'الشركة المصنعة'),
            _field(_country, 'الدولة'),
            _field(_strength, 'القوة / التركيز'),
            _field(_form, 'الشكل الصيدلاني'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('حفظ المنتج'),
            ),
          ],
        ),
      ),
    );
  }
}
