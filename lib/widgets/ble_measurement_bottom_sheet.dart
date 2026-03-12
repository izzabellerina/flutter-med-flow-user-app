import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../app/theme.dart';
import '../models/ble_device_info.dart';
import '../models/ble_measurement_result.dart';
import '../services/ble_service.dart';
import '../services/ble_permission_handler.dart';

/// ผลลัพธ์ที่ส่งกลับไปยัง MeasurementTab
class BleMeasurementData {
  final double? sBp;
  final double? dBp;
  final double? pr;
  final double? bw;
  final double? o2;
  final double? temp;

  BleMeasurementData({this.sBp, this.dBp, this.pr, this.bw, this.o2, this.temp});
}

class BleMeasurementBottomSheet extends StatefulWidget {
  const BleMeasurementBottomSheet({super.key});

  static Future<BleMeasurementData?> show(BuildContext context) {
    return showModalBottomSheet<BleMeasurementData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BleMeasurementBottomSheet(),
    );
  }

  @override
  State<BleMeasurementBottomSheet> createState() =>
      _BleMeasurementBottomSheetState();
}

class _BleMeasurementBottomSheetState extends State<BleMeasurementBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _bleService = BleService();

  // สถานะแต่ละแท็ป
  final List<_TabState> _tabStates = List.generate(4, (_) => _TabState());

  // ผลลัพธ์สะสม
  BleMeasurementResult? _bpResult;
  BleMeasurementResult? _weightResult;
  BleMeasurementResult? _o2Result;
  BleMeasurementResult? _tempResult;

  final _tabLabels = const ['ความดัน', 'น้ำหนัก', 'O2', 'อุณหภูมิ'];
  final _tabDeviceTypes = const [
    BleDeviceType.bloodPressure,
    BleDeviceType.weightScale,
    BleDeviceType.pulseOximeter,
    BleDeviceType.thermometer,
  ];

  StreamSubscription<List<BleDeviceInfo>>? _scanSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _bleService.dispose();
    _tabController.dispose();
    super.dispose();
  }

  BleDeviceType get _currentDeviceType =>
      _tabDeviceTypes[_tabController.index];

  _TabState get _currentTabState => _tabStates[_tabController.index];

  // ════════════════════════════════════════════════════════════════════
  // Actions
  // ════════════════════════════════════════════════════════════════════

  Future<void> _onConnectDevice() async {
    final tabState = _currentTabState;

    // ถ้ากำลัง scanning อยู่ ให้หยุด
    if (tabState.status == _BleTabStatus.scanning) {
      await _bleService.stopScan();
      setState(() => tabState.status = _BleTabStatus.idle);
      return;
    }

    // ถ้าเลือกอุปกรณ์แล้ว ให้เชื่อมต่อ
    if (tabState.status == _BleTabStatus.deviceSelected) {
      await _connectAndRead(tabState);
      return;
    }

    // เริ่มสแกน
    final permitted = await BlePermissionHandler.requestPermissions();
    if (!permitted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กรุณาอนุญาตการใช้งาน Bluetooth',
                style: AppTheme.generalText(14, color: Colors.white)),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // ตรวจ Bluetooth adapter
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('กรุณาเปิด Bluetooth',
                style: AppTheme.generalText(14, color: Colors.white)),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      tabState.status = _BleTabStatus.scanning;
      tabState.devices = [];
      tabState.error = null;
    });

    _scanSub?.cancel();
    _scanSub = _bleService.scanResults.listen((devices) {
      if (mounted) {
        setState(() => tabState.devices = devices);
      }
    });

    try {
      await _bleService.startScan();
      // Scan finished (timeout)
      if (mounted && tabState.status == _BleTabStatus.scanning) {
        setState(() {
          tabState.status = tabState.devices.isEmpty
              ? _BleTabStatus.idle
              : _BleTabStatus.idle;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          tabState.status = _BleTabStatus.idle;
          tabState.error = 'สแกนไม่สำเร็จ: $e';
        });
      }
    }
  }

  Future<void> _connectAndRead(_TabState tabState) async {
    if (tabState.selectedDevice == null) return;

    setState(() {
      tabState.status = _BleTabStatus.connecting;
      tabState.error = null;
    });

    try {
      // เชื่อมต่อเฉพาะเมื่อยังไม่ได้เชื่อมต่ออุปกรณ์ตัวนี้
      if (_bleService.connectedDevice?.remoteId !=
          tabState.selectedDevice!.device.remoteId) {
        await _bleService.disconnect();
        // รอสักครู่หลัง disconnect เพื่อป้องกัน GATT error 133
        await Future.delayed(const Duration(milliseconds: 600));
        await _bleService.connect(tabState.selectedDevice!.device);
      }

      setState(() {
        tabState.status = _BleTabStatus.reading;
        tabState.cuffPressure = null;
      });

      final result = await _bleService.readMeasurement(
        _currentDeviceType,
        onIntermediateBp: _currentDeviceType == BleDeviceType.bloodPressure
            ? (pressure) {
                if (mounted) {
                  setState(() => tabState.cuffPressure = pressure);
                }
              }
            : null,
        onIntermediateWeight: _currentDeviceType == BleDeviceType.weightScale
            ? (weight) {
                if (mounted) {
                  setState(() => tabState.intermediateWeight = weight);
                }
              }
            : null,
      );

      setState(() {
        tabState.status = _BleTabStatus.done;
        tabState.result = result;
        _storeResult(result);
      });
    } on BleServiceNotFoundException catch (e) {
      // อุปกรณ์ไม่รองรับ — ไม่ disconnect เพื่อให้ลองแท็ปอื่นได้
      if (mounted) {
        setState(() {
          tabState.status = _BleTabStatus.idle;
          tabState.error = e.toString();
        });
      }
    } on BleDeviceDisconnectedException {
      // เครื่องตัดการเชื่อมต่อเอง (พบบ่อยในเครื่องวัดความดัน)
      if (mounted) {
        setState(() {
          tabState.status = _BleTabStatus.idle;
          tabState.error =
              'เครื่องตัดการเชื่อมต่อ — กรุณากดวัดค่าที่เครื่องก่อน แล้วกด "เชื่อมต่อเครื่อง" อีกครั้ง';
        });
      }
      _bleService.disconnect();
    } catch (e) {
      if (mounted) {
        setState(() {
          tabState.status = _BleTabStatus.idle;
          tabState.error = 'เชื่อมต่อไม่สำเร็จ: $e';
        });
      }
      await _bleService.disconnect();
    }
  }

  void _storeResult(BleMeasurementResult result) {
    switch (result.deviceType) {
      case BleDeviceType.bloodPressure:
        _bpResult = result;
      case BleDeviceType.weightScale:
        _weightResult = result;
      case BleDeviceType.pulseOximeter:
        _o2Result = result;
      case BleDeviceType.thermometer:
        _tempResult = result;
    }
  }

  void _onSelectDevice(BleDeviceInfo device) {
    setState(() {
      _currentTabState.selectedDevice = device;
      _currentTabState.status = _BleTabStatus.deviceSelected;
    });
  }

  bool get _hasAnyResult =>
      _bpResult != null ||
      _weightResult != null ||
      _o2Result != null ||
      _tempResult != null;

  void _returnResults() {
    Navigator.pop(
      context,
      BleMeasurementData(
        sBp: _bpResult?.systolic,
        dBp: _bpResult?.diastolic,
        pr: _bpResult?.pulseRate ?? _o2Result?.pulseRate,
        bw: _weightResult?.weight,
        o2: _o2Result?.spO2,
        temp: _tempResult?.temperature,
      ),
    );
  }

  void _onNext() {
    final nextIndex = (_tabController.index + 1) % _tabController.length;
    _tabController.animateTo(nextIndex);
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  // ════════════════════════════════════════════════════════════════════
  // Build
  // ════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lineColorD9,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // TabBar
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryThemeApp,
            unselectedLabelColor: AppTheme.secondaryText62,
            labelStyle: AppTheme.generalText(15, fonWeight: FontWeight.w600),
            unselectedLabelStyle: AppTheme.generalText(14),
            indicatorColor: AppTheme.primaryThemeApp,
            indicatorWeight: 3,
            tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
          ),
          Divider(height: 1, color: AppTheme.lineColorD9),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(4, (i) => _buildTabContent(i)),
            ),
          ),

          // Bottom buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    final tabState = _tabStates[index];
    final deviceType = _tabDeviceTypes[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดงค่าที่วัดได้ (ถ้ามี)
          if (tabState.result != null) ...[
            _buildResultDisplay(tabState.result!, deviceType),
            const SizedBox(height: 16),
          ],

          // สถานะ
          if (tabState.status == _BleTabStatus.scanning)
            _buildScanningIndicator(),

          if (tabState.status == _BleTabStatus.connecting)
            _buildStatusCard('กำลังเชื่อมต่อ...', Icons.bluetooth_connected),

          if (tabState.status == _BleTabStatus.reading)
            deviceType == BleDeviceType.bloodPressure
                ? _buildBpReadingCard(tabState.cuffPressure)
                : deviceType == BleDeviceType.weightScale
                    ? _buildWeightReadingCard(tabState.intermediateWeight)
                    : _buildStatusCard(
                        'กำลังรออ่านค่าจากเครื่อง...', Icons.monitor_heart),

          // Error
          if (tabState.error != null) ...[
            _buildErrorCard(tabState.error!),
            const SizedBox(height: 12),
          ],

          // รายการอุปกรณ์ที่เจอ
          if (tabState.devices.isNotEmpty &&
              tabState.status != _BleTabStatus.connecting &&
              tabState.status != _BleTabStatus.reading) ...[
            Text(
              'อุปกรณ์ที่พบ',
              style: AppTheme.generalText(16,
                  fonWeight: FontWeight.bold, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 8),
            ...tabState.devices.map((d) => _buildDeviceCard(d, tabState)),
          ],

          // Empty state
          if (tabState.status == _BleTabStatus.idle &&
              tabState.devices.isEmpty &&
              tabState.result == null &&
              tabState.error == null)
            _buildEmptyState(deviceType),
        ],
      ),
    );
  }

  Widget _buildResultDisplay(
      BleMeasurementResult result, BleDeviceType type) {
    String valueText;
    String unitText;

    switch (type) {
      case BleDeviceType.bloodPressure:
        valueText =
            '${result.systolic?.round() ?? '-'}/${result.diastolic?.round() ?? '-'}';
        unitText = 'mmHg';
      case BleDeviceType.weightScale:
        valueText = result.weight?.toStringAsFixed(1) ?? '-';
        unitText = 'kg';
      case BleDeviceType.pulseOximeter:
        valueText = '${result.spO2?.round() ?? '-'}';
        unitText = '%';
      case BleDeviceType.thermometer:
        valueText = result.temperature?.toStringAsFixed(1) ?? '-';
        unitText = '°C';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.dateBadgeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryThemeApp.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            valueText,
            style: AppTheme.generalText(48,
                fonWeight: FontWeight.bold, color: AppTheme.primaryText),
          ),
          Text(
            unitText,
            style: AppTheme.generalText(18, color: AppTheme.secondaryText62),
          ),
          if (type == BleDeviceType.bloodPressure &&
              result.pulseRate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Pulse: ${result.pulseRate!.round()} bpm',
              style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
            ),
          ],
          if (type == BleDeviceType.pulseOximeter &&
              result.pulseRate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Pulse: ${result.pulseRate!.round()} bpm',
              style: AppTheme.generalText(16, color: AppTheme.secondaryText62),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryThemeApp,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'กำลังสแกนอุปกรณ์...',
            style: AppTheme.generalText(15, color: AppTheme.secondaryText62),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightReadingCard(double? weight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.dateBadgeColor,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.primaryThemeApp.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryThemeApp,
            ),
          ),
          const SizedBox(height: 16),
          if (weight != null) ...[
            Text(
              weight.toStringAsFixed(1),
              style: AppTheme.generalText(48,
                  fonWeight: FontWeight.bold, color: AppTheme.primaryText),
            ),
            Text(
              'kg',
              style: AppTheme.generalText(18, color: AppTheme.secondaryText62),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            weight != null
                ? 'กำลังรอค่านิ่ง...'
                : 'กรุณาขึ้นชั่งน้ำหนัก...',
            style: AppTheme.generalText(15, color: AppTheme.secondaryText62),
          ),
        ],
      ),
    );
  }

  Widget _buildBpReadingCard(double? cuffPressure) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.dateBadgeColor,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.primaryThemeApp.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryThemeApp,
            ),
          ),
          const SizedBox(height: 16),
          if (cuffPressure != null) ...[
            Text(
              '${cuffPressure.round()}',
              style: AppTheme.generalText(48,
                  fonWeight: FontWeight.bold, color: AppTheme.primaryText),
            ),
            Text(
              'mmHg',
              style: AppTheme.generalText(18, color: AppTheme.secondaryText62),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            cuffPressure != null
                ? 'กำลังวัดความดัน...'
                : 'กรุณากดวัดค่าที่เครื่อง...',
            style: AppTheme.generalText(15, color: AppTheme.secondaryText62),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lineColorD9),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryThemeApp,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryThemeApp),
              const SizedBox(width: 8),
              Text(
                message,
                style:
                    AppTheme.generalText(15, color: AppTheme.secondaryText62),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20, color: AppTheme.errorColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: AppTheme.generalText(13, color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BleDeviceInfo device, _TabState tabState) {
    final isSelected = tabState.selectedDevice?.device.remoteId ==
        device.device.remoteId;

    return GestureDetector(
      onTap: () => _onSelectDevice(device),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryThemeApp.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryThemeApp
                : AppTheme.lineColorD9,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bluetooth,
              size: 24,
              color: isSelected
                  ? AppTheme.primaryThemeApp
                  : AppTheme.secondaryText62,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: AppTheme.generalText(
                      15,
                      fonWeight: FontWeight.w600,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  Text(
                    device.device.remoteId.str,
                    style: AppTheme.generalText(12,
                        color: AppTheme.secondaryText62),
                  ),
                ],
              ),
            ),
            // Signal strength
            _buildSignalIcon(device.rssi),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalIcon(int rssi) {
    final strength = rssi > -60
        ? 3
        : rssi > -80
            ? 2
            : 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          strength >= 3
              ? Icons.signal_wifi_4_bar
              : strength >= 2
                  ? Icons.network_wifi_2_bar
                  : Icons.network_wifi_1_bar,
          size: 16,
          color: AppTheme.secondaryText62,
        ),
        const SizedBox(width: 4),
        Text(
          '${rssi}dBm',
          style: AppTheme.generalText(11, color: AppTheme.secondaryText62),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BleDeviceType type) {
    String label;
    switch (type) {
      case BleDeviceType.bloodPressure:
        label = 'เครื่องวัดความดัน';
      case BleDeviceType.weightScale:
        label = 'เครื่องชั่งน้ำหนัก';
      case BleDeviceType.pulseOximeter:
        label = 'เครื่องวัด O2';
      case BleDeviceType.thermometer:
        label = 'เครื่องวัดอุณหภูมิ';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.bluetooth_searching,
              size: 48, color: AppTheme.secondaryText62),
          const SizedBox(height: 16),
          Text(
            'กด "เชื่อมต่อเครื่อง" เพื่อค้นหา$label',
            textAlign: TextAlign.center,
            style: AppTheme.generalText(15, color: AppTheme.secondaryText62),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    final tabState = _currentTabState;

    String connectLabel;
    switch (tabState.status) {
      case _BleTabStatus.scanning:
        connectLabel = 'หยุดสแกน';
      case _BleTabStatus.deviceSelected:
        connectLabel = 'เชื่อมต่อ';
      case _BleTabStatus.connecting:
      case _BleTabStatus.reading:
        connectLabel = 'กำลังทำงาน...';
      default:
        connectLabel = 'เชื่อมต่อเครื่อง';
    }

    final isConnectDisabled = tabState.status == _BleTabStatus.connecting ||
        tabState.status == _BleTabStatus.reading;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.lineColorD9)),
      ),
      child: Row(
        children: [
          // ยกเลิก / บันทึกและปิด
          Expanded(
            child: _hasAnyResult
                ? ElevatedButton(
                    onPressed: _returnResults,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: AppTheme.primaryThemeApp,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'บันทึกและปิด',
                      style: AppTheme.generalText(15,
                          fonWeight: FontWeight.w600, color: Colors.white),
                    ),
                  )
                : OutlinedButton(
                    onPressed: _onCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      foregroundColor: AppTheme.primaryText,
                      side: BorderSide(color: AppTheme.lineColorD9),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'ยกเลิก',
                      style: AppTheme.generalText(15,
                          fonWeight: FontWeight.w600,
                          color: AppTheme.primaryText),
                    ),
                  ),
          ),
          const SizedBox(width: 10),

          // เชื่อมต่อเครื่อง
          Expanded(
            child: OutlinedButton(
              onPressed: isConnectDisabled ? null : _onConnectDevice,
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                foregroundColor: AppTheme.primaryThemeApp,
                side: BorderSide(color: AppTheme.primaryThemeApp),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                connectLabel,
                style: AppTheme.generalText(15,
                    fonWeight: FontWeight.w600,
                    color: AppTheme.primaryThemeApp),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ถัดไป
          Expanded(
            child: OutlinedButton(
              onPressed: _onNext,
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                foregroundColor: AppTheme.primaryText,
                side: BorderSide(color: AppTheme.lineColorD9),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'ถัดไป',
                style: AppTheme.generalText(15,
                    fonWeight: FontWeight.w600, color: AppTheme.primaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Per-tab state
// ════════════════════════════════════════════════════════════════════════════

enum _BleTabStatus { idle, scanning, deviceSelected, connecting, reading, done }

class _TabState {
  _BleTabStatus status = _BleTabStatus.idle;
  List<BleDeviceInfo> devices = [];
  BleDeviceInfo? selectedDevice;
  BleMeasurementResult? result;
  String? error;
  double? cuffPressure; // ค่าความดัน cuff realtime (เฉพาะแท็ปความดัน)
  double? intermediateWeight; // ค่าน้ำหนัก realtime (เฉพาะแท็ปน้ำหนัก)
}
