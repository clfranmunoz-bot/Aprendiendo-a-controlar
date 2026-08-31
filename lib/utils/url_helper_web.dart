import 'package:url_launcher/url_launcher.dart';

void openUrl(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    await launchUrl(uri);
  } catch (_) {}
}
