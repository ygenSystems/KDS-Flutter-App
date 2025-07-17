import 'package:audioplayers/audioplayers.dart';
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
  final _repeatSoundValue = false.obs;
  final _blinkNewOrder = false.obs;
  final _stopSoundOnPendingPressed = false.obs;
  final _delayOnDonePressed = false.obs;
  final audioPlayer = AudioPlayer();
  final _soundList = <String, String>{
    'new_order1': 'New Order 1',
    'new_order2': 'New Order 2',
    'new_order3': 'New Order 3',
    'new_order4': 'New Order 4',
    'new_order5': 'New Order 5',
    'new_order6': 'New Order 6',
  };

  @override
  void initState() {
    super.initState();
    final serverIp = _box.read('server_ip');
    if (serverIp != null) {
      _controller.text = serverIp;
    }
    _repeatSoundValue.value = _box.read('repeat_sound') ?? false;
    _blinkNewOrder.value = _box.read('blink_new_order') ?? false;
    _stopSoundOnPendingPressed.value =
        _box.read('stop_sound_on_pending_pressed') ?? false;
    _delayOnDonePressed.value = _box.read('delay_on_done_pressed') ?? false;
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    Get.snackbar('Setting', message, snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleLarge = textTheme.titleLarge;
    final bodyLarge = textTheme.bodyLarge;
    return Scaffold(
      appBar: AppBar(title: Text('SETTINGS', style: titleLarge)),
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
                    _showSnackbar('Server ip address saved');
                  }
                },
                icon: const Icon(Icons.check),
              ),
            ),
            DropdownMenu<String>(
              label: const Text('Notification Sound'),
              hintText: 'Select Sound',
              width: double.maxFinite,
              expandedInsets: const EdgeInsets.all(16.0),
              inputDecorationTheme: const InputDecorationTheme(
                border: UnderlineInputBorder(),
              ),
              initialSelection:
                  (_box
                      .read<String>('sound')
                      ?.split('/')
                      .last
                      .split('.')
                      .first) ??
                  'new_order1',
              dropdownMenuEntries:
                  _soundList.entries.map((entry) {
                    return DropdownMenuEntry(
                      leadingIcon: IconButton(
                        onPressed: () async {
                          final sound = 'sounds/${entry.key}.mp3';
                          await audioPlayer.play(AssetSource(sound));
                        },
                        icon: const Icon(Icons.play_arrow),
                      ),
                      value: entry.key,
                      label: entry.value,
                    );
                  }).toList(),
              onSelected: (value) async {
                if (value == null) return;
                final sound = 'sounds/$value.mp3';
                await _box.write('sound', sound);
                _showSnackbar('Sound saved');
              },
            ),
            Obx(
              () => SwitchListTile(
                title: const Text('Repeat Sound'),
                subtitle: const Text('Repeat sound when new order comes'),
                value: _repeatSoundValue.value,
                onChanged: (value) async {
                  _repeatSoundValue.value = value;
                  await _box.write('repeat_sound', value);
                },
              ),
            ),
            Obx(
              () => SwitchListTile(
                title: const Text('Blink New Order'),
                subtitle: const Text('Enable blink effect for new orders'),
                value: _blinkNewOrder.value,
                onChanged: (value) async {
                  _blinkNewOrder.value = value;
                  await _box.write('blink_new_order', value);
                },
              ),
            ),
            Obx(
              () => SwitchListTile(
                title: const Text('Stop Sound on Pending Pressed'),
                subtitle: const Text(
                  'Stop sound when pending button is pressed',
                ),
                value: _stopSoundOnPendingPressed.value,
                onChanged: (value) async {
                  _stopSoundOnPendingPressed.value = value;
                  await _box.write('stop_sound_on_pending_pressed', value);
                },
              ),
            ),
            Obx(
              () => SwitchListTile(
                title: const Text('Delay on Done Pressed'),
                subtitle: const Text('Delay before marking order as done'),
                value: _delayOnDonePressed.value,
                onChanged: (value) async {
                  _delayOnDonePressed.value = value;
                  await _box.write('delay_on_done_pressed', value);
                  _showSnackbar('Delay on done pressed saved');
                },
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
      title: TextField(controller: controller),
      subtitle: Text(label, style: bodyLarge),
      leading: IconButton(
        onPressed: onDonePressed,
        icon: const Icon(Icons.check),
      ),
    );
  }
}
