import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitchen_display_system/models/department.dart';
import 'package:kitchen_display_system/models/order_types.dart';
import 'package:kitchen_display_system/pages/kitchen_display_page/single_choice_widget.dart';

class KDSAppBar extends StatelessWidget {
  final RxBool reconnecting;
  final RxString selectedDepartment;
  final Rx<OrderType> selection;
  final RxList<Department> departments;
  final RxList<int> count;
  final Future<void> Function(String department) onUpdatePressed;
  final void Function({String? connectionId}) onReconnected;
  final void Function({Exception? error}) onReconnecting;
  final void Function(OrderType) onSelectionChanged;
  const KDSAppBar({
    super.key,
    required this.reconnecting,
    required this.selectedDepartment,
    required this.selection,
    required this.departments,
    required this.count,
    required this.onUpdatePressed,
    required this.onReconnected,
    required this.onReconnecting,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Obx(() {
        Widget child;
        if (reconnecting.value) {
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
        return Row(
          children: [
            child,
            const Spacer(),
            SingleChoice(
              count: count,
              selected: selection.value,
              onSelectionChanged: onSelectionChanged,
            ),
            const Spacer(flex: 2),
          ],
        );
      }),
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
                await onUpdatePressed(selectedDepartment.value);
                return;
              case 'departments':
                return;
              default:
                selectedDepartment.value = value;
                await onUpdatePressed(selectedDepartment.value);
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem<String>(value: 'update', child: Text('UPDATE')),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'departments',
                  child: Text('DEPARTMENTS'),
                ),
                const PopupMenuDivider(),
                ...departments.map(
                  (e) =>
                      PopupMenuItem<String>(value: e.name, child: Text(e.name)),
                ),
              ],
        ),
      ],
    );
  }
}
