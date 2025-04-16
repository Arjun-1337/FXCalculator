import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forex_calculator/theme_notifier.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? Colors.black
              : Colors.white, // Adjust background based on theme
      appBar: AppBar(
        title: const Text('Forex Calculators'),
        backgroundColor:
            isDarkMode ? Colors.black : Colors.white, // Adjust app bar color
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: isDarkMode ? Colors.white : Colors.black,
                ), // Adjust menu icon color
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: Drawer(
        backgroundColor:
            isDarkMode
                ? Colors.black
                : Colors.white, // Adjust drawer background color
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.calculate,
                color: isDarkMode ? Colors.white : Colors.black,
              ), // Adjust icon color
              title: Text(
                'Lot Size Calculator',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ), // Adjust text color based on theme
              ),
              onTap: () {
                Navigator.pushNamed(context, '/lot');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.money,
                color: isDarkMode ? Colors.white : Colors.black,
              ), // Adjust icon color
              title: Text(
                'Pip Value Calculator',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ), // Adjust text color based on theme
              ),
              onTap: () {
                Navigator.pushNamed(context, '/pip_value');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: isDarkMode ? Colors.white : Colors.black,
              ), // Adjust icon color
              title: Text(
                'Theme',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ), // Adjust text color based on theme
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeNotifier.toggleTheme();
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.grey,
              ),
              onTap: () {
                themeNotifier.toggleTheme();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CalculatorButton(
              label: 'Lot Size Calculator',
              onPressed: () => Navigator.pushNamed(context, '/lot'),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 20),
            CalculatorButton(
              label: 'Pip Value Calculator',
              onPressed: () => Navigator.pushNamed(context, '/pip_value'),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 20),
            CalculatorButton(
              label: 'More coming soon...',
              onPressed: () {},
              disabled: true,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool disabled;
  final bool isDarkMode;

  const CalculatorButton({
    required this.label,
    required this.onPressed,
    this.disabled = false,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDarkMode
                ? Colors.black
                : Colors.white, // Adjust button background
        foregroundColor:
            isDarkMode
                ? Colors.white
                : Colors.black, // Adjust button text color
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(
          color: isDarkMode ? Colors.white24 : Colors.black12,
        ), // Adjust button border
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ), // Adjust text color
    );
  }
}
