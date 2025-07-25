import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitchen_display_system/models/order.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({
    super.key,
    required this.primaryColor,
    required this.baseColor,
    required this.order,
  });

  final Color primaryColor;
  final Color? baseColor;
  final Order order;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: primaryColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColoredBox(
                color: baseColor ?? Colors.white,
                child: SizedBox(
                  height: 45,
                  width: double.maxFinite,
                  child: Center(
                    child: Text(
                      order.number,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: baseColor == null ? Colors.black : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 45,
                width: double.maxFinite,
                child: Center(
                  child: Text(
                    DateFormat.jm().format(order.orderTime),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                    textAlign: TextAlign.center,
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
