import 'package:flutter/material.dart';
import 'db/seed_data.dart';
import 'screens/home_search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PharmaApp());
}

class PharmaApp extends StatelessWidget {
  const PharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'موسوعة الأدوية',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0E7C7B),
        fontFamily: 'Cairo',
      ),
      builder: (context, child) {
        // الواجهة بالعربية RTL افتراضياً
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const AppBootstrap(),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});
  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await seedSampleData(); // بيانات تجريبية أولية فقط عند أول تشغيل
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const HomeSearchScreen();
  }
}
