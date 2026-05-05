import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/features/contact/data/models/dropdown/date_filter.dart';

class DateFilterPage extends StatelessWidget {
  const DateFilterPage({super.key});

  DateFilterResult _buildResult(String label, DateTime start, DateTime end) {
    return DateFilterResult(
      label: label,
      startDate: DateFormat('yyyy-MM-dd').format(start),
      endDate: DateFormat('yyyy-MM-dd').format(end),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    final startOfWeek =
        today.subtract(Duration(days: today.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfWeek.subtract(const Duration(days: 1));

    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter Date"),
        actions: [
          /// 🔥 CLEAR BUTTON
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                DateFilterResult(isClear: true),
              );
            },
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          _item(context, "Hari ini", today, today),
          _item(context, "Kemarin", yesterday, yesterday),
          _item(context, "Minggu ini", startOfWeek, today),
          _item(context, "Minggu kemarin", startOfLastWeek, endOfLastWeek),
          _item(context, "Bulan ini", startOfMonth, today),
          _item(context, "Bulan kemarin", startOfLastMonth, endOfLastMonth),

          const Divider(),

          ListTile(
            title: const Text("Custom Range"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (picked != null) {
                Navigator.pop(
                  context,
                  _buildResult(
                    "${DateFormat('dd MMM').format(picked.start)} - ${DateFormat('dd MMM yyyy').format(picked.end)}",
                    picked.start,
                    picked.end,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String label,
    DateTime start,
    DateTime end,
  ) {
    return ListTile(
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.pop(context, _buildResult(label, start, end));
      },
    );
  }
}