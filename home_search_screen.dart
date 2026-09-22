import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/drug_models.dart';
import 'drug_detail_screen.dart';
import 'csv_import_screen.dart';
import 'add_drug_screen.dart';

class HomeSearchScreen extends StatefulWidget {
  const HomeSearchScreen({super.key});
  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  final _controller = TextEditingController();
  List<GenericDrug> _results = [];
  bool _loading = false;

  Future<void> _doSearch(String q) async {
    setState(() => _loading = true);
    final res = q.trim().isEmpty
        ? await DBHelper.instance.allGenerics()
        : await DBHelper.instance.search(q.trim());
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _doSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موسوعة الأدوية'),
        actions: [
          IconButton(
            tooltip: 'استيراد CSV',
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CsvImportScreen()));
              _doSearch(_controller.text);
            },
          ),
          IconButton(
            tooltip: 'إضافة دواء',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddDrugScreen()));
              _doSearch(_controller.text);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onChanged: _doSearch,
              decoration: const InputDecoration(
                hintText: 'ابحث بالاسم العلمي أو التجاري...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: _results.isEmpty
                ? const Center(child: Text('لا توجد نتائج'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, i) {
                      final g = _results[i];
                      return ListTile(
                        title: Text(g.nameEn,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${g.nameAr}  •  ${g.system}'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DrugDetailScreen(generic: g)),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
