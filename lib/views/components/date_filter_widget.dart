import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';

class DateFilterWidget extends StatefulWidget {
  final Function(DateTime? start, DateTime? end) onDateRangeChanged;

  const DateFilterWidget({Key? key, required this.onDateRangeChanged}) : super(key: key);

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  String _selectedOption = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, String>> _options = [
    {'value': 'all', 'label': 'Tất cả thời gian'},
    {'value': 'today', 'label': 'Hôm nay'},
    {'value': 'this_week', 'label': 'Tuần này'},
    {'value': 'this_month', 'label': 'Tháng này'},
    {'value': 'this_year', 'label': 'Năm nay'},
    {'value': 'custom', 'label': 'Tùy chỉnh...'},
  ];

  void _handleOptionChange(String? value) async {
    if (value == null) return;

    DateTime now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (value == 'today') {
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (value == 'this_week') {
      // Đầu tuần là Thứ 2
      int daysToSubtract = now.weekday - 1;
      DateTime monday = now.subtract(Duration(days: daysToSubtract));
      start = DateTime(monday.year, monday.month, monday.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (value == 'this_month') {
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (value == 'this_year') {
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (value == 'custom') {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: now,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        start = picked.start;
        end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      } else {
        // Hủy chọn custom, giữ nguyên option cũ
        return;
      }
    }

    setState(() {
      _selectedOption = value;
      _startDate = start;
      _endDate = end;
    });

    widget.onDateRangeChanged(_startDate, _endDate);
  }

  @override
  Widget build(BuildContext context) {
    String displayDate = '';
    if (_selectedOption == 'custom' && _startDate != null && _endDate != null) {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      displayDate = ' (${formatter.format(_startDate!)} - ${formatter.format(_endDate!)})';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 18, color: Colors.white54),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedOption,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
              style: const TextStyle(color: Colors.white),
              dropdownColor: secondaryColor,
              onChanged: _handleOptionChange,
              items: _options.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(option['label']! + (option['value'] == 'custom' ? displayDate : '')),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
