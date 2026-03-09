import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import '../widgets/appointment_card.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _showUnregisteredOnly = false;

  List<dynamic> get _filteredAppointments {
    if (_showUnregisteredOnly) {
      return MockData.appointments.where((a) => !a.isRegistered).toList();
    }
    return MockData.appointments;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _formattedDate {
    return '${_selectedDate.day.toString().padLeft(2, '0')}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 350,
                    child: _buildSearchPanel(),
                  ),
                  VerticalDivider(width: 1, color: AppTheme.lineColorD9),
                  Expanded(child: _buildAppointmentList()),
                ],
              );
            }

            return Column(
              children: [
                _buildSearchPanel(),
                Expanded(child: _buildAppointmentList()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
    final appointments = _filteredAppointments;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, size: 32, color: AppTheme.primaryThemeApp),
              const SizedBox(width: 12),
              Text(
                'รายการนัดหมาย',
                style: AppTheme.generalText(
                  22,
                  fonWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ชื่อ-นามสกุล คนไข้',
                    hintStyle: TextStyle(color: AppTheme.secondaryText62),
                    prefixIcon:
                        Icon(Icons.search, color: AppTheme.secondaryText62),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.lineColorD9),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.lineColorD9),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.lineColorD9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.filter_list, color: AppTheme.primaryText),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date picker
          InkWell(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.lineColorD9),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formattedDate,
                      style: AppTheme.generalText(
                        15,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today,
                      color: AppTheme.secondaryText62, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _showUnregisteredOnly,
                      onChanged: (v) {
                        setState(
                            () => _showUnregisteredOnly = v ?? false);
                      },
                      activeColor: AppTheme.primaryThemeApp,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ยังไม่ลงทะเบียน',
                    style: AppTheme.generalText(
                      14,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ],
              ),
              Text(
                'ทั้งหมด ${appointments.length}',
                style: AppTheme.generalText(
                  14,
                  fonWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList() {
    final appointments = _filteredAppointments;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return AppointmentCard(appointment: appointments[index]);
      },
    );
  }
}
