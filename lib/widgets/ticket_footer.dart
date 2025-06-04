import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kitchen_display_system/models/order.dart';
import 'package:kitchen_display_system/models/order_status.dart';

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
                color: status == OrderStatus.preparing
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                    : null,
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'PREPARING',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
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
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
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
