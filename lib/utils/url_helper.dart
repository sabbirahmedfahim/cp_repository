import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  static Future<bool> launchProblemUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static String truncateUrl(String url) {
    try {
      final uri = Uri.parse(url);
      String display = '${uri.host}${uri.path}';
      if (display.length > 35) {
        return '${display.substring(0, 32)}...';
      }
      return display;
    } catch (_) {
      return url.length > 35 ? '${url.substring(0, 32)}...' : url;
    }
  }
}