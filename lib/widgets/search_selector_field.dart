import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Item ที่ใช้ในตัวเลือก
class SelectorItem {
  final String id;
  final String title;
  final String? subtitle;

  SelectorItem({required this.id, required this.title, this.subtitle});
}

/// ช่องเลือกแบบ search — กดแล้วเปิด bottom sheet ค้นหา
class SearchSelectorField extends StatelessWidget {
  final String label;
  final String? hint;
  final SelectorItem? selectedItem;
  final List<SelectorItem> items;
  final ValueChanged<SelectorItem> onSelected;
  final double? width;

  const SearchSelectorField({
    super.key,
    required this.label,
    this.hint,
    this.selectedItem,
    required this.items,
    required this.onSelected,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.generalText(15,
              fonWeight: FontWeight.w600, color: AppTheme.primaryText),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _openSelector(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.lineColorD9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItem != null
                        ? (selectedItem!.subtitle != null
                            ? '${selectedItem!.title} — ${selectedItem!.subtitle}'
                            : selectedItem!.title)
                        : hint ?? 'เลือก...',
                    style: AppTheme.generalText(
                      14,
                      color: selectedItem != null
                          ? AppTheme.primaryText
                          : AppTheme.secondaryText62,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.search, size: 20, color: AppTheme.secondaryText62),
              ],
            ),
          ),
        ),
      ],
    );

    if (width != null) return SizedBox(width: width, child: field);
    return field;
  }

  void _openSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSelectorSheet(
        title: label,
        items: items,
        selectedId: selectedItem?.id,
        onSelected: (item) {
          onSelected(item);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SearchSelectorSheet extends StatefulWidget {
  final String title;
  final List<SelectorItem> items;
  final String? selectedId;
  final ValueChanged<SelectorItem> onSelected;

  const _SearchSelectorSheet({
    required this.title,
    required this.items,
    this.selectedId,
    required this.onSelected,
  });

  @override
  State<_SearchSelectorSheet> createState() => _SearchSelectorSheetState();
}

class _SearchSelectorSheetState extends State<_SearchSelectorSheet> {
  final _searchController = TextEditingController();
  List<SelectorItem> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.items;
      } else {
        _filtered = widget.items.where((item) {
          return item.title.toLowerCase().contains(q) ||
              (item.subtitle?.toLowerCase().contains(q) ?? false) ||
              item.id.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

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

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: AppTheme.generalText(18,
                      fonWeight: FontWeight.bold, color: AppTheme.primaryText),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryText62,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text('ปิด',
                      style: AppTheme.generalText(15,
                          color: AppTheme.secondaryText62)),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'ค้นหา...',
                hintStyle: AppTheme.generalText(14,
                    color: AppTheme.secondaryText62),
                prefixIcon:
                    Icon(Icons.search, color: AppTheme.secondaryText62),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.lineColorD9),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.lineColorD9),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryThemeApp),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Result count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filtered.length} รายการ',
                style:
                    AppTheme.generalText(13, color: AppTheme.secondaryText62),
              ),
            ),
          ),

          Divider(height: 1, color: AppTheme.lineColorD9),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'ไม่พบรายการ',
                      style: AppTheme.generalText(15,
                          color: AppTheme.secondaryText62),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: AppTheme.lineColorD9),
                    itemBuilder: (context, index) {
                      final item = _filtered[index];
                      final isSelected = item.id == widget.selectedId;

                      return ListTile(
                        onTap: () => widget.onSelected(item),
                        selected: isSelected,
                        selectedTileColor: AppTheme.dateBadgeColor,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(
                          item.title,
                          style: AppTheme.generalText(14,
                              fonWeight: FontWeight.w500,
                              color: AppTheme.primaryText),
                        ),
                        subtitle: item.subtitle != null
                            ? Text(
                                item.subtitle!,
                                style: AppTheme.generalText(13,
                                    color: AppTheme.secondaryText62),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: AppTheme.primaryThemeApp, size: 22)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
