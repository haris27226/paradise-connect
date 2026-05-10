
import 'package:flutter/material.dart';

void showLoadingDialog(bool loadingDialogShown, BuildContext context) {
  if (!context.mounted) return;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
}

void hideLoadingDialog(bool loadingDialogShown, BuildContext context) {
  if (!context.mounted) return;
  try {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  } catch (_) {}
}
