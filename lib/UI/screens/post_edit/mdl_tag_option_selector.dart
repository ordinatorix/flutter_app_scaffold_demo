import 'package:flutter/material.dart';

import '../../base_model.dart';

import '../../../locator.dart';
import '../../../logger.dart';

import '../../../enums/view_state.dart';

import '../../../services/analytics_service.dart';
import '../../../services/navigation_service.dart';

import '../../../helpers/share_prefs_helper.dart';

import '../../../generated/i18n.dart';

final log = getLogger('TagOptionSelectorViewModel');

class TagOptionSelectorViewModel extends BaseModel {
  final SharedPrefsHelper _prefs = locator<SharedPrefsHelper>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final NavigationService _navigationService = locator<NavigationService>();

  List<Map> options;
  List<String> _selectedList = [];

  void initializeModel(BuildContext context) async {
    log.i('initializeModel | context: $context');
    _selectedList = _prefs.postTagList;
    options = [
      {
        'state': false,
        'refresh': true,
        'selected': 0,
      },
      {
        'state': false,
        'refresh': true,
        'selected': 0,
      },
      {
        'state': false,
        'refresh': true,
        'selected': 0,
      },
    ];
  }

  void getState(int index, String tagKey) async {
    log.i('getState | index: $index, tagKey: $tagKey');
    final String stateTagKey = '${tagKey}state';
    final String intTagKey = '${tagKey}int';
    if (options[index]['refresh']) {
      // log.w('is refresh');
      // log.w('stateTagKey: ${tagKey}state');
      // log.w('intTagKey: ${tagKey}int');
      // log.w('tagstate before: ${options[index]['state']}');
      options[index]['state'] = await _prefs.getTagState(stateTagKey) ?? false;
      // log.w('tagstate after: ${options[index]['state']}');
      // log.w('selected after: ${options[index]['selected']}');
      options[index]['selected'] = await _prefs.getInt(intTagKey) ?? 0;
      // log.w('selected after: ${options[index]['selected']}');
      options[index]['refresh'] = false;

      setState(ViewState.Idle);
    }
  }

  void onTagSelected({
    BuildContext context,
    Map tagInfo,
    int index,
    Function showSnackbar,
    String verificationType,
    String stat,
  }) async {
    log.i(
        'onTagSelected | context: $context, index: $index, tagInfo: $tagInfo, showSnackbar: $showSnackbar, verificationType: $verificationType, stat: $stat, ');
    final String optionIndex = 'option$index';
    final stateTagKey = '${tagInfo[optionIndex]}state';
    final intTagKey = '${tagInfo[optionIndex]}int';

    options[index]['refresh'] = true;
    if (options.where((element) => element.containsValue(1)).length <
        tagInfo['selectable']) {
      //if the number of selected items is less then the allowed number

      // I can select or remove the tags
      _prefs.setTagState(stateTagKey, !options[index]['state']);

      if (options[index]['state']) {
        log.d('removing currently selected tag');
        // if state is true, I need to remove the tag
        // IFF i have not pass the selectable amount
        _selectedList.remove(tagInfo[optionIndex]);
        await _prefs.updatePostTagList(_selectedList);
        _prefs.setInt(intTagKey, 0);

        await _analyticsService
            .logCustomEvent(name: 'remove_tags', parameters: {
          'verification_type': verificationType,
          'post_type': '${stat}_${tagInfo['title']}',
          'selected_tags': tagInfo[optionIndex]
        });
      } else {
        // otherwise add the tag
        _selectedList.add(tagInfo[optionIndex]);

        await _prefs.updatePostTagList(_selectedList);

        _prefs.setInt(intTagKey, 1);
        await _analyticsService.logCustomEvent(name: 'added_tags', parameters: {
          'verification_type': verificationType,
          'post_type': '${stat}_${tagInfo['title']}',
          'selected_tags': tagInfo[optionIndex]
        });
      }
    } else if (options.where((element) => element.containsValue(1)).length ==
        tagInfo['selectable']) {
      log.d('can only unselect tags');
      showSnackbar(
          '${I18n.of(context).postEditScreenTagLimit} ${tagInfo['selectable']} tag(s)');

      // Can only unselect tag
      _prefs.setTagState(stateTagKey, false);

      _selectedList.remove(tagInfo[optionIndex]);

      await _prefs.setInt(intTagKey, 0);

      await _prefs.updatePostTagList(_selectedList);
      await _analyticsService.logCustomEvent(name: 'remove_tags', parameters: {
        'verification_type': verificationType,
        'post_type': '${stat}_${tagInfo['title']}',
        'selected_tags': tagInfo[optionIndex]
      });
      _navigationService.pop();
    } else {
      log.wtf('This should not happen when selecting tags');
      showSnackbar(
          '${I18n.of(context).postEditScreenTagLimit} ${tagInfo['selectable']} tag(s)');
      // Can only unselect tag, but should not happen
      _prefs.setTagState(stateTagKey, false);
      _selectedList.remove(tagInfo[optionIndex]);

      await _prefs.updatePostTagList(_selectedList);

      _prefs.setInt(intTagKey, 0);
      await _analyticsService.logCustomEvent(name: 'remove_tags', parameters: {
        'verification_type': verificationType,
        'post_type': '${stat}_${tagInfo['title']}',
        'selected_tags': tagInfo[optionIndex]
      });
      _navigationService.pop();
    }

    setState(ViewState.Idle);
  }
}
