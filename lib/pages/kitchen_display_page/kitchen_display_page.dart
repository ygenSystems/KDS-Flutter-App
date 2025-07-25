import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitchen_display_system/models/department.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_status.dart';
import 'package:kitchen_display_system/models/order_types.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/kds_appbar_widget.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/kitchen_display_page_vm.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/order_tile_widget.dart';
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

  final _pageController = PageController();
  final _scrollController = ScrollController();
  final _pageOrders = <Order>[].obs;

  final count = 6;

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: KDSAppBar(
          onReconnected: _onReconnected,
          onReconnecting: _onReconnecting,
          reconnecting: _reconnecting,
          selectedDepartment: _selectedDepartment,
          selection: _selection,
          count: _count,
          departments: _departments,
          onUpdatePressed: _onUpdatePressed,
          onSelectionChanged: (value) {
            if (!mounted) return;
            _selection.value = value;
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Obx(
                () => PageView.builder(
                  controller: _pageController,
                  itemCount: (_orders.length / count).ceil(),
                  itemBuilder: (context, index1) {
                    _pageOrders.assignAll(
                      _orders.skip(index1 * count).take(count),
                    );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var order in _pageOrders)
                          Builder(
                            builder: (context) {
                              Color? baseColor = _checkOrderOverTime(
                                order.orderTime,
                              );
                              Color? alternate = _blinkOnNewOrder(order.status);
                              return SizedBox(
                                width: 300,
                                child: TicketWidget(
                                  order: order,
                                  baseColor: baseColor,
                                  alternateColor: alternate,
                                  onDonePressed: (orderId) async {
                                    if (await _vm.updateOrder(
                                      orderId,
                                      'done',
                                    )) {
                                      _orders.removeWhere(
                                        (e) => e.id == orderId,
                                      );
                                      _updateCount(order.orderType, false);
                                      _vm.stopSound();
                                    }
                                  },
                                  onPreparingPressed: (orderId) async {
                                    if (await _vm.updateOrder(
                                      orderId,
                                      'preparing',
                                    )) {
                                      _vm.stopSound();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                Color? baseColor = _checkOrderOverTime(order.orderTime);
                final primaryColor = Theme.of(context).primaryColor;
                return InkWell(
                  onTap: () {
                    final value = index ~/ count;
                    _pageController.animateToPage(
                      value,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: OrderTile(
                            primaryColor: primaryColor,
                            baseColor: baseColor,
                            order: order,
                          ),
                        ),
                        // Place VerticalDivider after every fifth widget except the last one
                        if ((index + 1) % 5 == 0 && index != _orders.length - 1)
                          const VerticalDivider(
                            color: Colors.white,
                            width: 1,
                            thickness: 1,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
