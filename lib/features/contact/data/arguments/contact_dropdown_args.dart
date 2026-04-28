class OwnerDropdownItem {
  final int? id;
  final String name;
  final String? subtitle;

  OwnerDropdownItem({this.id, required this.name, this.subtitle});
}

class ContactDropdownArgs {
  final String title;
  final List<OwnerDropdownItem> items;
  final int? selectedId;
  final List<int>? selectedIds;
  final bool isMultiSelect;

  ContactDropdownArgs({
    required this.title,
    required this.items,
    this.selectedId,
    this.selectedIds,
    this.isMultiSelect = false,
  });
}