import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import '../widgets/patient_card.dart';
import 'patient_registration_page.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final _searchController = TextEditingController();
  List<dynamic> _filteredPatients = MockData.patients;

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = MockData.patients;
      } else {
        _filteredPatients = MockData.patients.where((p) {
          final name = p.fullName.toLowerCase();
          final hn = p.hn.toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || hn.contains(q);
        }).toList();
      }
    });
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
                  Expanded(child: _buildPatientList()),
                ],
              );
            }

            return Column(
              children: [
                _buildSearchPanel(),
                Expanded(child: _buildPatientList()),
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
              builder: (_) => const PatientRegistrationPage(),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.people, size: 32, color: AppTheme.primaryThemeApp),
              const SizedBox(width: 12),
              Text(
                'รายการคนไข้',
                style: AppTheme.generalText(
                  22,
                  fonWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อ-สกุล เลข HN',
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
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        return PatientCard(patient: _filteredPatients[index]);
      },
    );
  }
}
