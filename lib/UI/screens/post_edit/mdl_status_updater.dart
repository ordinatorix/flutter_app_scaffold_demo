import 'package:flutter/material.dart';

import '../../../enums/status_option.dart';
import '../../../generated/i18n.dart';

import '../../../logger.dart';

final log = getLogger('StatusUpdaterViewModel');

class StatusUpdaterViewModel {
  StatusOptions dropDownValue;
  String originalStatus;
  List<DropdownMenuItem<StatusOptions>> option0;
  List<DropdownMenuItem<StatusOptions>> option1;

  void initializeModel(BuildContext context, String status) {
    log.i('initializeModel | context: $context, status: $status');
    originalStatus = status;
    option0 = [
      DropdownMenuItem(
        child: Center(
            child: Text(
          I18n.of(context).postEditScreenClearedStatus,
        )),
        value: StatusOptions.Cleared,
      ),
    ];
    option1 = [
      DropdownMenuItem(
        child: Center(
            child: Text(
          I18n.of(context).postEditScreenClearedStatus,
        )),
        value: StatusOptions.Cleared,
      ),
      DropdownMenuItem(
        child: Center(
            child: Text(
          I18n.of(context).postEditScreenConfirmedStatus,
        )),
        value: StatusOptions.Confirmed,
      ),
      DropdownMenuItem(
        child: Center(
            child: Text(
          I18n.of(context).postEditScreenFakeStatus,
        )),
        value: StatusOptions.Fake,
      ),
    ];
  }

  void onDropDownButtonTap(
      StatusOptions selectedValue, Function statusHandler) {
    log.i(
        'onDropDownButtonTap | selectedValue: $selectedValue, statusHandler: $statusHandler');
    if (selectedValue == StatusOptions.Confirmed) {
      if (originalStatus == 'Confirmed') {
        log.d('This event has already been marked as confirmed');
      } else if (originalStatus == 'Cleared') {
        log.d('This event has already been marked as cleared');
      } else {
        dropDownValue = selectedValue;
        statusHandler('Confirmed');

        log.d('Changing status to confirmed');
      }
    } else if (selectedValue == StatusOptions.Cleared) {
      if (originalStatus == 'Cleared') {
        log.d('This Event has already been marked as cleared');
      } else {
        dropDownValue = selectedValue;
        statusHandler('Cleared');

        log.d('Changing status to cleared');
      }
    } else if (selectedValue == StatusOptions.Fake) {
      if (originalStatus == 'Fake') {
        log.d('This Event has already been marked as fake');
      } else {
        statusHandler('Fake');
        dropDownValue = selectedValue;
        log.d('Changing status to fake');
      }
    } else {
      log.w('unknown StatusOption received $selectedValue');
      return;
    }
  }
}
