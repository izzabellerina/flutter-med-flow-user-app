import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/theme.dart';
import '../data/mock_data.dart';
import '../models/patient_registration.dart';
import '../models/treatment_order.dart';
import 'search_selector_field.dart';

class TreatmentOrderTab extends StatefulWidget {
  final String? patientHn;

  const TreatmentOrderTab({super.key, this.patientHn});

  @override
  State<TreatmentOrderTab> createState() => _TreatmentOrderTabState();
}

class _TreatmentOrderTabState extends State<TreatmentOrderTab> {
  SelectorItem? _selectedMedicine;
  SelectorItem? _selectedProcedure;
  SelectorItem? _selectedUsage;
  final _quantityController = TextEditingController(text: '1');

  // ข้อมูลยาที่เลือก
  String _selectedUnit = '';
  double _selectedPricePerUnit = 0;

  // null = ไม่แสดงฟอร์ม, medicine/procedure = แสดงฟอร์มตามประเภท
  TreatmentType? _activeFormType;

  /// ข้อมูลแพ้ยาของคนไข้
  List<DrugAllergy> get _drugAllergies {
    if (widget.patientHn == null) return [];
    final reg = MockData.patientRegistrations[widget.patientHn];
    return reg?.drugAllergies ?? [];
  }

  /// IDs ของยาที่คนไข้แพ้ (match ชื่อยาจาก mock data)
  Set<String> get _allergicMedicineIds {
    final allergies = _drugAllergies;
    if (allergies.isEmpty) return {};
    final ids = <String>{};
    for (final allergy in allergies) {
      final allergyName = allergy.drugName.toLowerCase();
      for (final med in MockData.medicines) {
        if ((med['name'] as String).toLowerCase().contains(allergyName)) {
          ids.add(med['id'] as String);
        }
      }
    }
    return ids;
  }

  final List<TreatmentOrder> _orders = [
    TreatmentOrder(
      id: '1',
      type: TreatmentType.procedure,
      name: 'Xen Implantation/OS',
      quantity: 1,
      unit: 'ครั้ง',
      pricePerUnit: 25000,
      isActive: true,
      recorderName: 'พญ. ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TreatmentOrder(
      id: '2',
      type: TreatmentType.medicine,
      name: 'Dexamethasone 0.025% in BSS Eye Drops 16 mL',
      usage: 'ตามคำสั่งแพทย์',
      quantity: 2,
      unit: 'ขวด',
      pricePerUnit: 350,
      isActive: true,
      recorderName: 'พญ. ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TreatmentOrder(
      id: '3',
      type: TreatmentType.medicine,
      name: 'Paracetamol 500 mg',
      usage: 'รับประทานครั้งละ 1-2 เม็ด ทุก 4-6 ชั่วโมง เมื่อมีอาการปวด',
      quantity: 30,
      unit: 'เม็ด',
      pricePerUnit: 2,
      isActive: false,
      recorderName: 'พญ. ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    TreatmentOrder(
      id: '4',
      type: TreatmentType.medicine,
      name: 'Ibuprofen 400 mg',
      usage: 'รับประทานครั้งละ 1 เม็ด วันละ 3 ครั้ง หลังอาหาร',
      quantity: 21,
      unit: 'เม็ด',
      pricePerUnit: 5,
      isActive: true,
      recorderName: 'พญ. ธนวัฒน์ แก้วพรหม',
      recordedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  List<TreatmentOrder> get _currentOrders =>
      _orders.where((o) => o.isToday).toList();

  List<TreatmentOrder> get _historyOrders =>
      _orders.where((o) => !o.isToday).toList();

  /// Group history orders by date string
  Map<String, List<TreatmentOrder>> get _groupedHistory {
    final history = _historyOrders;
    final map = <String, List<TreatmentOrder>>{};
    for (final order in history) {
      final key = _formatDateKey(order.recordedAt);
      map.putIfAbsent(key, () => []).add(order);
    }
    return map;
  }

  String _formatDateKey(DateTime dt) {
    return '${dt.day} ${_thaiMonth(dt.month)} ${dt.year + 543}';
  }

  SelectorItem? get _activeSelectedItem =>
      _activeFormType == TreatmentType.medicine
          ? _selectedMedicine
          : _selectedProcedure;

  void _addOrder() {
    final selected = _activeSelectedItem;
    if (selected == null) return;

    final qty = int.tryParse(_quantityController.text) ?? 1;

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
          quantity: qty,
          unit: _selectedUnit,
          pricePerUnit: _selectedPricePerUnit,
          recorderName: 'พญ. ธนวัฒน์ แก้วพรหม',
          recordedAt: DateTime.now(),
        ),
      );
      _selectedMedicine = null;
      _selectedProcedure = null;
      _selectedUsage = null;
      _quantityController.text = '1';
      _selectedUnit = '';
      _selectedPricePerUnit = 0;
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
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentOrders;
    final groupedHistory = _groupedHistory;

    final allergies = _drugAllergies;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แพ้ยา warning card
          if (allergies.isNotEmpty) ...[
            _buildAllergyWarningCard(allergies),
            const SizedBox(height: 16),
          ],

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
          else ...[
            ...current.map((o) => _buildOrderCard(o)),
            const SizedBox(height: 8),
            _buildSummary(current),
          ],

          const SizedBox(height: 24),

          // ย้อนหลัง (History) — grouped by date
          Text(
            'ย้อนหลัง',
            style: AppTheme.generalText(
              18,
              fonWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          if (groupedHistory.isEmpty)
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
          else ...[
            ...groupedHistory.entries.map((entry) => _buildDateGroup(
                  entry.key,
                  entry.value,
                )),
            const SizedBox(height: 8),
            _buildSummary(_historyOrders),
          ],
        ],
      ),
    );
  }

  Widget _buildAllergyWarningCard(List<DrugAllergy> allergies) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: AppTheme.errorColor),
              const SizedBox(width: 8),
              Text(
                'ประวัติแพ้ยา',
                style: AppTheme.generalText(
                  15,
                  fonWeight: FontWeight.bold,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...allergies.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTheme.generalText(13, color: AppTheme.primaryText),
                          children: [
                            TextSpan(
                              text: a.drugName,
                              style: AppTheme.generalText(13,
                                  fonWeight: FontWeight.w600,
                                  color: AppTheme.primaryText),
                            ),
                            if (a.reaction != null && a.reaction!.isNotEmpty)
                              TextSpan(text: ' — ${a.reaction}'),
                            if (a.severity != null) ...[
                              const TextSpan(text: ' ('),
                              TextSpan(
                                text: a.severity == 'severe'
                                    ? 'รุนแรง'
                                    : a.severity == 'moderate'
                                        ? 'ปานกลาง'
                                        : 'เล็กน้อย',
                                style: AppTheme.generalText(13,
                                    fonWeight: FontWeight.w600,
                                    color: a.severity == 'severe'
                                        ? AppTheme.errorColor
                                        : const Color(0xFFD97706)),
                              ),
                              const TextSpan(text: ')'),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
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
            _quantityController.text = '1';
            _selectedUnit = '';
            _selectedPricePerUnit = 0;
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
                        id: m['id'] as String, title: m['name'] as String))
                    .toList()
                : MockData.procedures
                    .map((p) => SelectorItem(
                        id: p['id'] as String, title: p['name'] as String))
                    .toList(),
            disabledIds: isMedicine ? _allergicMedicineIds : const {},
            disabledBadgeText: 'แพ้ยานี้',
            onSelected: (item) {
              setState(() {
                if (isMedicine) {
                  _selectedMedicine = item;
                  // autofill usage + unit + price from medicine data
                  final med = MockData.medicines
                      .where((m) => m['id'] == item.id)
                      .firstOrNull;
                  if (med != null) {
                    _selectedUnit = med['unit'] as String;
                    _selectedPricePerUnit = (med['pricePerUnit'] as num).toDouble();
                    final usageText = med['usage'] as String?;
                    if (usageText != null) {
                      final match = MockData.medicineUsages
                          .where((u) => u['name'] == usageText)
                          .firstOrNull;
                      if (match != null) {
                        _selectedUsage = SelectorItem(
                            id: match['id']!, title: match['name']!);
                      }
                    }
                  }
                } else {
                  _selectedProcedure = item;
                  // procedure: locked qty=1, unit=ครั้ง
                  final proc = MockData.procedures
                      .where((p) => p['id'] == item.id)
                      .firstOrNull;
                  if (proc != null) {
                    _selectedUnit = 'ครั้ง';
                    _selectedPricePerUnit = (proc['pricePerUnit'] as num).toDouble();
                  }
                  _quantityController.text = '1';
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

          const SizedBox(height: 12),

          // จำนวน + หน่วย + ราคา
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // จำนวน
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'จำนวน',
                      style: AppTheme.generalText(
                        14,
                        fonWeight: FontWeight.w600,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      readOnly: !isMedicine, // procedure locked to 1
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // หน่วย
              if (_selectedUnit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    _selectedUnit,
                    style: AppTheme.generalText(
                      14,
                      color: AppTheme.secondaryText62,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              // ราคาต่อหน่วย
              if (_selectedPricePerUnit > 0)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ราคา/หน่วย: ${_formatPrice(_selectedPricePerUnit)} ฿',
                          style: AppTheme.generalText(
                            13,
                            color: AppTheme.secondaryText62,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'รวม: ${_formatPrice(_selectedPricePerUnit * (int.tryParse(_quantityController.text) ?? 1))} ฿',
                          style: AppTheme.generalText(
                            14,
                            fonWeight: FontWeight.w600,
                            color: AppTheme.primaryThemeApp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

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

  /// สรุปรายการปัจจุบัน
  Widget _buildSummary(List<TreatmentOrder> orders) {
    final totalPrice = orders.fold<double>(0, (sum, o) => sum + o.totalPrice);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryThemeApp.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryThemeApp.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'รวม ${orders.length} รายการ',
            style: AppTheme.generalText(
              14,
              fonWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
          Text(
            'ราคารวม: ${_formatPrice(totalPrice)} ฿',
            style: AppTheme.generalText(
              15,
              fonWeight: FontWeight.bold,
              color: AppTheme.primaryThemeApp,
            ),
          ),
        ],
      ),
    );
  }

  /// Date group header + cards for history
  Widget _buildDateGroup(String dateLabel, List<TreatmentOrder> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppTheme.secondaryText62),
              const SizedBox(width: 6),
              Text(
                dateLabel,
                style: AppTheme.generalText(
                  13,
                  fonWeight: FontWeight.w600,
                  color: AppTheme.secondaryText62,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...orders.map((o) => _buildOrderCard(o)),
        _buildSummary(orders),
        const SizedBox(height: 16),
      ],
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

          // จำนวน + ราคา
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'จำนวน: ${order.quantity} ${order.unit}',
                style: AppTheme.generalText(
                  13,
                  fonWeight: FontWeight.w500,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'ราคา/หน่วย: ${_formatPrice(order.pricePerUnit)} ฿',
                style: AppTheme.generalText(
                  13,
                  color: AppTheme.secondaryText62,
                ),
              ),
              const Spacer(),
              Text(
                'รวม ${_formatPrice(order.totalPrice)} ฿',
                style: AppTheme.generalText(
                  14,
                  fonWeight: FontWeight.w600,
                  color: AppTheme.primaryThemeApp,
                ),
              ),
            ],
          ),

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

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return price.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
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
