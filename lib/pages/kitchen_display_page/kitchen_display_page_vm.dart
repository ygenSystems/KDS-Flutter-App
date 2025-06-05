import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kitchen_display_system/models/department.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';
import 'package:audioplayers/audioplayers.dart';

class KitchenDisplayController {
  late final OrdersRepository _repo;
  final AudioPlayer _audioPlayer = AudioPlayer();

  KitchenDisplayController() {
    _repo = Get.find<OrdersRepository>();
  }

  List<Order> orders = [];
  List<Department> departments = [];

  Future<List<Order>> getOrders(String department) async {
    try {
      orders = await _repo.getKDSOrders(department);
      return orders;
    } catch (e) {
      return orders;
    }
  }

  Future<void> playSound() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
    }
    final sound = GetStorage().read<String?>('sound') ?? 'new_order1.mp3';
    final repeat = GetStorage().read<bool>('repeat_sound') ?? false;
    if (repeat) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } else {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    }
    await _audioPlayer.play(AssetSource(sound));
  }

  Future<void> stopSound() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
    }
  }

  Future<List<Department>> getDepartments() async {
    try {
      return departments = await _repo.getDepartments();
    } catch (e) {
      return departments;
    }
  }

  void updateOrder(String orderNumber, String status) {
    _repo.updateOrderWSocket(orderNumber, status);
  }

  Stream<bool> getOrderStream() async* {
    await for (var event in _repo.setupKDSSocket()) {
      if (event) {
        yield event;
      }
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
    _repo.dispose();
  }
}
