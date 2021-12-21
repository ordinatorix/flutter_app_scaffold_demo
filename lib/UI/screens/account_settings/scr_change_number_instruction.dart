import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'scr_account_settings.dart';
import '../../../services/navigation_service.dart';
import '../../../generated/i18n.dart';
import '../../../logger.dart';
import '../../../locator.dart';

final log = getLogger('ChangeNumberInstructionScreen');

class ChangeNumberInstructionScreen extends StatelessWidget {
  static const routeName = '/change-number-instruction-screen';
  final NavigationService _navigationService = locator<NavigationService>();
  @override
  Widget build(BuildContext context) {
    SystemChrome.restoreSystemUIOverlays();
    log.i('building Change Number Instruction Screen');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          I18n.of(context).changeNumberInstructionScreenTitle,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                I18n.of(context).changeNumberInstructionScreenInfo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                I18n.of(context).changeNumberInstructionScreenInfo2,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                I18n.of(context).changeNumberInstructionScreenInfo3,
                textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _navigationService.navigateTo(
                    AccountSettingScreen.routeName,
                    arguments: 'phoneNumber',
                  );
                 
                },
                child: Text(I18n.of(context).buttonsNextButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
