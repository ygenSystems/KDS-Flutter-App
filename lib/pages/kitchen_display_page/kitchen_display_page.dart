import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:kitchen_display_system/models/department.dart';
import 'package:kitchen_display_system/models/order.dart';
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

  OrderType _selection = OrderType.all;
  final List<Order> _orders = [];
  final List<Department> _departments = [];
  List<int> _count = [0, 0, 0, 0];
  bool _updating = false;
  String _selectedDepartment = 'ALL';

  @override
  void initState() {
    super.initState();
    _vm = Get.find();
    _updating = true;
    _vm.getDepartments().then((value) async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        _departments.addAll(value);
      });
    });
    _vm.getOrders().then((value) async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _updateOrdersSelection();
      });
      _updating = false;
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {});
    });

    _vm.getOrderStream().listen((value) {
      _onUpdatePressed();
    });
  }

  void _updateOrdersSelection() {
    _orders.clear();
    _count = [0, 0, 0, 0];
    for (var element in _vm.orders) {
      if (_selection == OrderType.all) {
        _orders.add(element);
      } else if (element.orderType == _selection) {
        _orders.add(element);
      }
      _count[0]++;
      if (element.orderType == OrderType.dineIn) {
        _count[1]++;
      } else if (element.orderType == OrderType.takeAway) {
        _count[2]++;
      } else if (element.orderType == OrderType.delivery) {
        _count[3]++;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _vm.dispose();
    Get.delete<KitchenDisplayController>();
    Get.delete<OrdersRepository>();
  }

  void _onUpdatePressed() {
    if (!mounted) return;
    setState(() {
      _updating = true;
    });
    _vm.getOrders().then((value) {
      setState(() {
        _updateOrdersSelection();
        _updating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool itemExists = false;
    final listOrders = <Order>[];
    if (_selectedDepartment != 'ALL') {
      for (var order in _orders) {
        for (var item in order.items) {
          if (item.department == _selectedDepartment) {
            itemExists = true;
            break;
          }
        }
        for (var deal in order.deals) {
          for (var dealItem in deal.dealItems) {
            if (dealItem.department == _selectedDepartment) {
              itemExists = true;
              break;
            }
          }
          if (itemExists) break;
        }
        for (var lessItem in order.lessItems) {
          if (lessItem.department == _selectedDepartment) {
            itemExists = true;
            break;
          }
        }

        if (itemExists) {
          listOrders.add(order);
          itemExists = false;
        }
      }
    } else {
      listOrders.addAll(_orders);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DropdownMenu<String>(
              initialSelection: _selectedDepartment,
              width: 250,
              dropdownMenuEntries: _departments
                  .map(
                    (e) => DropdownMenuEntry<String>(
                      value: e.name,
                      label: e.name,
                    ),
                  )
                  .toList(),
              onSelected: (value) {
                setState(() {
                  _selectedDepartment = value ?? 'ALL';
                });
              },
            ),
            SingleChoice(
              count: _count,
              selected: _selection,
              onSelectionChanged: (value) {
                if (!mounted) return;
                setState(() {
                  _selection = value;
                  _updateOrdersSelection();
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _onUpdatePressed,
            icon: const Icon(Icons.refresh),
            label: Text(_updating ? 'Please Wait' : 'Update'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: MasonryGridView.count(
          itemCount: listOrders.length,
          crossAxisCount: 4,
          itemBuilder: (context, index) {
            final order = listOrders[index];

            return SizedBox(
              width: 300,
              child: TicketWidget(
                selectedDepartment: _selectedDepartment,
                order: order,
                onDonePressed: (orderNumber) {
                  _vm.updateOrder(orderNumber, 'done');
                },
                onPreparingPressed: (orderNumber) {
                  _vm.updateOrder(orderNumber, 'preparing');
                },
              ),
            );
          },
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
          label: Text('All (${count[0]})', style: style),
          icon: Icon(Icons.all_inclusive, color: primaryColor),
        ),
        ButtonSegment<OrderType>(
          value: OrderType.dineIn,
          label: Text('Dine In (${count[1]})', style: style),
          icon: Icon(Icons.table_restaurant, color: primaryColor),
        ),
        ButtonSegment<OrderType>(
          value: OrderType.takeAway,
          label: Text('Takeaway (${count[2]})', style: style),
          icon: Icon(Icons.directions_walk, color: primaryColor),
        ),
        ButtonSegment<OrderType>(
          value: OrderType.delivery,
          label: Text('Delivery (${count[3]})', style: style),
          icon: Icon(Icons.pedal_bike, color: primaryColor),
        ),
      ],
      selected: <OrderType>{selected},
      onSelectionChanged: (Set<OrderType> newSelection) => onSelectionChanged(newSelection.first),
    );
  }
}
