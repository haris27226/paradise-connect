String getInitials(String name) {
  List<String> names = name.split(" ");
  String initials = "";

  if (names.length > 0) {
    initials += names[0][0].toUpperCase();
  }

  if (names.length > 1) {
    initials += names[1][0].toUpperCase();
  }

  return initials;
}
