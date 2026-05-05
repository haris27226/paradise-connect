class DateFilterResult {
  final String? label;
  final String? startDate;
  final String? endDate;
  final bool isClear;

  DateFilterResult({
    this.label,
    this.startDate,
    this.endDate,
    this.isClear = false,
  });
}