import 'dart:async';

import 'package:flutter/material.dart';

import '../models/dialog_model.dart';

import '../logger.dart';

final log = getLogger('DialogService');

class DialogService {
  GlobalKey<NavigatorState> _dialogNavigationKey = GlobalKey<NavigatorState>();
  Function(DialogRequest) _showDialogListener;
  Function(DialogRequest) _showSuccessDialogListener;
  Function(DialogRequest) _showWarningDialogListener;
  Function(DialogRequest) _showErrorDialogListener;
  Function(DialogRequest) _showTextInputDialogListener;
  Function(DialogRequest) _showFcmPromptDialogListener;
  Function(DialogRequest) _showFcmPostDialogListener;

  Completer<DialogResponse> _dialogCompleter;
  Completer<DialogResponse> _successDialogCompleter;
  Completer<DialogResponse> _warningDialogCompleter;
  Completer<DialogResponse> _errorDialogCompleter;
  Completer<DialogResponse> _textInputDialogCompleter;
  Completer<DialogResponse> _fcmPromptDialogCompleter;
  Completer<DialogResponse> _fcmPostDialogCompleter;

  GlobalKey<NavigatorState> get dialogNavigationKey => _dialogNavigationKey;

  /// Registers a callback function. Typically to show the dialog
  void registerDialogListener(Function(DialogRequest) showDialogListener) {
    log.i('registerDialogListener | showDialogListener: $showDialogListener');
    _showDialogListener = showDialogListener;
  }

  /// Registers a callback function. Typically to show the dialog
  void registerSuccessDialogListener(
      Function(DialogRequest) showSuccessDialogListener) {
    log.i(
        'registerSuccessDialogListener | showSuccessDialogListener: $showSuccessDialogListener');
    _showSuccessDialogListener = showSuccessDialogListener;
  }

  /// Registers a callback function. Typically to show the dialog
  void registerWarningDialogListener(
      Function(DialogRequest) showWarningDialogListener) {
    log.i(
        'registerWarningDialogListener | showWarningDialogListener: $showWarningDialogListener');
    _showWarningDialogListener = showWarningDialogListener;
  }

  /// Registers a callback function. Typically to show the dialog
  void registerErrorDialogListener(
      Function(DialogRequest) showErrorDialogListener) {
    log.i(
        'registerErrorDialogListener | showErrorDialogListener: $showErrorDialogListener');
    _showErrorDialogListener = showErrorDialogListener;
  }

  /// Registers a callback function. Typically to show the dialog
  void registerTextInputDialogListener(
      Function(DialogRequest) showTextInputDialogListener) {
    log.i(
        'registerTextInputDialogListener | showTextInputDialogListener: $showTextInputDialogListener');
    _showTextInputDialogListener = showTextInputDialogListener;
  }

  /// Registers a callback function. Typically to show the dialog
  void registerFcmPromptDialogListener(
      Function(DialogRequest) showFcmPromptDialogListener) {
    log.i(
        'registerFcmPromptDialogListener | showFcmPromptDialogListener: $showFcmPromptDialogListener');
    _showFcmPromptDialogListener = showFcmPromptDialogListener;
  }

  /// Registers a callback function. Typically to show the dialog
  void registerFcmPostDialogListener(
      Function(DialogRequest) showFcmPostDialogListener) {
    log.i(
        'registerFcmPostDialogListener | showFcmPostDialogListener: $showFcmPostDialogListener');
    _showFcmPostDialogListener = showFcmPostDialogListener;
  }

  /// Calls the dialog listener and returns a Future that will wait for dialogComplete.
  Future<DialogResponse> showDialog({
    @required String title,
    @required String description,
    Widget content,
    String buttonTitle = 'Ok',
    @required String dialogType,
  }) {
    log.i(
        'showDialog | title: $title, description: $description, buttonTitle: $buttonTitle');
    _dialogCompleter = Completer<DialogResponse>();
    _showDialogListener(DialogRequest(
      title: title,
      description: description,
      buttonTitle: buttonTitle,
      dialogType: dialogType,
      content: content,
    ));
    return _dialogCompleter.future.then((response) {
      log.d('future completed with: $response');
      var savedResponse = response;
      _dialogCompleter = null;
      return savedResponse;
    });
  }

  /// Shows a success dialog
  Future<DialogResponse> showSuccessDialog({
    @required String title,
    @required String description,
    String buttonTitle = 'Ok',
    @required String dialogType,
  }) {
    log.i(
        'showSuccessDialog | title: $title, description: $description, buttonTitle: $buttonTitle');
    log.d('initial dialog completer is: $_successDialogCompleter');
    if (_successDialogCompleter == null) {
      _successDialogCompleter = Completer<DialogResponse>();

      _showSuccessDialogListener(
        DialogRequest(
            title: title,
            description: description,
            buttonTitle: buttonTitle,
            dialogType: dialogType),
      );
    }
    return _successDialogCompleter.future.then((response) {
      log.d('future completed with: $response');
      var savedResponse = response;
      _successDialogCompleter = null;
      return savedResponse;
    });
  }

  /// Shows a warning dialog
  Future<DialogResponse> showWarningDialog({
    @required String title,
    @required String description,
    String confirmationTitle = 'Ok',
    String cancelTitle = 'Cancel',
    @required String dialogType,
  }) {
    log.i(
        'showWarningDialog | title: $title, description: $description, confirmationTitle: $confirmationTitle, cancelTitle: $cancelTitle');
    log.d('initial dialog completer is: $_warningDialogCompleter');
    if (_warningDialogCompleter == null) {
      _warningDialogCompleter = Completer<DialogResponse>();

      _showWarningDialogListener(
        DialogRequest(
            title: title,
            description: description,
            buttonTitle: confirmationTitle,
            cancelTitle: cancelTitle,
            dialogType: dialogType),
      );
    }

    return _warningDialogCompleter.future.then((response) {
      log.d('future completed with: $response');
      var savedResponse = response;
      _warningDialogCompleter = null;
      return savedResponse;
    });
  }

  /// Shows a error dialog
  Future<DialogResponse> showErrorDialog({
    @required String title,
    @required String description,
    String buttonTitle = 'Ok',
    @required String dialogType,
  }) {
    log.i(
        'showErrorDialog | title: $title, description: $description, buttonTitle: $buttonTitle');
    log.d('initial dialog completer is: $_errorDialogCompleter');
    if (_errorDialogCompleter == null) {
      _errorDialogCompleter = Completer<DialogResponse>();

      _showErrorDialogListener(
        DialogRequest(
            title: title,
            description: description,
            buttonTitle: buttonTitle,
            dialogType: dialogType),
      );
    }

    return _errorDialogCompleter.future.then((response) {
      log.d('future completed with: $response');
      var savedResponse = response;
      _errorDialogCompleter = null;
      return savedResponse;
    });
  }

  /// Shows a prompt dialog
  Future<DialogResponse> showTextInputDialog({
    @required String title,
    String description,
    String confirmationTitle = 'Done',
    String cancelTitle = 'Cancel',
    @required String dialogType,
  }) {
    log.i(
        'showTextInputDialog | title: $title, description: $description, confirmationTitle: $confirmationTitle, cancelTitle: $cancelTitle');
    log.d('initial dialog completer is: $_textInputDialogCompleter');
    if (_textInputDialogCompleter == null) {
      _textInputDialogCompleter = Completer<DialogResponse>();

      _showTextInputDialogListener(
        DialogRequest(
            title: title,
            description: description,
            buttonTitle: confirmationTitle,
            cancelTitle: cancelTitle,
            dialogType: dialogType),
      );
    }

    return _textInputDialogCompleter.future.then((response) {
      log.d('future completed with: $response');
      var savedResponse = response;
      _textInputDialogCompleter = null;
      return savedResponse;
    });
  }

  /// Shows a FCM prompt dialog
  // TODO: rename to showPromtDialog
  Future<DialogResponse> showFcmPromptDialog({
    @required String title,
    @required String description,
    String confirmationTitle,
    String cancelTitle,
    @required String dialogType,
  }) {
    log.i(
        'showFcmPromptDialog | title: $title, description: $description, confirmationTitle: $confirmationTitle, cancelTitle: $cancelTitle');
    log.d('initial dialog completer is: $_fcmPromptDialogCompleter');
    if (_fcmPromptDialogCompleter == null) {
      _fcmPromptDialogCompleter = Completer<DialogResponse>();

      _showFcmPromptDialogListener(
        DialogRequest(
            title: title,
            description: description,
            buttonTitle: confirmationTitle,
            cancelTitle: cancelTitle,
            dialogType: dialogType),
      );
    }

    return _fcmPromptDialogCompleter.future.then((response) {
      log.d('future completed with: $response');
      var savedResponse = response;
      _fcmPromptDialogCompleter = null;
      return savedResponse;
    });
  }

  /// Shows a FCM prompt dialog
  Future<DialogResponse> showFcmPostDialog({
    @required String title,
    @required String description,
    String confirmationTitle = 'Proceed',
    String cancelTitle = 'Dismiss',
    @required String dialogType,
    @required String publisherId,
  }) {
    log.i(
        'showFcmPostDialog | title: $title, description: $description, confirmationTitle: $confirmationTitle, cancelTitle: $cancelTitle, dialog type: $dialogType, publisher ID: $publisherId');
    log.d('initial FCM dialog completer is: $_fcmPostDialogCompleter');
    if (_fcmPostDialogCompleter == null) {
      _fcmPostDialogCompleter = Completer<DialogResponse>();

      _showFcmPostDialogListener(
        DialogRequest(
            title: title,
            description: description,
            buttonTitle: confirmationTitle,
            cancelTitle: cancelTitle,
            dialogType: dialogType,
            publisherId: publisherId),
      );
    } else {
      // TODO: handle case when posts are submitted at the same time.
      fcmPostDialogComplete(DialogResponse(confirmed: false));
    }

    return _fcmPostDialogCompleter.future.then((response) {
      log.d('showFcmPostDialog future completed with: $response');
      var savedResponse = response;
      _fcmPostDialogCompleter = null;
      return savedResponse;
    });
  }

  /// Completes the [_dialogCompleter] to resume the Future's execution call
  void dialogComplete(DialogResponse response) {
    log.i('dialogComplete | response: $response');
    // _dialogNavigationKey.currentState.pop();
    _dialogCompleter.complete(response);
    // TODO: pop the navigator here with the response bool?
  }

  /// Completes the [_successDialogCompleter] to resume the Future's execution call
  void successDialogComplete(DialogResponse response) {
    log.i('dialogComplete | response: $response');
    // _dialogNavigationKey.currentState.pop();
    _successDialogCompleter?.complete(response);
    // TODO: pop the navigator here with the response bool?
  }

  /// Completes the [_warningDialogCompleter] to resume the Future's execution call
  void warningDialogComplete(DialogResponse response) {
    log.i('dialogComplete | response: $response');
    // _dialogNavigationKey.currentState.pop();
    _warningDialogCompleter.complete(response);
    // TODO: pop the navigator here with the response bool?
  }

  /// Completes the [_errorDialogCompleter] to resume the Future's execution call
  void errorDialogComplete(DialogResponse response) {
    log.i('dialogComplete | response: $response');
    // _dialogNavigationKey.currentState.pop();
    _errorDialogCompleter.complete(response);
    // TODO: pop the navigator here with the response bool?
  }

  /// Completes the [_textInputDialogCompleter] to resume the Future's execution call
  void textInputDialogComplete(DialogResponse response) {
    log.i('dialogComplete | response: $response');
    // _dialogNavigationKey.currentState.pop();
    _textInputDialogCompleter.complete(response);
    // TODO: pop the navigator here with the response bool?
  }

  /// Completes the [_fcmPromptDialogCompleter] to resume the Future's execution call
  void fcmPromptDialogComplete(DialogResponse response) {
    log.i('dialogComplete | response: $response');
    // _dialogNavigationKey.currentState.pop();
    _fcmPromptDialogCompleter.complete(response);
    // TODO: pop the navigator here with the response bool?
  }

  /// Completes the [_fcmPostDialogCompleter] to resume the Future's execution call
  void fcmPostDialogComplete(DialogResponse response) {
    log.i('fcmPostDialogComplete | response $response');
    // _dialogNavigationKey.currentState.pop();
    _fcmPostDialogCompleter.complete(response);
    log.d('fcmPostDialogComplete has been completed');
    // TODO: pop the navigator here with the response bool?
  }
}
