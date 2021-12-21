import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base_view_screen.dart';

import 'mdl_general_settings.dart';
import '../../../models/user.dart';
import '../../../generated/i18n.dart';
import '../../../logger.dart';

final log = getLogger('GeneralSettingsScreen');

class GeneralSettingsScreen extends StatelessWidget {
  static const routeName = '/general-settings';

  @override
  Widget build(BuildContext context) {
    log.i('building general settings screen');

    return BaseView<GeneralSettingsViewModel>(
      onModelReady: (model) {
        model.initializeModel(context);
      },
      builder: (context, model, child) {
        return MultiProvider(
          providers: [
            StreamProvider<List<User>>.value(
              initialData: [],
              value: model.database.getUser(user: model.user),
            ),
          ],
          child: WillPopScope(
            onWillPop: () {
              model.onWillPop();

              return Future.value(false);
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    model.onAppbarBackButtonPressed();
                  },
                ),
                title: Text(
                  I18n.of(context).generalSettingsScreenTitle,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            I18n.of(context)
                                .generalSettingsScreenGeneralSettings,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.lightbulb_outline),
                          title:
                              Text(I18n.of(context).generalSettingsScreenTheme),
                          trailing: ToggleButtons(
                            isSelected: model.isSelected,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(I18n.of(context)
                                    .generalSettingsScreenModeLight),
                              ), //Light
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(I18n.of(context)
                                    .generalSettingsScreenModeAuto),
                              ), //Auto
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(I18n.of(context)
                                    .generalSettingsScreenModeDark),
                              ), //Dark
                            ],
                            onPressed: (int index) {
                              model.onDarkButtonPressed(index);
                            },
                            borderRadius: BorderRadius.circular(55),
                            constraints: BoxConstraints(
                              minHeight: 30,
                              minWidth: 45,
                            ),
                          ),
                        ),
                        SwitchListTile(
                          title:
                              Text(I18n.of(context).generalSettingsScreenUnits),
                          secondary: Icon(Icons.straighten),
                          value: model.settings.isMetric,
                          subtitle: Text(
                            model.unit,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          onChanged: (bool value) {
                            model.onUnitButtonPressed(context, value);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.notifications_outlined),
                          title: Text(
                            I18n.of(context)
                                .generalSettingsScreenManageNotifications,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          onTap: () {
                            model.onNotificationListTileTap();
                          },
                          trailing: Icon(Icons.navigate_next),
                        ),
                        Divider(
                          color: Theme.of(context).accentColor,
                          thickness: 1,
                          indent: 5,
                          endIndent: 5,
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            I18n.of(context)
                                .generalSettingsScreenAccountSettings,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.perm_identity),
                          title: Text(
                            I18n.of(context)
                                .generalSettingsScreenChangeUsername,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          trailing: Icon(Icons.navigate_next),
                          onTap: () {
                            model.onChangeUsernameListTileTap();
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.perm_device_info),
                          title: Text(
                            I18n.of(context).generalSettingsScreenChangeNumber,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          trailing: Icon(Icons.navigate_next),
                          onTap: () {
                            model.onChangeNumberListTileTap();
                          },
                        ),
                        Divider(
                          color: Theme.of(context).accentColor,
                          thickness: 1,
                          indent: 5,
                          endIndent: 5,
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            I18n.of(context).generalSettingsScreenAbout,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.privacy_tip_outlined),
                          title: Text(
                            I18n.of(context).generalSettingsScreenPrivacyPolicy,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          trailing: Icon(Icons.open_in_new),
                          onTap: () {
                            model.launchInBrowser(
                                url:
                                    'https://docs.google.com/document/d/1WeYd6E3x-Pee-TDaA8kqpC8ZcgdB53TC5NDYdgo5Y3M/edit?usp=sharing',
                                linkTo: 'privacy_policy');
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.text_snippet_outlined),
                          title: Text(
                            I18n.of(context)
                                .generalSettingsScreenTermsOfServices,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          trailing: Icon(Icons.open_in_new),
                          onTap: () {
                            model.launchInBrowser(
                                url:
                                    'https://docs.google.com/document/d/1WeYd6E3x-Pee-TDaA8kqpC8ZcgdB53TC5NDYdgo5Y3M/edit?usp=sharing',
                                linkTo: 'terms_o_services');
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.bug_report_outlined),
                          title: Text(
                            I18n.of(context).generalSettingsScreenReportBug,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          trailing: Icon(Icons.open_in_new),
                          onTap: () {
                            model.launchInBrowser(
                                url: 'https://forms.gle/TG5ZZYpZwkTvZ9n47',
                                linkTo: 'bug_post');
                          },
                        ),
                        Divider(
                          color: Theme.of(context).accentColor,
                          thickness: 1,
                          indent: 5,
                          endIndent: 5,
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            I18n.of(context).generalSettingsScreenDangerZone,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            I18n.of(context)
                                .generalSettingsScreenAccountCloseWarning,
                            style: Theme.of(context).textTheme.subtitle2,
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 15, bottom: 20),
                          width: double.infinity,
                          height: 100,
                          child: TextButton(
                            // shape: Border.all(),
                            // color: Theme.of(context).errorColor,
                            // splashColor: Theme.of(context).accentColor,
                            onPressed: () async {
                              model.onCloseAccountButtonPressed(context);
                            },
                            child: Text(
                              I18n.of(context)
                                  .generalSettingsScreenCloseAccountButton,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
