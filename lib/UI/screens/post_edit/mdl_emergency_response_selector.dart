import 'package:flutter/material.dart';

import '../../../locator.dart';
import '../../../enums/view_state.dart';
import '../../../services/analytics_service.dart';
import '../../../helpers/share_prefs_helper.dart';
import '../../../generated/i18n.dart';

import '../../base_model.dart';

import '../../../logger.dart';

final log = getLogger('EmergencyResponseSelectorViewModel');

class EmergencyResponseSelectorViewModel extends BaseModel {
  final SharedPrefsHelper prefs = locator<SharedPrefsHelper>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  List<Map> options;
  List<String> _selectedList = [];

  void initializeModel(BuildContext context) async {
    log.i('initializeModel | context: $context');
    _selectedList = prefs.emergencyTagList;
    options = [
      {
        'title': 'Police onsite',
        'titleTrans': I18n.of(context).postEditScreenPoliceOnsite,
        'icon': Icons.local_police,
        'state': false,
        'refresh': true,
      },
      {
        'title': 'Ambulance onsite',
        'titleTrans': I18n.of(context).postEditScreenAmbulanceOnsite,
        'icon': Icons.local_hospital,
        'state': false,
        'refresh': true,
      },
      {
        'title': 'Firefighters onsite',
        'titleTrans': I18n.of(context).postEditScreenFirefightersOnsite,
        'icon': Icons.local_fire_department,
        'state': false,
        'refresh': true,
      },
    ];
  }

  void getState(int index) async {
    log.i('getState | index: $index');
    if (options[index]['refresh']) {
      options[index]['state'] =
          await prefs.getTagState(options[index]['title']) ?? false;
      options[index]['refresh'] = false;
      setState(ViewState.Idle);
    }
  }

  void onTagSelected({
    int index,
    String verificationType,
    String stat,
    String title,
  }) async {
    log.i(
        'onTagSelected | index: $index, verificationType: $verificationType, stat: $stat, title: $title');
    // store the state of the selected tag to what it was not
    prefs.setTagState(options[index]['title'], !options[index]['state']);
    options[index]['refresh'] = true;

    if (options[index]['state']) {
      // if state is true, I need to remove the tag
      _selectedList.remove(options[index]['title']);
      prefs.updateEmergencyTagList(_selectedList);
      await _analyticsService
          .logCustomEvent(name: 'remove_emergency_tag', parameters: {
        'verification_type': verificationType,
        'post_type': '${stat}_$title',
        'selected_tags': options[index]['title']
      });
    } else {
      // otherwise add the tag
      _selectedList.add(options[index]['title']);
      prefs.updateEmergencyTagList(_selectedList);
      await _analyticsService
          .logCustomEvent(name: 'added_emergency_tag', parameters: {
        'verification_type': verificationType,
        'post_type': '${stat}_$title',
        'selected_tags': options[index]['title']
      });
    }
    setState(ViewState.Idle);
  }
}
