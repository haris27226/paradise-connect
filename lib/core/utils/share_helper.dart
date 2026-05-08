import 'package:share_plus/share_plus.dart';
import '../../features/contact/domain/entities/contact/contact.dart';

class ShareHelper {
  static void shareContact(Contact contact) {
    final String text = "Name: ${contact.fullName}\nWhatsapp: https://wa.me/${contact.whatsappNumber ?? '-'}";
    
    Share.share(text);
  }
}
