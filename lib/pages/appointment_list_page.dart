import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../models/appointment_model.dart';
import '../models/response_model.dart';
import '../services/telemed_service.dart';
import '../widgets/appointment_card.dart';
import 'create_appointment_page.dart';

class AppointmentListPage extends ConsumerStatefulWidget {
  const AppointmentListPage({super.key});

  @override
  ConsumerState<AppointmentListPage> createState() =>
      _AppointmentListPageState();
}

class _AppointmentListPageState extends ConsumerState<AppointmentListPage> {
  final _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      final result = await TelemedService.appointment(
        context,
        date: dateStr,
      );

      if (!mounted) return;

      if (result.responseEnum == ResponseEnum.success) {
        setState(() {
          _appointments = result.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _appointments = [];
          _isLoading = false;
          _errorMessage = 'ไม่สามารถโหลดข้อมูลนัดหมายได้';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
    }
  }

  List<AppointmentModel> get _filteredAppointments {
    if (_searchQuery.isEmpty) return _appointments;
    final q = _searchQuery.toLowerCase();
    return _appointments.where((a) {
      final patientName =
          '${a.patient.prefix}${a.patient.firstName} ${a.patient.lastName}'
              .toLowerCase();
      final hn = a.patient.hn.toLowerCase();
      return patientName.contains(q) || hn.contains(q);
    }).toList();
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
      _fetchAppointments();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateAppointmentPage(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryThemeApp,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
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
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'ชื่อ-นามสกุล หรือ HN',
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

          // Count
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'ทั้งหมด ${appointments.length}',
              style: AppTheme.generalText(
                14,
                fonWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: AppTheme.secondaryText62),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style:
                  AppTheme.generalText(14, color: AppTheme.secondaryText62),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchAppointments,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    final appointments = _filteredAppointments;

    if (appointments.isEmpty) {
      return Center(
        child: Text(
          'ไม่พบรายการนัดหมาย',
          style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return AppointmentCard(appointment: appointments[index]);
        },
      ),
    );
  }
}
