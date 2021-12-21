import '../locator.dart';
import '../services/dialog_service.dart';
import '../services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter/services.dart';

import '../models/dialog_model.dart';
import '../logger.dart';
import '../generated/i18n.dart';

final log = getLogger('DialogManager');

class DialogManager extends StatefulWidget {
  final Widget child;
  final String publisherID;
  DialogManager({
    Key key,
    this.child,
    this.publisherID,
  }) : super(key: key);

  _DialogManagerState createState() => _DialogManagerState();
}

class _DialogManagerState extends State<DialogManager> {
  DialogService _dialogService = locator<DialogService>();
  final AnalyticsService _analytics = locator<AnalyticsService>();
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();

  @override
  void initState() {
    log.i('initState');
    super.initState();
    _dialogService.registerDialogListener(_showDialog);
    _dialogService.registerSuccessDialogListener(_showSuccessDialog);
    _dialogService.registerErrorDialogListener(_showErrorDialog);
    _dialogService.registerWarningDialogListener(_showWarningDialog);
    _dialogService.registerTextInputDialogListener(_showTextInputDialog);
    _dialogService.registerFcmPromptDialogListener(_showFcmPromptDialog);
    _dialogService.registerFcmPostDialogListener(_showFcmPostDialog);
  }

  @override
  void dispose() {
    log.i('dispose');
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.d('building dialog manager');
    return widget.child;
  }

  Future _showDialog(DialogRequest request) async {
    log.i('_showDialog | request: $request');
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromBottom,
      isCloseButton: false,
      isOverlayTapDismiss: true,
      titleStyle: Theme.of(context).textTheme.headline6,
      descStyle: Theme.of(context).textTheme.bodyText2,
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45),
        side: BorderSide(
          color: Colors.amber,
        ),
      ),
    );
    var alert = await Alert(
        context: context,
        title: request.title,
        desc: request.description,
        content: request.content,
        style: alertStyle,
        closeFunction: () =>
            _dialogService.dialogComplete(DialogResponse(confirmed: true)),
        buttons: [
          DialogButton(
            child: Text(request.buttonTitle),
            onPressed: () {
              _analytics.dialogResponse(
                dialogType: request.dialogType,
                response: 'dismiss',
              );
              _dialogService.dialogComplete(DialogResponse(confirmed: true));
              Navigator.of(context).pop(true);
            },
          ),
        ]).show();
    if (alert == null) {
      _dialogService.dialogComplete(DialogResponse(confirmed: true));
    }
    return alert;
  }

  /// Build success dialog.
  ///
  /// Returns [true] after user input or [timeout] delay.
  Future _showSuccessDialog(DialogRequest request) async {
    log.i('_showSuccessDialog | request: $request');
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromBottom,
      isCloseButton: false,
      isOverlayTapDismiss: true,
      titleStyle: Theme.of(context).textTheme.headline6,
      descStyle: Theme.of(context).textTheme.bodyText2,
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45),
        side: BorderSide(
          color: Colors.amber,
        ),
      ),
    );

    bool alert = await Alert(
        context: context,
        type: AlertType.success,
        title: request.title,
        desc: request.description,
        style: alertStyle,
        closeFunction: () => _dialogService
            .successDialogComplete(DialogResponse(confirmed: true)),
        buttons: [
          DialogButton(
            child: Text(
              request.buttonTitle.toUpperCase(),
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              _analytics.dialogResponse(
                dialogType: request.dialogType,
                response: 'okay',
              );
              _dialogService
                  .successDialogComplete(DialogResponse(confirmed: true));
              Navigator.of(context).pop(true);
            },
          )
        ]).show().timeout(Duration(seconds: 5), onTimeout: () {
      log.d('sucess dialog timeout');
      _dialogService.successDialogComplete(DialogResponse(confirmed: true));
      Navigator.of(context).pop(true);
      return true;
    });
    log.d('returned from success alert dialog: $alert');
    if (alert == null) {
      _dialogService.successDialogComplete(DialogResponse(confirmed: true));
    }
    return alert;
  }

  /// Build warning dialog.
  ///
  /// Returns [true] or [false] after user input.
  Future _showWarningDialog(DialogRequest request) async {
    log.i('_showWarningDialog | request: $request');
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromBottom,
      isCloseButton: false,
      isOverlayTapDismiss: true,
      titleStyle: Theme.of(context).textTheme.headline6,
      descStyle: Theme.of(context).textTheme.bodyText2,
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45),
        side: BorderSide(
          color: Colors.amber,
        ),
      ),
    );

    bool alert = await Alert(
        context: context,
        type: AlertType.warning,
        title: request.title,
        desc: request.description,
        style: alertStyle,
        closeFunction: () => _dialogService
            .warningDialogComplete(DialogResponse(confirmed: false)),
        buttons: [
          DialogButton(
            color: Colors.redAccent,
            child: Text(request.cancelTitle),
            onPressed: () {
              _analytics.dialogResponse(
                  dialogType: request.dialogType, response: 'abort');
              _dialogService
                  .warningDialogComplete(DialogResponse(confirmed: false));
              Navigator.of(context).pop(false);
            },
          ),
          DialogButton(
            color: Colors.green,
            child: Text(request.buttonTitle),
            onPressed: () {
              _analytics.dialogResponse(
                  dialogType: request.dialogType, response: 'proceed');
              _dialogService
                  .warningDialogComplete(DialogResponse(confirmed: true));
              Navigator.of(context).pop(true);
            },
          ),
        ]).show();
    log.d('returned from warning alert dialog: $alert');
    if (alert == null) {
      _dialogService.warningDialogComplete(DialogResponse(confirmed: false));
    }
    return alert;
  }

  /// Build error dialog.
  ///
  /// Returns [false] after user input.
  Future _showErrorDialog(DialogRequest request) async {
    log.i('_showErrorDialog | request: $request');
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromBottom,
      isCloseButton: false,
      isOverlayTapDismiss: false,
      titleStyle: Theme.of(context).textTheme.headline6,
      descStyle: Theme.of(context).textTheme.bodyText2,
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45),
        side: BorderSide(
          color: Colors.amber,
        ),
      ),
    );

    var alert = await Alert(
        context: context,
        type: AlertType.error,
        title: request.title,
        desc: request.description,
        style: alertStyle,
        closeFunction: () => _dialogService
            .errorDialogComplete(DialogResponse(confirmed: false)),
        buttons: [
          DialogButton(
            color: Colors.redAccent,
            child: Text(
              request.buttonTitle.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              _analytics.dialogResponse(
                  dialogType: request.dialogType, response: 'okay');
              _dialogService
                  .errorDialogComplete(DialogResponse(confirmed: false));
              Navigator.of(context).pop(false);
            },
          )
        ]).show();
    log.d('returned from error alert dialog: $alert');
    if (alert == null) {
      _dialogService.errorDialogComplete(DialogResponse(confirmed: false));
    }
    return alert;
  }

  /// Build text input dialog.
  ///
  /// Returns [true] and a [String] or [false] after user input.
  Future _showTextInputDialog(DialogRequest request) async {
    log.i('_showTextInputDialog | request: $request,');

    String smsCode;
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromBottom,
      isCloseButton: false,
      isOverlayTapDismiss: true,
      titleStyle: Theme.of(context).textTheme.headline6,
      descStyle: Theme.of(context).textTheme.bodyText2,
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45),
        side: BorderSide(
          color: Colors.amber,
        ),
      ),
    );

    var alert = await Alert(
        context: context,
        type: AlertType.none,
        title: request.title,
        desc: '',
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the code received.';
                  } else if (RegExp(r'^[1-9]\d{5,}$').hasMatch(value)) {
                    return null;
                  } else {
                    return 'Please enter a valid code.';
                  }
                },
                controller: _codeController,
                keyboardType: TextInputType.number,
                onEditingComplete: () async {
                  // activated when pressing enter on the keyboard
                  if (_formKey.currentState.validate()) {
                    log.d('editing complete');
                    await _analytics.dialogResponse(
                        dialogType: request.dialogType, response: 'done');

                    smsCode = _codeController.text.trim();
                    if (smsCode.isEmpty || smsCode == null) {
                      _dialogService.textInputDialogComplete(
                          DialogResponse(confirmed: false));
                      Navigator.of(context).pop(false);
                      smsCode = null;
                      _codeController?.clear();
                    } else {
                      _dialogService.textInputDialogComplete(
                          DialogResponse(confirmed: true, fieldOne: smsCode));
                      Navigator.of(context).pop(true);
                      smsCode = null;
                      _codeController?.clear();
                    }
                    SystemChrome
                        .restoreSystemUIOverlays(); //removes the system navigation bar
                  }
                },
              ),
            ],
          ),
        ),
        style: alertStyle,
        closeFunction: () => _dialogService
            .textInputDialogComplete(DialogResponse(confirmed: false)),
        buttons: [
          DialogButton(
            color: Colors.redAccent,
            child: Text(request.cancelTitle),
            onPressed: () {
              log.d('dialog response negative');
              _analytics.dialogResponse(
                  dialogType: request.dialogType, response: 'cancel');
              _dialogService
                  .textInputDialogComplete(DialogResponse(confirmed: false));
              SystemChrome
                  .restoreSystemUIOverlays(); //removes the system navigation bar
              Navigator.of(context).pop(false);
              smsCode = null;
              _codeController?.clear();
            },
          ),
          DialogButton(
            color: Colors.green,
            child: Text(request.buttonTitle),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                log.d('editing complete');
                await _analytics.dialogResponse(
                    dialogType: request.dialogType, response: 'done');

                smsCode = _codeController.text.trim();
                if (smsCode.isEmpty || smsCode == null) {
                  _dialogService.textInputDialogComplete(
                      DialogResponse(confirmed: false));
                  Navigator.of(context).pop(false);
                  smsCode = null;
                  _codeController?.clear();
                } else {
                  _dialogService.textInputDialogComplete(
                      DialogResponse(confirmed: true, fieldOne: smsCode));
                  Navigator.of(context).pop(true);
                  smsCode = null;
                  _codeController?.clear();
                }
                SystemChrome.restoreSystemUIOverlays();
              }
            },
          ),
        ]).show();
    log.d('returned from text input alert dialog: $alert');
    if (alert == null) {
      _dialogService.textInputDialogComplete(DialogResponse(confirmed: false));
    }
    return alert;
  }

  /// Build fcm prompt dialog.
  ///
  /// Returns [true] or [false] after user input.
  Future _showFcmPromptDialog(DialogRequest request) async {
    log.i('_showFcmPromptDialog | request: $request');
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromBottom,
      isCloseButton: false,
      isOverlayTapDismiss: true,
      titleStyle: Theme.of(context).textTheme.headline6,
      descStyle: Theme.of(context).textTheme.bodyText2,
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45),
        side: BorderSide(
          color: Colors.amber,
        ),
      ),
    );

    var alert = await Alert(
        context: context,
        type: AlertType.none,
        title: request.title,
        desc: request.description,
        style: alertStyle,
        closeFunction: () => _dialogService
            .fcmPromptDialogComplete(DialogResponse(confirmed: false)),
        buttons: [
          DialogButton(
            color: Colors.redAccent,
            child: Text(
              request.cancelTitle ?? I18n.of(context).buttonsDismissButton,
            ),
            onPressed: () {
              _analytics.dialogResponse(
                  dialogType: request.dialogType, response: 'dismiss');
              _dialogService
                  .fcmPromptDialogComplete(DialogResponse(confirmed: false));
              Navigator.of(context).pop(false);
            },
          ),
          DialogButton(
            color: Colors.green,
            child: Text(
              request.buttonTitle ?? I18n.of(context).buttonsProceedButton,
            ),
            onPressed: () {
              _analytics.dialogResponse(
                  dialogType: request.dialogType, response: 'proceed');
              _dialogService
                  .fcmPromptDialogComplete(DialogResponse(confirmed: true));
              Navigator.of(context).pop(true);
            },
          ),
        ]).show();
    log.d('returned from FCM prompt alert dialog: $alert');
    if (alert == null) {
      _dialogService.fcmPromptDialogComplete(DialogResponse(confirmed: false));
    }
    return alert;
  }

  /// Build fcm post dialog.
  ///
  /// Returns [true] or [false] after user input.
  Future _showFcmPostDialog(DialogRequest request) async {
    log.i('_showFcmPostDialog | request: $request');
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromBottom,
      isCloseButton: false,
      isOverlayTapDismiss: true,
      titleStyle: Theme.of(context).textTheme.headline6,
      descStyle: Theme.of(context).textTheme.bodyText2,
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45),
        side: BorderSide(
          color: Colors.amber,
        ),
      ),
    );
    var alert;
    if (request.publisherId == widget.publisherID) {
      log.d('current user is the publisher');
      alert = null;
    } else {
      alert = await Alert(
          context: context,
          type: AlertType.none,
          title: I18n.of(context).dialogsPostNotificationTitle(request.title),
          desc: request.description,
          style: alertStyle,
          closeFunction: () => _dialogService.fcmPostDialogComplete(
                DialogResponse(
                  confirmed: false,
                  publisherIsUser: (request.publisherId == widget.publisherID),
                ),
              ),
          buttons: [
            DialogButton(
              color: Colors.redAccent,
              child: Text(
                I18n.of(context).buttonsDismissButton,
              ),
              onPressed: () {
                _analytics.dialogResponse(
                    dialogType: request.dialogType, response: 'dismiss');
                _dialogService.fcmPostDialogComplete(
                  DialogResponse(
                    confirmed: false,
                    publisherIsUser:
                        (request.publisherId == widget.publisherID),
                  ),
                );
                Navigator.of(context).pop(false);
              },
            ),
            DialogButton(
              color: Colors.green,
              child: Text(I18n.of(context).dialogsFcmShowMeButton),
              onPressed: () {
                _analytics.dialogResponse(
                    dialogType: request.dialogType, response: 'proceed');
                _dialogService.fcmPostDialogComplete(
                  DialogResponse(
                    confirmed: true,
                    publisherIsUser:
                        (request.publisherId == widget.publisherID),
                  ),
                );
                Navigator.of(context).pop(true);
              },
            ),
          ]).show();
    }
    log.d('returned from FCM post alert dialog: $alert');
    if (alert == null) {
      _dialogService.fcmPostDialogComplete(
        DialogResponse(
          confirmed: false,
          publisherIsUser: (request.publisherId == widget.publisherID),
        ),
      );
    }
    return alert;
  }
}
