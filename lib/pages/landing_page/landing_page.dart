import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitchen_display_system/pages/collection_display_page/collection_display_page.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/kitchen_display_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Card(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome to Kitchen Display System',
                              style: TextStyle(
                                fontSize: 24,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _onPressed(const KitchenDisplayPage()),
                  label: const Text('KITCHEN DISPLAY'),
                  icon: const Icon(Icons.kitchen),
                ),
                const Divider(),
                TextButton.icon(
                  onPressed: () => _onPressed(const CollectionDisplayPage()),
                  icon: const Icon(Icons.directions_walk),
                  label: const Text('COLLECTION DISPLAY'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPressed(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }
}
