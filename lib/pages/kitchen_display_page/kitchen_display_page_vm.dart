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

  Future<List<Order>> getOrders() async {
    try {
      final newOrders = await _repo.getKDSOrders();
      bool itemsChanged = false;
      for (var newOrder in newOrders) {
        final prevOrder =
            orders.firstWhereOrNull((o) => o.number == newOrder.number);
        if (prevOrder != null) {
          if (newOrder.items.length != prevOrder.items.length ||
              newOrder.lessItems.length != prevOrder.lessItems.length) {
            itemsChanged = true;
            break;
          }
        } else {
          // New order added
          itemsChanged = true;
          break;
        }
      }
      // Do NOT play sound if an order is removed (skip this block)
      // else if (orders.isEmpty && newOrders.isNotEmpty) {
      //   itemsChanged = true;
      // }
      if (orders.isEmpty && newOrders.isNotEmpty) {
        itemsChanged = true;
      }
      if (itemsChanged) {
        _playNewOrderSound();
      }
      orders = newOrders;
      return orders;
    } catch (e) {
      return orders;
    }
  }

  Future<void> _playNewOrderSound() async {
    // Replace with your sound asset path or URL
    final sound = GetStorage().read<String?>('sound') ?? 'new_order1.mp3';
    await _audioPlayer.play(AssetSource(sound));
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
