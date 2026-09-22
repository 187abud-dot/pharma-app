import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../db/db_helper.dart';
import '../models/drug_models.dart';
import 'add_trade_product_screen.dart';

class DrugDetailScreen extends StatefulWidget {
  final GenericDrug generic;
  const DrugDetailScreen({super.key, required this.generic});

  @override
  State<DrugDetailScreen> createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  final FlutterTts _tts = FlutterTts();
  List<TradeProduct> _trades = [];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('en-US'); // النطق بالإنجليزية فقط، كما طُلب
    _load();
  }

  Future<void> _load() async {
    final t = await DBHelper.instance.tradesForGeneric(widget.generic.id!);
    setState(() => _trades = t);
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.generic;
    return Scaffold(
      appBar: AppBar(title: Text(g.nameEn)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('إضافة اسم تجاري'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddTradeProductScreen(genericId: g.id!)),
          );
          _load();
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- الاسم العلمي أولاً ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(g.nameEn,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        tooltip: 'نطق الاسم العلمي',
                        onPressed: () => _speak(g.nameEn),
                      ),
                    ],
                  ),
                  Text(g.nameAr,
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  if (g.system.isNotEmpty) Chip(label: Text(g.system)),
                  const Divider(height: 24),
                  if (g.introduction.isNotEmpty) ...[
                    const Text('مقدمة عن الدواء',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(g.introduction),
                    const SizedBox(height: 8),
                  ],
                  if (g.mechanismOfAction.isNotEmpty) ...[
                    const Text('آلية العمل',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(g.mechanismOfAction),
                    const SizedBox(height: 8),
                  ],
                  if (g.drugInteractions.isNotEmpty) ...[
                    const Text('التداخل الدوائي',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(g.drugInteractions),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('الأسماء التجارية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // ---- الأسماء التجارية متداخلة تحت الاسم العلمي ----
          ..._trades.map((t) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: t.imagePath.isNotEmpty && File(t.imagePath).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(File(t.imagePath),
                              width: 48, height: 48, fit: BoxFit.cover),
                        )
                      : const CircleAvatar(child: Icon(Icons.medication)),
                  title: Text(t.brandName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${t.manufacturer} • ${t.country}\n${t.strength} - ${t.dosageForm}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'نطق الاسم التجاري',
                    onPressed: () => _speak(t.brandName),
                  ),
                ),
              )),
          if (_trades.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('لا توجد أسماء تجارية مضافة بعد لهذا الدواء.'),
            ),
        ],
      ),
    );
  }
}
