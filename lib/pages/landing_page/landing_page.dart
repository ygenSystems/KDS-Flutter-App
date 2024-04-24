import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kitchen_display_system/pages/collection_display_page/collection_display_page.dart';
import 'package:kitchen_display_system/pages/collection_display_page/collection_display_page_vm.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/kitchen_display_page.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/kitchen_display_page_vm.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _box = GetStorage();
  bool _isValidIp = true;
  final _controller = TextEditingController();

  initState() {
    super.initState();
    final serverIp = _box.read('server_ip');
    if (serverIp != null) {
      _controller.text = serverIp;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          SizedBox(
            width: 220,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Server IP Address',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: _isValidIp ? null : 'Invalid IP address',
              ),
              onChanged: (value) async {
                const pattern = r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d{1,5})?$';
                final regExp = RegExp(pattern);

                _isValidIp = regExp.hasMatch(value);
                if (_isValidIp) {
                  await _box.write('server_ip', value);
                }
                setState(() {});
              },
            ),
          ),
        ],
      ),
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
    // unfocus the text field
    FocusManager.instance.primaryFocus?.unfocus();
    final serverIp = _box.read<String?>('server_ip');
    final uri = 'http://$serverIp/';
    if (serverIp != null && Uri.parse(uri).isAbsolute) {
      final repo = OrdersRepository(serverIp);
      _resetDep(KitchenDisplayPageVM(repo));
      _resetDep(CollectionDisplayPageVM(repo));
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    }
  }

  S _resetDep<S>(S vm) {
    if (Get.isRegistered<S>()) Get.delete<S>();
    return Get.put<S>(vm);
  }
}
