import 'package:url_launcher/url_launcher.dart';

void launchBrowserUrl(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    try {
      await launchUrl(uri);
    } catch (_) {}
  }
}
