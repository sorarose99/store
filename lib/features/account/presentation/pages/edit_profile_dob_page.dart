import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class EditProfileDobPage extends StatefulWidget {
  final String currentDob;

  const EditProfileDobPage({super.key, required this.currentDob});

  @override
  State<EditProfileDobPage> createState() => _EditProfileDobPageState();
}

class _EditProfileDobPageState extends State<EditProfileDobPage> {
  // Years list
  final List<int> _years = List.generate(100, (index) => DateTime.now().year - 99 + index);
  // Arabic months
  final List<String> _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];
  // Days
  final List<int> _days = List.generate(31, (index) => index + 1);

  late int _selectedYearIndex;
  late int _selectedMonthIndex;
  late int _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    // Parse currentDob like 'dd/mm/yyyy'
    int day = 15;
    int month = 9;
    int year = 2002;
    try {
      final parts = widget.currentDob.split('/');
      if (parts.length == 3) {
        day = int.parse(parts[0]);
        month = int.parse(parts[1]);
        year = int.parse(parts[2]);
      }
    } catch (_) {}

    _selectedYearIndex = _years.indexOf(year);
    if (_selectedYearIndex == -1) _selectedYearIndex = _years.length - 20;

    _selectedMonthIndex = month - 1;
    _selectedDayIndex = day - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background tap to close
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Scrollable Wheels popup
          Align(
            alignment: Alignment.bottomCenter,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          'تحديد تاريخ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Wheels selector row
                      SizedBox(
                        height: 160,
                        child: Stack(
                          children: [
                            // Center highlighted line
                            Center(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                // Day column
                                Expanded(
                                  child: ListWheelScrollView.useDelegate(
                                    itemExtent: 40,
                                    perspective: 0.005,
                                    diameterRatio: 1.2,
                                    controller: FixedExtentScrollController(initialItem: _selectedDayIndex),
                                    onSelectedItemChanged: (index) {
                                      _selectedDayIndex = index;
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: _days.length,
                                      builder: (context, index) => Center(
                                        child: Text(
                                          '${_days[index]}',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Month column
                                Expanded(
                                  child: ListWheelScrollView.useDelegate(
                                    itemExtent: 40,
                                    perspective: 0.005,
                                    diameterRatio: 1.2,
                                    controller: FixedExtentScrollController(initialItem: _selectedMonthIndex),
                                    onSelectedItemChanged: (index) {
                                      _selectedMonthIndex = index;
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: _months.length,
                                      builder: (context, index) => Center(
                                        child: Text(
                                          _months[index],
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Year column
                                Expanded(
                                  child: ListWheelScrollView.useDelegate(
                                    itemExtent: 40,
                                    perspective: 0.005,
                                    diameterRatio: 1.2,
                                    controller: FixedExtentScrollController(initialItem: _selectedYearIndex),
                                    onSelectedItemChanged: (index) {
                                      _selectedYearIndex = index;
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: _years.length,
                                      builder: (context, index) => Center(
                                        child: Text(
                                          '${_years[index]}',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Cancel and Apply actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFFEEEEEE)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final dayStr = '${_selectedDayIndex + 1}'.padLeft(2, '0');
                                final monthStr = '${_selectedMonthIndex + 1}'.padLeft(2, '0');
                                final yearStr = '${_years[_selectedYearIndex]}';
                                Navigator.pop(context, '$dayStr/$monthStr/$yearStr');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'تطبيق',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
