import 'package:flutter/material.dart';

class OptionDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const OptionDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: value,
      label: Text(label),
      expandedInsets: EdgeInsets.zero,
      requestFocusOnTap: false,
      dropdownMenuEntries: options
          .map((o) => DropdownMenuEntry<String>(value: o, label: o))
          .toList(),
      onSelected: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}