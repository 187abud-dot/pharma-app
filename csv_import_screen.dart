import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../db/db_helper.dart';

class CsvImportScreen extends StatefulWidget {
  const CsvImportScreen({super.key});
  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  bool _importing = false;
  String? _resultMsg;

  Future<void> _pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _importing = true;
      _resultMsg = null;
    });
    try {
      final file = File(result.files.single.path!);
      final count = await DBHelper.instance.importCsv(file);
      setState(() => _resultMsg = 'تم استيراد $count صف بنجاح.');
    } catch (e) {
      setState(() => _resultMsg = 'حدث خطأ أثناء الاستيراد: $e');
    } finally {
      setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استيراد بيانات CSV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('الأعمدة المطلوبة في ملف CSV:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'generic_name_en, generic_name_ar, brand_name, manufacturer,\n'
                  'country, strength, dosage_form, system, atc_code,\n'
                  'introduction, mechanism_of_action, drug_interactions, image_path',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ملاحظة: صف الصورة (image_path) هو مسار محلي أو رابط، وسيتم ربطه لاحقاً. '
              'الاسم العلمي المكرر يتم تجميع أسمائه التجارية تحته تلقائياً.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _importing ? null : _pickAndImport,
              icon: const Icon(Icons.upload_file),
              label: Text(_importing ? 'جاري الاستيراد...' : 'اختيار ملف CSV واستيراده'),
            ),
            if (_importing) const Padding(
              padding: EdgeInsets.only(top: 16),
              child: LinearProgressIndicator(),
            ),
            if (_resultMsg != null) Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_resultMsg!),
            ),
          ],
        ),
      ),
    );
  }
}
