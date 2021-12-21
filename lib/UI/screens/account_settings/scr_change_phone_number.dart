// TODO: use consumer for device location
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../base_view_screen.dart';

import '../../../enums/view_state.dart';

import '../../../models/user.dart';

import '../../../generated/i18n.dart';

import 'mdl_change_phone_number.dart';

import '../../../logger.dart';

final log = getLogger('ChangePhoneNumberScreen');

class ChangePhoneNumberScreen extends StatelessWidget {
  final User authUser;
  ChangePhoneNumberScreen({@required this.authUser});

  @override
  Widget build(BuildContext context) {
    log.i('building changephone screen');

    final mediaQuery = MediaQuery.of(context);
    return BaseView<ChangePhoneNumberModel>(
      onModelDisposing: (model) {
        model.disposer();
      },
      onModelDependencyChange: (model) {
        model.deviceLocation = Provider.of<DeviceLocation>(context);
      },
      onModelUpdate: (model) {
        model.deviceLocation = Provider.of<DeviceLocation>(context);
      },
      builder: (context, model, child) {
        model.initializeModel(context, authUser.uid);
        return (model.userList.isEmpty || model.userList == null)
            ? Center(
                child: SpinKitCubeGrid(
                  color: Theme.of(context).accentColor,
                ),
              )
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Form(
                      key: model.form,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                I18n.of(context)
                                    .changePhoneNumberScreenOldNumberTextfieldCaption,
                                softWrap: true,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.only(left: 15),
                                    // color: Colors.blue,
                                    width: mediaQuery.size.width * 0.32,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CountryCodePicker(
                                          boxDecoration: new BoxDecoration(
                                            borderRadius:
                                                new BorderRadius.circular(16.0),
                                            color: Theme.of(context)
                                                .dialogBackgroundColor,
                                          ),
                                          searchStyle: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                          padding: const EdgeInsets.only(
                                            left: 5.0,
                                            bottom: 2.5,
                                          ),
                                          dialogTextStyle: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(fontSize: 16.0),
                                          onInit: (value) {
                                            model.onOldNumberCountryChanged(
                                              countryCode: value.code,
                                              countryDialCode: value.dialCode,
                                              isInit: true,
                                            );
                                          },
                                          onChanged: (value) {
                                            model.onOldNumberCountryChanged(
                                              countryCode: value.code,
                                              countryDialCode: value.dialCode,
                                            );
                                          },
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                  hintText: I18n.of(context)
                                      .changePhoneNumberScreenTextFieldLabel,
                                ),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(
                                      model.newPhoneNumberFocusNode);
                                },
                                focusNode: model.oldPhoneNumberFocusNode,
                                keyboardType: TextInputType.phone,
                                controller: model.currentPhoneNumberController,
                                validator: (value) =>
                                    model.formValidator(value, context),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                I18n.of(context)
                                    .changePhoneNumberScreenNewNumberTextfieldCaption,
                                softWrap: true,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.only(left: 15),
                                      // color: Colors.blue,
                                      width: mediaQuery.size.width * 0.32,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CountryCodePicker(
                                            boxDecoration: new BoxDecoration(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        16.0),
                                                color: Theme.of(context)
                                                    .dialogBackgroundColor),
                                            searchStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                            padding: const EdgeInsets.only(
                                              left: 5.0,
                                              bottom: 2.5,
                                            ),
                                            dialogTextStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText2,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(fontSize: 16.0),
                                            onInit: (value) {
                                              model.onNewNumberCountryChanged(
                                                countryCode: value.code,
                                                countryDialCode: value.dialCode,
                                                isInit: true,
                                              );
                                            },
                                            onChanged: (value) {
                                              model.onNewNumberCountryChanged(
                                                countryCode: value.code,
                                                countryDialCode: value.dialCode,
                                              );
                                            },
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                    hintText: I18n.of(context)
                                        .changePhoneNumberScreenTextFieldLabel),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  model.updatePhoneNumber(
                                    ctx: context,
                                  );
                                },
                                focusNode: model.newPhoneNumberFocusNode,
                                keyboardType: TextInputType.phone,
                                controller: model.newPhoneNumberController,
                                validator: (value) =>
                                    model.formValidator(value, context),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();

                                model.updatePhoneNumber(
                                  ctx: context,
                                );
                              },
                              child: Text(
                                I18n.of(context).buttonsUpdateAccountButton,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  model.state == ViewState.Busy
                      ? Container(
                          color: Colors.black45,
                          child: Center(
                            child: SpinKitCubeGrid(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              );
      },
    );
  }
}
