import 'package:share_plus/share_plus.dart';
import '../../features/contact/domain/entities/contact/contact.dart';

class ShareHelper {
  static void shareContact(Contact contact) {
    final String text = "Contact Info:\n"
        "Name: ${contact.fullName}\n"
        "Phone: ${contact.primaryPhone ?? '-'}\n"
        "Email: ${contact.primaryEmail ?? '-'}\n"
        "Address: ${contact.ktpAddress ?? '-'}";
    
    Share.share(text);
  }
}
