import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_types.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/kitchen_display_page_vm.dart';
import 'package:kitchen_display_system/widgets/ticket_widget.dart';

class KitchenDisplayPage extends StatefulWidget {
  const KitchenDisplayPage({super.key});

  @override
  State<KitchenDisplayPage> createState() => _KitchenDisplayPageState();
}

class _KitchenDisplayPageState extends State<KitchenDisplayPage> {
  late final KitchenDisplayPageVM _vm;
  Timer? _updateTimer;
  int _updateCount = 5;

  OrderType _selection = OrderType.all;
  List<Order> _orders = [];
  List<int> _count = [0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _vm = Get.find();
    _updateTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateOrdersSelection();
          _updateCount--;
          if (_updateCount == 0) {
            _updateCount = 5;
            _vm.getOrders();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _updateOrdersSelection() {
    if (!mounted) return;

    setState(() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SingleChoice(
          count: _count,
          selected: _selection,
          onSelectionChanged: (value) {
            _selection = value;
            _updateOrdersSelection();
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              _vm.getOrders();
            },
            icon: const Icon(Icons.refresh),
            label: Text('Update ${_updateCount}s'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  children: List<Widget>.generate(
                    _orders.length,
                    (index) {
                      final order = _orders[index];
                      return TicketWidget(
                        order: order,
                        onDonePressed: (orderNumber) {
                          _vm.updateOrder(orderNumber, 'done');
                        },
                        onPreparingPressed: (orderNumber) {
                          _vm.updateOrder(orderNumber, 'preparing');
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
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
