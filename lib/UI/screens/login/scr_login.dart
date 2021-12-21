import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

import '../../base_view_screen.dart';

import '../../../enums/view_state.dart';

import '../../../generated/i18n.dart';

import '../../../models/user.dart' show DeviceLocation;

import 'mdl_login_screen.dart';

import '../../../logger.dart';

final log = getLogger('LoginScreen');

class LoginScreen extends StatelessWidget {
  static const routeName = '/login-screen';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    log.i('building login Screen');

    return BaseView<LoginScreenModel>(
      onModelDisposing: (model) {
        model.disposer();
      },
      onModelReady: (model) {},
      onModelDependencyChange: (model) {
        model.deviceLocation = Provider.of<DeviceLocation>(context);//TODO: review this stream
      },
      onModelUpdate: (model) {
        model.deviceLocation = Provider.of<DeviceLocation>(context);
      },
      builder: (context, model, child) => Scaffold(
        body: Stack(
          children: [
            Container(
              height: mediaQuery.size.height,
              child: Form(
                key: model.formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: mediaQuery.size.height * 0.2,
                    right: mediaQuery.size.width * 0.1,
                    left: mediaQuery.size.width * 0.1,
                    bottom: mediaQuery.size.height * 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        I18n.of(context).loginScreenLogin,
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 36,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: mediaQuery.size.height * 0.03,
                      ),
                      Text(
                        I18n.of(context).loginScreenNumber.toUpperCase(),
                        style: Theme.of(context).textTheme.overline,
                      ),
                      SizedBox(
                        height: mediaQuery.size.height * 0.01,
                      ),
                      TextFormField(
                        onFieldSubmitted: (_) {
                          final isValid = model.formKey.currentState.validate();
                          log.d('validation complete');
                          if (!isValid) {
                            log.d('isValid: $isValid');
                            log.d('not valid');
                            return;
                          }

                          final String mobile =
                              '${model.dialCode}${model.phoneController.text.trim()}';

                          model.phoneLogin(phoneNumber: mobile, ctx: context);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.phone,
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
                                          .dialogBackgroundColor),
                                  searchStyle:
                                      Theme.of(context).textTheme.bodyText2,
                                  padding: const EdgeInsets.only(
                                    left: 5.0,
                                    bottom: 2.5,
                                  ),
                                  dialogTextStyle:
                                      Theme.of(context).textTheme.bodyText2,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(fontSize: 16.0),
                                  onInit: (value) {
                                    model.onCountryChanged(
                                      countryCode: value.code,
                                      countryDialCode: value.dialCode,
                                      isInit: true,
                                    );
                                  },
                                  onChanged: (value) {
                                    model.onCountryChanged(
                                      countryCode: value.code,
                                      countryDialCode: value.dialCode,
                                    );
                                  },
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey[700],
                                ),
                              ],
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: I18n.of(context).loginScreenHintText,
                        ),
                        controller: model.phoneController,
                        validator: (value) =>
                            model.validateForm(value, context),
                      ),
                      SizedBox(
                        height: mediaQuery.size.height * 0.07,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(205, 141, 0, 1).withOpacity(0.9),
                              Theme.of(context).accentColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0, 1],
                          ),
                        ),
                        width: double.infinity,
                        child: TextButton(
                          child: Text(I18n.of(context).loginScreenLoginButton),
                          // textColor: Colors.white,
                          // padding: EdgeInsets.all(16),
                          onPressed: () {
                            final isValid =
                                model.formKey.currentState.validate();
                            log.d('validation complete');
                            if (!isValid) {
                              log.d('isValid: $isValid');
                              log.d('not valid');
                              return;
                            }

                            final String mobile =
                                '${model.dialCode}${model.phoneController.text.trim()}';

                            model.phoneLogin(phoneNumber: mobile, ctx: context);
                          },
                          // color: Colors.transparent,
                          // shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                      SizedBox(
                        height: mediaQuery.size.height * 0.07,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(107, 246, 0, 1).withOpacity(0.8),
                              Theme.of(context).accentColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: [0, 1],
                          ),
                        ),
                        width: double.infinity,
                        child: TextButton(
                          child: Text('Anonymous Login'),
                          // textColor: Colors.white,
                          // padding: EdgeInsets.all(16),
                          onPressed: () {
                           
                            model.anonLogin();
                            
                          },
                          // color: Colors.transparent,
                          // shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: mediaQuery.size.height * 0.07,
                            bottom: 5,
                            right: 15,
                            left: 15),
                        width: double.infinity,
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text:
                                    '${I18n.of(context).loginScreenRateWarning}\n\n${I18n.of(context).loginScreenPolicyAgreementWarning}',
                                style: Theme.of(context).textTheme.subtitle2,
                                children: [
                                  TextSpan(
                                    text:
                                        I18n.of(context).loginScreenTermsOfUse,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(
                                          color: Colors.lightBlue,
                                          decoration: TextDecoration.underline,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        model.launchInBrowser(
                                            url: 'https://google.com',
                                            linkTo: 'terms_o_services');
                                      },
                                  ),
                                  TextSpan(
                                      text: I18n.of(context).loginScreenAnd),
                                  TextSpan(
                                    text: I18n.of(context)
                                        .loginScreenPrivacyPolicy,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(
                                          color: Colors.lightBlue,
                                          decoration: TextDecoration.underline,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        model.launchInBrowser(
                                            url: 'https://google.com',
                                            linkTo: 'privacy_policy');
                                      },
                                  )
                                ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            model.state == ViewState.Busy
                ? Container(
                    width: mediaQuery.size.width,
                    height: mediaQuery.size.height,
                    color: Colors.black45,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
