import 'package:flutter/material.dart';
import 'encryption_screen.dart';
import 'decryption_screen.dart';

class NavigationMenu extends StatefulWidget {
  final int screenIndex;

  const NavigationMenu({Key? key, required this.screenIndex}) : super(key: key);

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.screenIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      const EncryptionScreen(),
      const DecryptionScreen(),
    ];

    return DefaultTabController(
      length: widgetOptions.length,
      initialIndex: _selectedIndex,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(19),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.lock), text: 'Encrypt'),
                  Tab(icon: Icon(Icons.lock_open), text: 'Decrypt'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[500],
                indicatorColor: Colors.white,
                labelStyle:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: widgetOptions,
        ),
      ),
    );
  }
}
