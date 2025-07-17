import 'dart:async';

import 'package:flutter/material.dart';
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
  final _updating = false.obs;
  final _selectedDepartment = 'ALL'.obs;
  final _gridOrders = <Order>[].obs;
  final _pageController = PageController();
  final _gridController = ScrollController();
  final _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _vm = Get.find();
    _updating.value = true;
    _vm.getDepartments().then((value) async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      _departments.assignAll(value);
    });
    _vm.getOrders('').then((value) async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _updateOrdersCount();
      _updating.value = false;
    });
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   if (!mounted) return;
    //   _updateOrdersCount();
    // });

    _vm.updateListener().listen((value) {
      _onUpdatePressed(_selectedDepartment.value);
    });
  }

  void _updateOrdersCount() {
    final currentList = <Order>[];
    final count = <int>[];
    count.addAll([0, 0, 0, 0]);
    for (var element in _vm.orders) {
      if (_selection.value == OrderType.all) {
        currentList.add(element);
      } else if (element.orderType == _selection.value) {
        currentList.add(element);
      }
      count[0]++;
      if (element.orderType == OrderType.dineIn) {
        count[1]++;
      } else if (element.orderType == OrderType.takeAway) {
        count[2]++;
      } else if (element.orderType == OrderType.delivery) {
        count[3]++;
      }
    }

    _gridOrders.assignAll(
      currentList.length > 4 ? currentList.take(4).toList() : currentList,
    );
    _count.assignAll(count);

    final dict1 = _orders.map((e) => e.number).toSet();
    final dict2 = currentList.map((e) => e.number).toSet();

    final difference1 = dict2.difference(dict1);
    if (difference1.isNotEmpty) {
      _vm.playSound();
    }

    _orders.clear();
    _orders.addAll(currentList);
  }

  @override
  void dispose() {
    super.dispose();
    _vm.dispose();
    Get.delete<KitchenDisplayController>();
    Get.delete<OrdersRepository>();
    _pageController.dispose();
    _gridController.dispose();
    _listController.dispose();
  }

  Future<void> _onUpdatePressed(String department) async {
    if (_updating.value) return;
    _updating.value = true;
    await _vm.getOrders(department);
    _updateOrdersCount();
    _updating.value = false;
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
      return Colors.yellow.withValues(alpha: 0.8);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Obx(
          () => SingleChoice(
            count: _count,
            selected: _selection.value,
            onSelectionChanged: (value) {
              if (!mounted) return;
              _selection.value = value;
              _updateOrdersCount();
            },
          ),
        ),
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
                  PopupMenuItem<String>(
                    value: 'update',
                    child: Text(_updating.value ? 'PLEASE WAIT' : 'UPDATE'),
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Placeholder(
                child: Obx(
                  () => PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _pageController,
                    itemCount: _orders.length,
                    onPageChanged: (value) {
                      print('Page changed to: $value');
                      var orders = _orders.skip(value * 4).take(4).toList();
                      _gridOrders.assignAll(orders);
                    },
                    itemBuilder: (context, pageIndex) {
                      return Obx(
                        () => GridView.builder(
                          controller: _gridController,
                          itemCount: _gridOrders.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 1.0,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            Color? baseColor = _checkOrderOverTime(
                              order.orderTime,
                            );
                            Color? alternate = _blinkOnNewOrder(order.status);
                            return TicketWidget(
                              baseColor: baseColor,
                              alternateColor: alternate,
                              order: order,
                              onDonePressed: () {
                                _vm.updateOrder(order.number, 'done');
                                _vm.stopSound();
                              },
                              onPreparingPressed: () {
                                _vm.updateOrder(order.number, 'preparing');
                                _vm.stopSound();
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              height: 100,
              child: Obx(
                () => ListView.builder(
                  controller: _listController,
                  itemCount: _orders.length,
                  scrollDirection: Axis.horizontal,

                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    Color? baseColor = _checkOrderOverTime(order.orderTime);
                    Color? alternate = _blinkOnNewOrder(order.status);

                    String timeSince = '';
                    final now = DateTime.now();
                    final difference = now.difference(order.orderTime);
                    if (difference.inMinutes > 0) {
                      timeSince = '${difference.inMinutes} min ';
                    } else if (difference.inSeconds > 0) {
                      timeSince = '${difference.inSeconds} sec ';
                    } else {
                      timeSince = 'Just now';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                order.number,
                                style: TextStyle(
                                  color: baseColor ?? Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const Divider(),
                              Text(
                                timeSince,
                                style: TextStyle(
                                  color: baseColor ?? Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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
