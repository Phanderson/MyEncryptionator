import 'navigationmenu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state_management.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => StateManagement(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: '/encrypt',
      routes: {
        '/encrypt': (context) => const NavigationMenu(screenIndex: 0),
        '/decrypt': (context) => const NavigationMenu(screenIndex: 1),
      },
    );
  }
}
