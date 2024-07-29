import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _isValidIp = true.obs;
  final _box = GetStorage();
  final _controller = TextEditingController();

  @override
  void initState() {
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
    final textTheme = Theme.of(context).textTheme;
    final titleLarge = textTheme.titleLarge;
    final bodyLarge = textTheme.bodyLarge;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              title: Obx(
                () => TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Server IP Address',
                    hintStyle: bodyLarge,
                    errorText: _isValidIp.value ? null : 'Invalid IP address',
                  ),
                  onChanged: (value) async {
                    const pattern =
                        r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d{1,5})?$';
                    final regExp = RegExp(pattern);

                    _isValidIp.value = regExp.hasMatch(value);
                  },
                ),
              ),
              subtitle: const Text('Server Ip Address'),
              trailing: IconButton(
                onPressed: () async {
                  if (_isValidIp.value) {
                    await _box.write('server_ip', _controller.text);
                    Get.snackbar('Setting', 'Server ip address saved');
                  }
                },
                icon: const Icon(Icons.check),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final void Function() onDonePressed;
  const SettingsTile({
    super.key,
    required this.controller,
    required this.label,
    required this.onDonePressed,
  });

  @override
  Widget build(BuildContext context) {
    final bodyLarge = Theme.of(context).textTheme.bodyLarge;
    return ListTile(
      title: TextField(
        controller: controller,
      ),
      subtitle: Text(
        label,
        style: bodyLarge,
      ),
      leading: IconButton(
        onPressed: onDonePressed,
        icon: const Icon(Icons.check),
      ),
    );
  }
}
