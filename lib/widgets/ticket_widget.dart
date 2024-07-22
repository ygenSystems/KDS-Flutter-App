import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitchen_display_system/models/deal.dart';
import 'package:kitchen_display_system/models/item.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_status.dart';
import 'package:kitchen_display_system/models/order_types.dart';
import 'package:kitchen_display_system/widgets/dashed_divider.dart';

class TicketWidget extends StatelessWidget {
  final String selectedDepartment;
  final Order order;
  final void Function(String orderNumber) onDonePressed;
  final void Function(String orderNumber) onPreparingPressed;
  const TicketWidget({
    super.key,
    required this.selectedDepartment,
    required this.order,
    required this.onDonePressed,
    required this.onPreparingPressed,
  });

  @override
  Widget build(BuildContext context) {
    const divider = SizedBox(height: 2.0);
    final primaryColor = Theme.of(context).primaryColor;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TicketHeader(order: order),
            divider,
            TicketSubHeader(order: order),
            Divider(color: primaryColor),
            TicketDetails(
              title: 'ITEMS',
              selectedDepartment: selectedDepartment,
              order: order,
            ),
            if (order.lessItems.isNotEmpty) Divider(color: primaryColor),
            if (order.lessItems.isNotEmpty)
              TicketDetails(
                title: 'LESS ITEMS',
                selectedDepartment: selectedDepartment,
                order: order,
              ),
            Divider(color: primaryColor),
            TicketFooter(
              order: order,
              onDonePressed: onDonePressed,
              onPreparingPressed: onPreparingPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class TicketHeader extends StatelessWidget {
  final Order order;
  const TicketHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColor,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${order.orderType.name.toUpperCase()} (${order.duration.inMinutes % 60}:${order.duration.inSeconds % 60})',
          style: textStyle,
        ),
        Text(
          order.number,
          style: textStyle,
        ),
      ],
    );
  }
}

class TicketSubHeader extends StatelessWidget {
  final Order order;
  const TicketSubHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (order.orderType == OrderType.dineIn)
              LimitedBox(
                maxWidth: 50,
                child: Text(
                  'Tbl: ${order.tableNumber}'.toUpperCase(),
                  style: TextStyle(color: primaryColor),
                ),
              )
            else
              const Text('- - - - - - - -'),
            LimitedBox(
              maxWidth: 150,
              child: Text(
                'Wtr: ${order.waiter}'.toUpperCase(),
                style: TextStyle(color: primaryColor, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time: ${DateFormat('hh:mm a').format(order.orderTime)}'.toUpperCase(),
              style: TextStyle(color: primaryColor),
            ),
            const Text(''),
          ],
        ),
      ],
    );
  }
}

class TicketDetails extends StatelessWidget {
  final String title;
  final Order order;
  final String selectedDepartment;
  const TicketDetails({
    super.key,
    required this.title,
    required this.order,
    required this.selectedDepartment,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final items = <Item>[];
    final lessItems = <Item>[];
    final deals = <Deal>[];
    final lessDeals = <Deal>[];
    if (selectedDepartment == 'ALL') {
      items.addAll(order.items);
      deals.addAll(order.deals);
      lessItems.addAll(order.deals);
      lessDeals.addAll(order.lessDeals);
    } else {
      for (var item in order.items) {
        if (item.department == selectedDepartment) {
          items.add(item);
        }
      }

      for (var deal in order.deals) {
        final list = <DealItem>[];
        for (var dealItem in deal.dealItems) {
          if (dealItem.department == selectedDepartment) {
            list.add(dealItem);
          }
        }
        if (list.isEmpty) continue;
        final d = Deal(
          id: deal.id,
          name: deal.name,
          department: deal.department,
          comment: deal.comment,
          isNew: deal.isNew,
          quantity: deal.quantity,
          status: deal.status,
          dealItems: list,
        );
        deals.add(d);
      }

      for (var deal in order.lessDeals) {
        final list = <DealItem>[];
        for (var dealItem in deal.dealItems) {
          if (dealItem.department == selectedDepartment) {
            list.add(dealItem);
          }
        }
        if (list.isEmpty) continue;
        final d = Deal(
          id: deal.id,
          name: deal.name,
          department: deal.department,
          comment: deal.comment,
          isNew: deal.isNew,
          quantity: deal.quantity,
          status: deal.status,
          dealItems: list,
        );
        lessDeals.add(d);
      }
    }

    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            Divider(color: primaryColor),
          ],
        ),
        ..._getItems(items, primaryColor),
        ..._getDeals(deals, primaryColor),
        ..._getItems(lessItems, primaryColor),
        ..._getDeals(lessDeals, primaryColor),
      ],
    );
  }

  List<Widget> _getItems(List<Item> items, Color primaryColor) {
    return List.generate(
      items.length,
      (index) {
        final item = items[index];
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    item.name.toUpperCase(),
                    style: TextStyle(
                      color: title == 'LESS ITEMS'
                          ? Colors.red
                          : item.isNew
                              ? Colors.green
                              : primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  item.quantity.toString(),
                  style: TextStyle(
                    color: title == 'LESS ITEMS'
                        ? Colors.red
                        : item.isNew
                            ? Colors.green
                            : primaryColor,
                  ),
                ),
              ],
            ),
            if (item.comment.isNotEmpty)
              Row(
                children: [
                  Text(
                    '- ${item.comment}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            const DashedDivider(),
          ],
        );
      },
    );
  }

  List<Widget> _getDeals(List<Deal> deals, Color primaryColor) {
    return List.generate(
      deals.length,
      (index) {
        final deal = deals[index];
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    deal.name.toUpperCase(),
                    style: TextStyle(
                      color: title == 'LESS ITEMS'
                          ? Colors.red
                          : deal.isNew
                              ? Colors.green
                              : primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  deal.quantity.toString(),
                  style: TextStyle(
                    color: title == 'LESS ITEMS'
                        ? Colors.red
                        : deal.isNew
                            ? Colors.green
                            : primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ...List.generate(deal.dealItems.length, (index) {
              final dealitem = deal.dealItems[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '   ${dealitem.name.toUpperCase()}',
                      style: TextStyle(
                        color: title == 'LESS ITEMS'
                            ? Colors.red
                            : deal.isNew
                                ? Colors.green
                                : primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Text(
                    '     ${dealitem.quantity.toString()}',
                    style: TextStyle(
                      color: title == 'LESS ITEMS'
                          ? Colors.red
                          : deal.isNew
                              ? Colors.green
                              : primaryColor,
                    ),
                  ),
                ],
              );
            }),
            if (deal.comment.isNotEmpty)
              Row(
                children: [
                  Text(
                    '- ${deal.comment}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            const DashedDivider(),
          ],
        );
      },
    );
  }
}

class TicketFooter extends StatefulWidget {
  final Order order;
  final void Function(String orderNumber) onDonePressed;
  final void Function(String orderNumber) onPreparingPressed;
  const TicketFooter({
    super.key,
    required this.order,
    required this.onDonePressed,
    required this.onPreparingPressed,
  });

  @override
  State<TicketFooter> createState() => _TicketFooterState();
}

class _TicketFooterState extends State<TicketFooter> {
  @override
  Widget build(BuildContext context) {
    final OrderStatus status = widget.order.status;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _onPreparingPressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: status == OrderStatus.preparing ? Theme.of(context).primaryColor.withOpacity(0.3) : null,
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'PREPARING',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: InkWell(
            onTap: _onDonePressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    _count == 5 ? 'DONE' : 'DONE(${_count + 1})',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Timer? _timer;
  int _count = 5;

  void _onDonePressed() {
    if (_timer != null) {
      setState(() {
        _timer?.cancel();
        _timer = null;
        _count = 5;
      });
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
    }
  }

  void _timerCallback(timer) {
    if (!mounted) return;
    setState(() {
      if (_count > 0) {
        _count--;
      } else {
        widget.onDonePressed(widget.order.id);
        _timer?.cancel();
        _count = 5;
      }
    });
  }

  void _onPreparingPressed() {
    _timer?.cancel();
    _count = 5;
    widget.onPreparingPressed(widget.order.id);
  }
}
