import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/calculators/lot_size/lot_size_screen.dart';
import 'features/calculators/pip_value/pip_value_screen.dart';
import 'theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file with keys
  try {
    await dotenv.load(fileName: "KEY.env");
  } catch (e) {
    debugPrint("❌ Failed to load .env: $e");
  }

  runApp(const ForexCalculatorApp());
}

class ForexCalculatorApp extends StatelessWidget {
  const ForexCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Builder(
        builder: (context) {
          final themeNotifier = Provider.of<ThemeNotifier>(context);
          return MaterialApp(
            title: 'Forex Calculator',
            debugShowCheckedModeBanner: false,
            theme: themeNotifier.currentTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/home': (context) => const HomeScreen(),
              '/lot': (context) => const LotSizeScreen(),
              '/pip_value': (context) => const PipValueScreen(),
            },
          );
        },
      ),
    );
  }
}
