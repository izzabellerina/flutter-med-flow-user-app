import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import '../models/treatment_order.dart';
import 'search_selector_field.dart';

class TreatmentOrderTab extends StatefulWidget {
  const TreatmentOrderTab({super.key});

  @override
  State<TreatmentOrderTab> createState() => _TreatmentOrderTabState();
}

class _TreatmentOrderTabState extends State<TreatmentOrderTab> {
  SelectorItem? _selectedMedicine;
  SelectorItem? _selectedProcedure;
  SelectorItem? _selectedUsage;

  // null = ไม่แสดงฟอร์ม, medicine/procedure = แสดงฟอร์มตามประเภท
  TreatmentType? _activeFormType;

  final List<TreatmentOrder> _orders = [
    TreatmentOrder(
      id: '1',
      type: TreatmentType.procedure,
      name: 'Xen Implantation/OS',
      isActive: true,
      recorderName: 'พญ. ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TreatmentOrder(
      id: '2',
      type: TreatmentType.medicine,
      name: 'Dexamethasone 0.025% in BSS Eye Drops 16 mL',
      usage: 'ตามคำสั่งแพทย์',
      isActive: true,
      recorderName: 'พญ. ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TreatmentOrder(
      id: '3',
      type: TreatmentType.medicine,
      name: 'Paracetamol 500 mg',
      usage: 'รับประทานครั้งละ 1-2 เม็ด ทุก 4-6 ชั่วโมง เมื่อมีอาการปวด',
      isActive: false,
      recorderName: 'พญ. ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  List<TreatmentOrder> get _currentOrders =>
      _orders.where((o) => o.isToday).toList();

  List<TreatmentOrder> get _historyOrders =>
      _orders.where((o) => !o.isToday).toList();

  SelectorItem? get _activeSelectedItem =>
      _activeFormType == TreatmentType.medicine
          ? _selectedMedicine
          : _selectedProcedure;

  void _addOrder() {
    final selected = _activeSelectedItem;
    if (selected == null) return;

    setState(() {
      _orders.insert(
        0,
        TreatmentOrder(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: _activeFormType!,
          name: selected.title,
          usage: _activeFormType == TreatmentType.medicine
              ? _selectedUsage?.title
              : null,
          recorderName: 'พญ. ธนวัฒน์ แก้วพรหม',
          recordedAt: DateTime.now(),
        ),
      );
      _selectedMedicine = null;
      _selectedProcedure = null;
      _selectedUsage = null;
      _activeFormType = null;
    });
  }

  void _toggleActive(TreatmentOrder order) {
    setState(() {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(isActive: !order.isActive);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentOrders;
    final history = _historyOrders;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ปุ่ม +สั่งยา / +หัตถการ
          Row(
            children: [
              _buildAddButton(
                label: '+สั่งยา',
                type: TreatmentType.medicine,
              ),
              const SizedBox(width: 12),
              _buildAddButton(
                label: '+หัตถการ',
                type: TreatmentType.procedure,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Inline Form
          if (_activeFormType != null) ...[
            _buildInlineForm(),
            const SizedBox(height: 24),
            Divider(color: AppTheme.lineColorD9),
            const SizedBox(height: 16),
          ],

          // ปัจจุบัน (Today)
          Text(
            'รายการปัจจุบัน',
            style: AppTheme.generalText(
              18,
              fonWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          if (current.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'ยังไม่มีรายการสั่งการรักษาวันนี้',
                style: AppTheme.generalText(
                  14,
                  color: AppTheme.secondaryText62,
                ),
              ),
            )
          else
            ...current.map((o) => _buildOrderCard(o)),

          const SizedBox(height: 24),

          // ย้อนหลัง (History)
          Text(
            'ย้อนหลัง',
            style: AppTheme.generalText(
              18,
              fonWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'ยังไม่มีข้อมูลย้อนหลัง',
                style: AppTheme.generalText(
                  14,
                  color: AppTheme.secondaryText62,
                ),
              ),
            )
          else
            ...history.map((o) => _buildOrderCard(o)),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required TreatmentType type,
  }) {
    final isActive = _activeFormType == type;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          if (isActive) {
            _activeFormType = null;
          } else {
            _activeFormType = type;
            _selectedMedicine = null;
            _selectedProcedure = null;
            _selectedUsage = null;
          }
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive ? Colors.white : AppTheme.primaryText,
        backgroundColor:
            isActive ? AppTheme.primaryThemeApp : Colors.white,
        side: BorderSide(
          color: isActive ? AppTheme.primaryThemeApp : AppTheme.lineColorD9,
        ),
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: AppTheme.generalText(
          15,
          fonWeight: FontWeight.w600,
          color: isActive ? Colors.white : AppTheme.primaryText,
        ),
      ),
    );
  }

  Widget _buildInlineForm() {
    final isMedicine = _activeFormType == TreatmentType.medicine;
    final title = isMedicine ? 'สั่งยา' : 'สั่งหัตถการ';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.generalText(
              16,
              fonWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          SearchSelectorField(
            label: isMedicine ? 'ชื่อยา' : 'ชื่อหัตถการ',
            hint: isMedicine ? 'ค้นหาชื่อยา...' : 'ค้นหาชื่อหัตถการ...',
            selectedItem: _activeSelectedItem,
            items: isMedicine
                ? MockData.medicines
                    .map((m) => SelectorItem(
                        id: m['id']!, title: m['name']!))
                    .toList()
                : MockData.procedures
                    .map((p) => SelectorItem(
                        id: p['id']!, title: p['name']!))
                    .toList(),
            onSelected: (item) {
              setState(() {
                if (isMedicine) {
                  _selectedMedicine = item;
                  // autofill usage from medicine's default usage
                  final med = MockData.medicines
                      .where((m) => m['id'] == item.id)
                      .firstOrNull;
                  if (med != null && med['usage'] != null) {
                    final usageText = med['usage']!;
                    final match = MockData.medicineUsages
                        .where((u) => u['name'] == usageText)
                        .firstOrNull;
                    if (match != null) {
                      _selectedUsage = SelectorItem(
                          id: match['id']!, title: match['name']!);
                    }
                  }
                } else {
                  _selectedProcedure = item;
                }
              });
            },
          ),

          if (isMedicine) ...[
            const SizedBox(height: 12),
            SearchSelectorField(
              label: 'วิธีใช้',
              hint: 'ค้นหาวิธีใช้ยา...',
              selectedItem: _selectedUsage,
              items: MockData.medicineUsages
                  .map((u) =>
                      SelectorItem(id: u['id']!, title: u['name']!))
                  .toList(),
              onSelected: (item) {
                setState(() {
                  _selectedUsage = item;
                });
              },
            ),
          ],

          const SizedBox(height: 16),

          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: ElevatedButton(
              onPressed: _addOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryThemeApp,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'เพิ่ม',
                style: AppTheme.generalText(
                  16,
                  fonWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(TreatmentOrder order) {
    final isMedicine = order.type == TreatmentType.medicine;
    final badgeLabel = isMedicine ? 'สั่งยา' : 'สั่งหัตถการ';
    final badgeColor =
        isMedicine ? const Color(0xFFFEF3C7) : const Color(0xFFFED7AA);
    final badgeTextColor =
        isMedicine ? const Color(0xFFD97706) : const Color(0xFFEA580C);

    final dateStr =
        '${order.recordedAt.day} ${_thaiMonth(order.recordedAt.month)} ${order.recordedAt.year + 543}, '
        '${order.recordedAt.hour.toString().padLeft(2, '0')}:${order.recordedAt.minute.toString().padLeft(2, '0')} น.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMedicine
              ? const Color(0xFFFDE68A)
              : const Color(0xFFFDBA74),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: badge + actions
          Row(
            children: [
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeLabel,
                  style: AppTheme.generalText(
                    12,
                    fonWeight: FontWeight.w600,
                    color: badgeTextColor,
                  ),
                ),
              ),
              const Spacer(),
              // Delete
              InkWell(
                onTap: () {
                  setState(() {
                    _orders.removeWhere((o) => o.id == order.id);
                  });
                },
                child: Icon(Icons.delete_outline,
                    size: 20, color: AppTheme.secondaryText62),
              ),
              const SizedBox(width: 10),
              // Edit
              InkWell(
                onTap: () {},
                child: Icon(Icons.edit_outlined,
                    size: 20, color: AppTheme.secondaryText62),
              ),
              const SizedBox(width: 10),
              // ON/OFF toggle
              GestureDetector(
                onTap: () => _toggleActive(order),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.isActive
                        ? AppTheme.primaryThemeApp
                        : AppTheme.secondaryText62,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.isActive ? 'ON' : 'OFF',
                    style: AppTheme.generalText(
                      12,
                      fonWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            order.name,
            style: AppTheme.generalText(
              15,
              fonWeight: FontWeight.w500,
              color: AppTheme.primaryText,
            ),
          ),

          // Usage (medicine only)
          if (isMedicine && order.usage != null && order.usage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoLine('วิธีใช้ :', order.usage!),
          ],

          const SizedBox(height: 12),

          // Footer: recorder + date
          Text(
            'ผู้บันทึกล่าสุด :',
            style: AppTheme.generalText(
              12,
              color: AppTheme.secondaryText62,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            order.recorderName,
            style: AppTheme.generalText(
              13,
              fonWeight: FontWeight.w500,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 14, color: AppTheme.secondaryText62),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style:
                    AppTheme.generalText(12, color: AppTheme.secondaryText62),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.generalText(
            13,
            fonWeight: FontWeight.w600,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: AppTheme.generalText(13, color: AppTheme.secondaryText62),
          ),
        ),
      ],
    );
  }

  String _thaiMonth(int month) {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    return months[month - 1];
  }
}
