import 'package:url_launcher/url_launcher.dart';

import '../logger.dart';
import '../locator.dart';
import '../services/analytics_service.dart';

final log = getLogger('UrlLauncherService');

class UrlLauncherService {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  Future<void> launchInBrowser({String url, String linkTo}) async {
    log.i('launchInBrowser | url: $url');
    _analyticsService.logCustomEvent(
        name: 'open_link_in_browser', parameters: {'link_to': linkTo});
    if (await canLaunch(url)) {
      await launch(
        url,
      );
    } else {
      throw 'Could open launch $url';
    }
  }
}
