import 'package:flutter/material.dart';
import 'package:money_tracker/data/models/category_model.dart';

class CategoryPicker extends StatelessWidget {
  final List<CategoryModel> categories;
  final CategoryModel? selected;
  final Color accentColor;
  final ValueChanged<CategoryModel> onSelect;
  final VoidCallback onAddCategory;

  const CategoryPicker({
    super.key,
    required this.categories,
    required this.selected,
    required this.accentColor,
    required this.onSelect,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...categories.map((cat) {
          final isSelected = selected?.id == cat.id;
          return _CategoryChip(
            label: cat.name,
            isSelected: isSelected,
            accentColor: accentColor,
            onTap: () => onSelect(cat),
          );
        }),
        _CategoryChip(
          label: '+ Kategori baru',
          isSelected: false,
          accentColor: Colors.grey,
          onTap: onAddCategory,
          isDashed: true,
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isDashed;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}