import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_types.dart';

class TicketHeader extends StatelessWidget {
  final Order order;
  const TicketHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColor,
    );
    final now = DateTime.now();
    final difference = now.difference(order.orderTime).inMinutes;
    if (difference >= 15) {
      textStyle = textStyle.copyWith(color: Colors.black);
    } else if (difference >= 20) {
      textStyle = textStyle.copyWith(color: Colors.white);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OrderTime(
          orderType: order.orderType,
          orderTime: order.orderTime,
          style: textStyle,
        ),
        Text(order.number, style: textStyle.copyWith(fontSize: 20)),
      ],
    );
  }
}

class OrderTime extends StatefulWidget {
  final OrderType orderType;
  final DateTime orderTime;
  final TextStyle? style;
  const OrderTime({
    super.key,
    required this.orderType,
    required this.orderTime,
    this.style,
  });

  @override
  State<OrderTime> createState() => _OrderTimeState();
}

class _OrderTimeState extends State<OrderTime> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.orderTime);
    return Text(
      '${widget.orderType.name.toUpperCase()} (${elapsed.inMinutes % 60}:${elapsed.inSeconds % 60})',
      style: widget.style,
    );
  }
}
