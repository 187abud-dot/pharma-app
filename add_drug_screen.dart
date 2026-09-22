import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/drug_models.dart';

class AddDrugScreen extends StatefulWidget {
  const AddDrugScreen({super.key});
  @override
  State<AddDrugScreen> createState() => _AddDrugScreenState();
}

class _AddDrugScreenState extends State<AddDrugScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEn = TextEditingController();
  final _nameAr = TextEditingController();
  final _system = TextEditingController();
  final _atc = TextEditingController();
  final _intro = TextEditingController();
  final _moa = TextEditingController();
  final _interactions = TextEditingController();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await DBHelper.instance.insertGeneric(GenericDrug(
      nameEn: _nameEn.text.trim(),
      nameAr: _nameAr.text.trim(),
      system: _system.text.trim(),
      atcCode: _atc.text.trim(),
      introduction: _intro.text.trim(),
      mechanismOfAction: _moa.text.trim(),
      drugInteractions: _interactions.text.trim(),
    ));
    if (mounted) Navigator.pop(context);
  }

  Widget _field(TextEditingController c, String label, {bool required = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: lines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة دواء (اسم علمي)')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_nameEn, 'الاسم العلمي بالإنجليزية', required: true),
            _field(_nameAr, 'الاسم العلمي بالعربية', required: true),
            _field(_system, 'الجهاز الدوائي'),
            _field(_atc, 'رمز ATC'),
            _field(_intro, 'مقدمة عن الدواء', lines: 3),
            _field(_moa, 'آلية العمل', lines: 3),
            _field(_interactions, 'التداخل الدوائي', lines: 3),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
