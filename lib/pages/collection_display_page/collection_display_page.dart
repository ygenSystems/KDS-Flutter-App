import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_status.dart';
import 'package:kitchen_display_system/pages/collection_display_page/collection_display_page_vm.dart';
import 'package:kitchen_display_system/widgets/customer_ticket_widget.dart';

class CollectionDisplayPage extends StatefulWidget {
  const CollectionDisplayPage({super.key});

  @override
  State<CollectionDisplayPage> createState() => _CollectionDisplayPageState();
}

class _CollectionDisplayPageState extends State<CollectionDisplayPage> {
  late final CollectionDisplayPageVM _vm;
  Timer? _updateTimer;
  int _updateCount = 5;

  @override
  void initState() {
    super.initState();
    _vm = Get.find();
    _updateTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateCount--;
        if (_updateCount == 0) {
          _updateCount = 5;
          _vm.getOrders();
        }
        _updateOrders();
      }
    });
  }

  final List<Order> _preparingOrders = [];
  final List<Order> _doneOrders = [];

  void _updateOrders() {
    setState(() {
      _preparingOrders.clear();
      _doneOrders.clear();
      for (var order in _vm.orders) {
        if (order.status == OrderStatus.preparing) {
          _preparingOrders.add(order);
        } else if (order.status == OrderStatus.done) {
          _doneOrders.add(order);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      childAspectRatio: 4.5,
    );
    return Scaffold(
      appBar: AppBar(
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'PREPARING',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: delegate,
                      itemCount: _preparingOrders.length,
                      itemBuilder: (context, index) {
                        final order = _preparingOrders[index];
                        return CustomerTicket(order: order);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'NOW SERVING',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: delegate,
                      itemCount: _doneOrders.length,
                      itemBuilder: (context, index) {
                        final order = _doneOrders[index];
                        return CustomerTicket(order: order);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
