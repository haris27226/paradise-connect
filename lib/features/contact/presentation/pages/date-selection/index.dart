import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:progress_group/core/constants/colors.dart';
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

    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfWeek.subtract(const Duration(days: 1));

    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);

    return Scaffold(
      backgroundColor: Color(whiteColor),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 HEADER
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Color(whiteColor),
                border: Border(
                  bottom: BorderSide(width: 1, color: Color(grey9Color)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back, color: Color(primaryColor), size: 27),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Filter Date",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pop(DateFilterResult(isClear: true));
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔥 LIST
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _item(context, "Today", today, today),
                  _divider(),
                  _item(context, "Yesterday", yesterday, yesterday),
                  _divider(),
                  _item(context, "This Week", startOfWeek, today),
                  _divider(),
                  _item(context, "Last Week", startOfLastWeek, endOfLastWeek),
                  _divider(),
                  _item(context, "This Month", startOfMonth, today),
                  _divider(),
                  _item(context, "Last Month", startOfLastMonth, endOfLastMonth),
                  _divider(),
                  _itemCustom(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Color(grey9Color),
      indent: 16,
    );
  }

  Widget _item(
    BuildContext context,
    String label,
    DateTime start,
    DateTime end,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.pop(_buildResult(label, start, end));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(blue2Color),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Color(grey5Color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemCustom(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Color(primaryColor),
                    onPrimary: Colors.white,
                    onSurface: Color(blue2Color),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            context.pop(
              _buildResult(
                "${DateFormat('dd MMM').format(picked.start)} - ${DateFormat('dd MMM yyyy').format(picked.end)}",
                picked.start,
                picked.end,
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Custom Range",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(blue2Color),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Color(grey5Color)),
            ],
          ),
        ),
      ),
    );
  }
}