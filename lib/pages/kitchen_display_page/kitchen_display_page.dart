import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:kitchen_display_system/models/department.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_status.dart';
import 'package:kitchen_display_system/models/order_types.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/kitchen_display_page_vm.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';
import 'package:kitchen_display_system/widgets/ticket_widget.dart';

class KitchenDisplayPage extends StatefulWidget {
  const KitchenDisplayPage({super.key});

  @override
  State<KitchenDisplayPage> createState() => _KitchenDisplayPageState();
}

class _KitchenDisplayPageState extends State<KitchenDisplayPage> {
  late final KitchenDisplayController _vm;

  final _selection = OrderType.all.obs;
  final _orders = <Order>[].obs;
  final _departments = <Department>[].obs;
  final _count = [0, 0, 0, 0].obs;
  final _selectedDepartment = 'ALL'.obs;
  late final Timer _timer;
  final _reconnecting = false.obs;

  @override
  void initState() {
    super.initState();
    _vm = Get.find();
    _vm.setupSignalR(_onReconnected, _onReconnecting).then((_) {
      _vm.updateListener(_onOrderUpdate);
      _vm.getOrders('');
    });
    _vm.getDepartments().then((value) async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _departments.assignAll(value);
    });
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _onReconnected({String? connectionId}) {
    _reconnecting.value = false;
  }

  void _onReconnecting({Exception? error}) {
    _reconnecting.value = true;
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _vm.dispose();
    Get.delete<KitchenDisplayController>();
    Get.delete<OrdersRepository>();
  }

  void _onOrderUpdate(Order value) {
    List<Order> orders = [..._orders];
    var order = orders.firstWhereOrNull((e) => e.id == value.id);
    final orderExists = order != null;
    if (orderExists) {
      orders.remove(order);
    }
    if (!orderExists) {
      _updateCount(value.orderType, true);
    }
    orders.add(value);
    if (orders.length != _orders.length) {
      _vm.playSound();
    }
    orders.sort((a, b) => int.parse(a.number).compareTo(int.parse(b.number)));
    _orders.assignAll(orders);
  }

  Future<void> _onUpdatePressed(String department) async {
    _orders.clear();
    _count.clear();
    _count.addAll([0, 0, 0, 0]);
    await _vm.getOrders(department);
  }

  Color? _blinkOnNewOrder(OrderStatus orderStatus) {
    if (!_vm.blinkOnNewOrder()) return null;
    if (orderStatus == OrderStatus.pending) {
      final isOdd = DateTime.now().second.isOdd;
      if (isOdd) {
        return Colors.white.withValues(alpha: 0.8);
      }
    }
    return null;
  }

  Color? _checkOrderOverTime(DateTime orderTime) {
    final now = DateTime.now();
    final difference = now.difference(orderTime).inMinutes;
    if (difference >= 20) {
      return Colors.red.withValues(alpha: 0.8);
    } else if (difference >= 15) {
      return Colors.yellow.shade800.withValues(alpha: 0.8);
    }
    return null;
  }

  void _updateCount(OrderType type, bool increment) {
    if (increment) {
      _count[0]++;
      if (type == OrderType.dineIn) {
        _count[1]++;
      } else if (type == OrderType.takeAway) {
        _count[2]++;
      } else if (type == OrderType.delivery) {
        _count[3]++;
      }
    } else {
      _count[0]--;
      if (type == OrderType.dineIn) {
        _count[1]--;
      } else if (type == OrderType.takeAway) {
        _count[2]--;
      } else if (type == OrderType.delivery) {
        _count[3]--;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Obx(() {
          Widget child;
          if (_reconnecting.value) {
            child = SizedBox(
              width: 350,
              child: Row(
                children: [
                  Flexible(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade800.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.yellow.shade800),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Reconnecting...'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            child = const SizedBox(width: 350);
          }
          return Row(
            children: [
              child,
              const Spacer(),
              SingleChoice(
                count: _count,
                selected: _selection.value,
                onSelectionChanged: (value) {
                  if (!mounted) return;
                  _selection.value = value;
                },
              ),
              const Spacer(flex: 2),
            ],
          );
        }),
        actions: [
          PopupMenuButton<String>(
            child: const SizedBox(
              width: 150,
              child: ListTile(
                title: Text('OPTIONS'),
                trailing: Icon(Icons.more_vert),
              ),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'update':
                  await _onUpdatePressed(_selectedDepartment.value);
                  return;
                case 'departments':
                  return;
                default:
                  _selectedDepartment.value = value;
                  await _onUpdatePressed(_selectedDepartment.value);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(value: 'update', child: Text('UPDATE')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'departments',
                    child: Text('DEPARTMENTS'),
                  ),
                  const PopupMenuDivider(),
                  ..._departments.map(
                    (e) => PopupMenuItem<String>(
                      value: e.name,
                      child: Text(e.name),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Obx(
          () => MasonryGridView.builder(
            itemCount: _orders.length,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemBuilder: (context, index) {
              final order = _orders[index];
              Color? baseColor = _checkOrderOverTime(order.orderTime);
              Color? alternate = _blinkOnNewOrder(order.status);
              return SizedBox(
                width: 300,
                child: TicketWidget(
                  baseColor: baseColor,
                  alternateColor: alternate,
                  order: order,
                  onDonePressed: (orderId) async {
                    if (await _vm.updateOrder(orderId, 'done')) {
                      _orders.removeWhere((e) => e.id == orderId);
                      _updateCount(order.orderType, false);
                      _vm.stopSound();
                    }
                  },
                  onPreparingPressed: (orderId) async {
                    if (await _vm.updateOrder(orderId, 'preparing')) {
                      _vm.stopSound();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SingleChoice extends StatelessWidget {
  final OrderType selected;
  final List<int> count;
  final void Function(OrderType) onSelectionChanged;
  const SingleChoice({
    super.key,
    required this.selected,
    required this.onSelectionChanged,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final style = TextStyle(color: primaryColor);
    return SegmentedButton<OrderType>(
      segments: <ButtonSegment<OrderType>>[
        ButtonSegment<OrderType>(
          value: OrderType.all,
          label: Obx(() => Text('All (${count[0]})', style: style)),
          icon: Icon(Icons.all_inclusive, color: primaryColor),
        ),
        ButtonSegment<OrderType>(
          value: OrderType.dineIn,
          label: Obx(() => Text('Dine In (${count[1]})', style: style)),
          icon: Icon(Icons.table_restaurant, color: primaryColor),
        ),
        ButtonSegment<OrderType>(
          value: OrderType.takeAway,
          label: Obx(() => Text('Takeaway (${count[2]})', style: style)),
          icon: Icon(Icons.directions_walk, color: primaryColor),
        ),
        ButtonSegment<OrderType>(
          value: OrderType.delivery,
          label: Obx(() => Text('Delivery (${count[3]})', style: style)),
          icon: Icon(Icons.pedal_bike, color: primaryColor),
        ),
      ],
      selected: <OrderType>{selected},
      onSelectionChanged:
          (Set<OrderType> newSelection) =>
              onSelectionChanged(newSelection.first),
    );
  }
}
