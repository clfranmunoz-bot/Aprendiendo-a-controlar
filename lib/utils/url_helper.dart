import 'url_helper_stub.dart'
    if (dart.library.html) 'url_helper_web.dart'
    if (dart.library.io) 'url_helper_mobile.dart';

void launchBrowserUrl(String url) {
  openUrl(url);
}
