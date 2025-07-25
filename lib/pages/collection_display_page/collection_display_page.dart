import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_status.dart';
import 'package:kitchen_display_system/pages/collection_display_page/collection_display_page_vm.dart';
import 'package:kitchen_display_system/repositories/order_repository.dart';
import 'package:kitchen_display_system/widgets/customer_ticket_widget.dart';

class CollectionDisplayPage extends StatefulWidget {
  const CollectionDisplayPage({super.key});

  @override
  State<CollectionDisplayPage> createState() => _CollectionDisplayPageState();
}

class _CollectionDisplayPageState extends State<CollectionDisplayPage> {
  late final CollectionDisplayPageVM _vm;
  final _preparingOrders = <Order>[].obs;
  final _doneOrders = <Order>[].obs;
  final _reconnecting = false.obs;

  @override
  void initState() {
    super.initState();
    _vm = Get.find<CollectionDisplayPageVM>();

    _vm.setupSignalR(_onReconnected, _onReconnecting).then((_) async {
      await _vm.getOrders();
      _vm.getOrdersStream(_updateOrders);
    });
    Future.delayed(const Duration(seconds: 1)).then((value) {
      if (mounted) setState(() {});
    });
  }

  void _updateOrders(Order order) {
    int sortDesc(Order a, Order b) {
      return int.parse(b.number).compareTo(int.parse(a.number));
    }

    if (order.status == OrderStatus.preparing) {
      _doneOrders.removeWhere((o) => o.id == order.id);
      final temp = [..._preparingOrders];
      temp.add(order);
      temp.sort(sortDesc);
      _preparingOrders.assignAll(temp);
    } else if (order.status == OrderStatus.done) {
      _preparingOrders.removeWhere((o) => o.id == order.id);
      final temp = [..._doneOrders];
      temp.add(order);
      temp.sort(sortDesc);
      _doneOrders.assignAll(temp);
    } else if (order.status == OrderStatus.pending) {
      _preparingOrders.removeWhere((o) => o.id == order.id);
      _doneOrders.removeWhere((o) => o.id == order.id);
    }
  }

  void _onReconnected({String? connectionId}) {
    _reconnecting.value = false;
  }

  void _onReconnecting({Exception? error}) {
    _reconnecting.value = true;
  }

  Future<void> _onUpdatePressed() async {
    await _vm.getOrders();
  }

  @override
  void dispose() {
    super.dispose();
    _vm.dispose();
    Get.delete<CollectionDisplayPageVM>();
    Get.delete<OrdersRepository>();
  }

  @override
  Widget build(BuildContext context) {
    const delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      childAspectRatio: 2,
    );
    return Scaffold(
      appBar: AppBar(
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
          return Row(children: [child, const Spacer()]);
        }),
        actions: [
          TextButton.icon(
            onPressed: _onUpdatePressed,
            icon: const Icon(Icons.refresh),
            label: Text('Update'),
          ),
        ],
      ),
      body: ColoredBox(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'PREPARING',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(color: Colors.white),
                    ),
                    const Divider(),
                    Expanded(
                      child: Obx(
                        () => GridView.builder(
                          gridDelegate: delegate,
                          itemCount: _preparingOrders.length,
                          itemBuilder: (context, index) {
                            final order = _preparingOrders[index];
                            return CustomerTicket(order: order);
                          },
                        ),
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
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(color: Colors.white),
                    ),
                    const Divider(),
                    Expanded(
                      child: Obx(
                        () => GridView.builder(
                          gridDelegate: delegate,
                          itemCount: _doneOrders.length,
                          itemBuilder: (context, index) {
                            final order = _doneOrders[index];
                            return CustomerTicket(order: order);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
