import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:permission_handler/permission_handler.dart';

import './analytics_service.dart';
import './database_service.dart';
import './dialog_service.dart';
import './navigation_service.dart';

import '../locator.dart';
import '../logger.dart';

import '../models/user.dart';
import '../models/settings.dart';

import '../generated/i18n.dart';

import '../helpers/soul_reaper.dart';
import '../helpers/custom_exceptions.dart';
import '../helpers/initial_location.dart';
import '../helpers/share_prefs_helper.dart';

final log = getLogger('AuthService');

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final SoulReaper _reaper = SoulReaper();
  final SharedPrefsHelper _sharedPrefsHelper = locator<SharedPrefsHelper>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final Duration _autoVerificationTimeout = Duration(seconds: 60);
  final CountryISOCode _isoCodes = CountryISOCode();
  Completer<auth.User> _loginCompleter = Completer();
  Completer<auth.User> _changeNumberCompleter = Completer();
  Completer<auth.User> _closeAccountCompleter = Completer();

  /// Converts firebase_auth user to User.
  User _userFromFirebaseUser(auth.User authUser) {
    log.i('_userFromFirebaseUser | user: $authUser');
    User user;
    if (authUser != null) {
      log.d(
          'uid: ${authUser.uid}, displayName:${authUser.displayName}, email: ${authUser.email}, phoneNumber:${authUser.phoneNumber}, isAnonymous: ${authUser.isAnonymous}, photoUrl: ${authUser.photoURL}');
      user = User(
        uid: authUser.uid,
        displayName: authUser.displayName,
        email: authUser.email,
        phone: authUser.phoneNumber,
        isAnonymous: authUser.isAnonymous,
        photoUrl: authUser.photoURL,
        lastSignInTime: authUser.metadata.lastSignInTime,
      );
    }
    return user;
  }

  /// Creates a stream of all firebase_auth User changes.
  Stream<User> get user {
    log.i('get user');

    return _auth.userChanges().map(_userFromFirebaseUser);
  }

  /// Provides current authenticated User data.
  User currentAuthenticatedUser() {
    log.i('currentAuthenticatedUser');

    auth.User firebaseUser = _auth.currentUser;
    User authenticatedUser = _userFromFirebaseUser(firebaseUser);
    return authenticatedUser;
  }

  /// Updates Firebase_auth User profile data.
  Future<void> updateUserAuthProfile({
    String displayName,
    String photoUrl,
  }) async {
    log.i(
        'updateUserAuthProfile | displayName: $displayName, photoUrl: $photoUrl ');
    try {
      auth.User currentUser = _auth.currentUser;

      String newDisplayName = displayName ?? currentUser.displayName;
      String newPhotoUrl = photoUrl ?? currentUser.photoURL;

      await currentUser.updateProfile(
          displayName: newDisplayName, photoURL: newPhotoUrl);
      log.d('Done updating auth userprofile');
    } catch (error) {
      log.e('error updating user auth profile');
      throw error;
    }
  }

  /// Change users current phone number.
  ///
  /// Will ask the User to re-verify its current phone number before proceeding.
  Future<bool> changePhoneNumber({
    @required String currentPhoneNumber,
    @required String newPhoneNumber,
    @required BuildContext ctx,
    @required DeviceLocation deviceLocation,
  }) async {
    log.i(
        'changePhoneNumber | context: $ctx, current phone: $currentPhoneNumber, new phone number: $newPhoneNumber');

    log.d('getting current user');

    log.d('current user is: ${_auth.currentUser}');
    bool changeComplete = false;
    try {
      log.d('verifying that new number is != the current number');
      // Check that the new phone number is not the same as the registered number.
      if (_auth.currentUser.phoneNumber != newPhoneNumber &&
          _auth.currentUser.phoneNumber == currentPhoneNumber) {
        bool _isDenied =
            false; // Asume that the use has allowed SMS permissions.
        log.d('checking sms permissions');
        var smsPermission = await Permission
            .sms.status; // Verify that the user has given SMS permissions.
        log.d('sms permission is: $smsPermission');

        if (smsPermission == PermissionStatus.granted) {
          log.d('getting sms messages');
          await _reaper.getAllSms();
        } else {
          log.d('SMS permission not granted');
          _isDenied = true; // User has denied SMS permissions.
        }
        log.d('verifying current phone number');
        // Verify that the user still has access to the phone number by re-verifying the number.
        await _auth.verifyPhoneNumber(
            phoneNumber: _auth.currentUser
                .phoneNumber, //TODO: should i use the number entered by user here of is this fine?
            timeout: _autoVerificationTimeout,
            verificationCompleted: (auth.AuthCredential _credential) {
              if (!_isDenied) {
                // Only auto verify if user has given SMS permissions.
                _onAutoVerifyCurrentNumberCompleted(
                  authCredential: _credential,
                  ctx: ctx,
                  newPhoneNumber: newPhoneNumber,
                  denied: _isDenied,
                );
              }
            },
            verificationFailed: (auth.FirebaseAuthException authException) {
              log.e(
                  'verification failed while attempting to change phone number: ${authException.message}');
              _changeNumberCompleter.completeError(authException);
            },
            codeSent: (String verificationId, [int forceResendingToken]) {
              // Show dialog to take input from the user.

              _onCurrentNumberCodeSent(
                  verificationId, ctx, newPhoneNumber, _isDenied);
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              verificationId = verificationId;
              log.d(verificationId);
              log.d("Timout");
            });

        auth.User _authenticatedUser = await _changeNumberCompleter.future;
        if (_authenticatedUser != null) {
          final User dbUser = User(
            uid: _authenticatedUser.uid,
            phone: _authenticatedUser.phoneNumber,
            displayName: _authenticatedUser.displayName,
            email: _authenticatedUser.email,
            isAnonymous: _authenticatedUser.isAnonymous,
            creationTime: _authenticatedUser.metadata.creationTime,
            lastSignInTime: _authenticatedUser.metadata.lastSignInTime,
            lastKnownLocation: deviceLocation,
          );
          await _databaseService.updateUser(user: dbUser).then((_) {
            _analyticsService.logCustomEvent(
                name: 'changed_phone_number',
                parameters: {'number': dbUser.phone});
            changeComplete = true;
            _navigationService.pop(true); // Discard any open dialog.
            log.d('done poping, now navigating');

            _changeNumberCompleter = Completer(); // Reset completer;
          });

          log.d('about to return');
          return changeComplete;
        } else {
          changeComplete = false;
          log.d('user cancelled verification');
          _changeNumberCompleter = Completer(); // Reset completer;
          return changeComplete;
        }
      } else {
        changeComplete = false;
        log.d('Phone numbers entered are the same.');

        throw ScaffoldException(
            code: 'phone-number-mismatch',
            message:
                'There is a mismatch in the phone numbers entered by the user.');
      }
    } catch (error) {
      log.e('changePhoneNumber | Error: $error');
      changeComplete = false;
      _onVerificationFailed(
        authException: error,
        context: ctx,
      );

      _changeNumberCompleter = Completer(); // Reset completer;
      return changeComplete;
    }
  }

  /// Signup or login using phone number.
  Future<void> phoneLogin({
    @required String phoneNumber,
    @required BuildContext ctx,
    @required DeviceLocation deviceLocation,
  }) async {
    log.i('phoneLogin | phoneNumber: $phoneNumber, context: $ctx,');

    try {
      _auth.setLanguageCode(Platform.localeName).catchError((onError) {
        log.e(
            'Language not set. Defaulting to English. | error: ${onError.code}');
      });
      bool _isDenied = false;
      var smsPermission =
          await Permission.sms.status; // Check the SMS permission status
      log.d('sms permission is: $smsPermission');
      if (smsPermission == PermissionStatus.granted) {
        log.d('SMS permisions granted');
        await _reaper.getAllSms(); // Read SMS if Permission granted.
      } else {
        _isDenied = true; // SMS permission has been denied by user.
      }
      await _auth.verifyPhoneNumber(
        // Authenticate using firebase auth.
        phoneNumber: phoneNumber,
        timeout: _autoVerificationTimeout,
        verificationCompleted: (auth.AuthCredential authCredential) {
          // Auto verify credentials.
          _onLoginAutoVerify(
            credential: authCredential,
            smsReadDenied: _isDenied,
          );
        },
        verificationFailed: (auth.FirebaseAuthException authException) {
          // Verification has failed.
          log.e('Verification failed: $authException');

          _loginCompleter.completeError(authException);
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          // Logic handling the code entered by the user.
          _onLoginCodeSent(
            verificationId,
            ctx,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Logic handling auto-rerieval timeout.
          verificationId = verificationId;
          log.d(verificationId);
          log.d("Timout");
        },
      );

      // Wait for firebaseAuth do finish authenticating.
      final auth.User _authUser = await _loginCompleter.future;

      if (_authUser != null) {
        String _countryCode = _sharedPrefsHelper.countryCode;
        _navigationService.replaceWith('/tab-screen');
        bool _exist = false;
        _databaseService.usersCollection.doc(_authUser.uid).get().then((value) {
          _exist = value.exists; // Check if the user already exist in db

          // Create a local user.
          User _dbUser = User(
            uid: _authUser.uid,
            displayName: _authUser.displayName,
            email: _authUser.email,
            phone: _authUser.phoneNumber,
            isAnonymous: _authUser.isAnonymous,
            creationTime: _authUser.metadata.creationTime,
            lastSignInTime: _authUser.metadata.lastSignInTime,
            lastKnownLocation: deviceLocation ??
                DeviceLocation(
                  latitude: (value.exists &&
                          value.data()['lastKnownLocation'] != null)
                      ? value.data()['lastKnownLocation']['geopoint'].latitude
                      : _isoCodes.isoLocation[_countryCode].latitude,
                  longitude: (value.exists &&
                          value.data()['lastKnownLocation'] != null)
                      ? value.data()['lastKnownLocation']['geopoint'].longitude
                      : _isoCodes.isoLocation[_countryCode].longitude,
                  accuracy: 0.0,
                  timestamp: DateTime.now(),
                ),
          );

          if (!_exist) {
            // create user if does not exist
            log.d('User does not exist');
            _databaseService
                .addUser(
              user: _dbUser,
            )
                .whenComplete(() {
              _analyticsService.onSignUp(
                  user: _dbUser); // send logs to analytics about user sign-up
              _loginCompleter = Completer(); // Reset completer;
            });
          } else {
            // User already exist.
            log.d('User already exist. signing in.');

            _databaseService.updateUser(user: _dbUser); // Update the user data.
            // Fetch saved user settings in db.
            _databaseService
                .fetchSettings(user: _dbUser)
                .then((AppSettings userSettings) {
              // re-subscribe to the previously saved notifications
              _databaseService
                  .resubscribeToSavedTopics(
                      uid: _authUser.uid, userSettings: userSettings)
                  .whenComplete(() {
                _analyticsService.onLogin(
                    user: _dbUser); // send log to analytics about user login
                _loginCompleter = Completer(); // Reset completer;
              });
            });
          }
        });
      } else {
        log.d('user cancelled verification');
        _loginCompleter = Completer(); // Reset completer;
      }
    } catch (e) {
      log.e('phoneLogin | PhoneNumber: $phoneNumber; error code: ${e.code}');
      _onVerificationFailed(
        authException: e,
        context: ctx,
      );
      _loginCompleter = Completer(); // Reset completer;
    }
  }

  /// Anonymous Login
  ///
  /// Allow a user to login anonymously to the app
  Future anonLogin() async {
    log.i('anonLogin');
    try {
      await _auth.signInAnonymously();
      
    } catch (error) {
      log.e('error with anonymous login: $error');
      _onVerificationFailed(authException: error);
    }
  }

  /// SignOut
  ///
  /// This will not delete any user information.
  Future signOut() async {
    log.i('signOut');
    try {
      await _analyticsService.logCustomEvent(name: 'logout');
      await _auth.signOut();
    } catch (error) {
      log.e('error signing out: $error');
      throw error;
    }
  }

  /// Close Account
  ///
  /// Delete all firebase_auth user data.
  Future closeAcount({
    @required BuildContext ctx,
  }) async {
    log.i('closeAcount | context: $ctx');
    try {
      log.d('check sms permission status');
      var smsPermission =
          await Permission.sms.status; // Check if user granted SMS permissions.
      log.d('sms Permission is: $smsPermission');

      bool _isDenied = false;
      if (smsPermission == PermissionStatus.granted) {
        log.d('getting SMS messages');
        await _reaper.getAllSms(); // Read SMS to fetch code.
      } else {
        //SMS permission was denied by user.
        log.w('get permission if !permanatly denied');
        // TODO: ask permission if !permanatly denied
        _isDenied = true;
      }

      log.d('getting current user');

      log.d('current user UID is: ${_auth.currentUser.uid}');

      // reauthenticate user before closing account.
      log.d('verifying phone number');
      _auth.verifyPhoneNumber(
          phoneNumber: _auth.currentUser.phoneNumber,
          timeout: _autoVerificationTimeout,
          verificationCompleted: (auth.AuthCredential _credential) {
            _onCloseAccountAutoVerificationCompleted(
              authCredential: _credential,
              denied: _isDenied,
            );
          },
          verificationFailed: (auth.FirebaseAuthException authException) {
            log.e(
                'phone number verification failed during account closure: ${authException.code}');

            _closeAccountCompleter.completeError(authException);
          },
          codeSent: (String verificationId, [int forceResendingToken]) {
            // Manually verify account using code sent to user.
            _onCloseAccountCodeSent(verificationId, ctx);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
          });

      auth.User authUser = await _closeAccountCompleter.future;

      if (authUser != null) {
        await _analyticsService.logCustomEvent(
          name: 'delete_account',
          parameters: {'number': authUser.phoneNumber},
        );
        await authUser.delete(); // Delete firebase_auth user data permanatly.
        //TODO: Show delete confirmation to user.

        log.d('User account deleted.');
        _closeAccountCompleter = Completer();
        _navigationService
            .removeUntil('/'); // navigate to home screen after account closure.
      } else {
        log.d('user cancelled verification');
        await _analyticsService.logCustomEvent(
          name: 'cancel_delete_account',
        );
        _closeAccountCompleter = Completer();
      }
    } catch (error) {
      log.e('closeAcount | Error: $error');
      _onVerificationFailed(
        authException: error,
        context: ctx,
      );
      _closeAccountCompleter = Completer();
    }
  }

  /// Automatically authenticate phone number during login.
  ///
  /// Create a new user or login existing user after successful authentication.
  /// Requires SMS permissions to auto verify phone number.
  /// Auto verify only works for android phones.
  /// Show error dialog on authentication error.
  void _onLoginAutoVerify({
    auth.AuthCredential credential,
    bool smsReadDenied,
  }) async {
    // Automatically verify the user with the sms they receive.
    log.i(
        '_onLoginAutoVerify | authCredential: $credential, smsReadDenied: $smsReadDenied');
    if (!smsReadDenied) {
      // Sign-in using firebase_auth.
      _auth.signInWithCredential(credential).then((auth.UserCredential result) {
        if (result != null) {
          _loginCompleter.complete(result.user);
          // Once user credentials has been verified, discard the verification prompt dialog.
          _navigationService.pop();
        }
      }).catchError((e) {
        // error during phone number verification will be caught here.
        log.e('_onLoginAutoVerify | error: ${e.code}');

        _loginCompleter.completeError(e);
      });
    } else {
      //SMS permission was denied by user. Function is not executed.
      log.d('sms permission was denied. did not read sms');
      return;
    }
  }

  /// Automatically reauthenticate phone number before closing account.
  ///
  /// Deletes user firebase_auth data after successful authentication.
  /// Requires SMS permissions to auto verify phone number.
  /// Auto verify only works for android phones.
  /// Show error dialog on authentication error.
  void _onCloseAccountAutoVerificationCompleted({
    auth.AuthCredential authCredential,
    bool denied,
  }) {
    log.i(
        '_onCloseAccountAutoVerificationCompleted | credential: $authCredential, denied: $denied');

    if (!denied) {
      // SMS permission has been granted by user.
      _auth.currentUser
          .reauthenticateWithCredential(authCredential)
          .then((result) {
        log.d('reauth successfull. Deleting user data.');
        if (result != null) {
          _closeAccountCompleter.complete(result.user);
        }
      }).catchError((e) async {
        log.e('_onCloseAccountAutoVerificationCompleted | Error: ${e.code}');
        _closeAccountCompleter.completeError(e);
      });
    } else {
      // SMS permission was denied by user.
      log.d('permission denied. verification will not autocomplete');
      return; // Function does not execute.
    }
  }

  /// Automatically authenticate current phone number.
  ///
  /// Starts new number verification process after successful authentication.
  /// Requires SMS permissions to auto verify phone number.
  /// Auto verify only works for android phones.
  /// Show error dialog on authentication error.
  void _onAutoVerifyCurrentNumberCompleted({
    auth.AuthCredential authCredential,
    BuildContext ctx,
    @required String newPhoneNumber,
    bool denied,
  }) {
    log.i(
        '_onAutoVerifyCurrentNumberCompleted | credentials: $authCredential, context: $ctx, newPhoneNumber: $newPhoneNumber, denied: $denied ');
    // reauthenticate the current number.
    _auth.currentUser
        .reauthenticateWithCredential(authCredential)
        .then((result) {
      log.d('reauthenticated current phone number: with result: $result');
      if (result != null) {
        log.d('current number reauthenticated');
        log.d('popping current phone number verification dialog');
        _navigationService.pop(); // Discarding the current verification dialog.

        log.d('verifying new phone number');
        // verifying new phone number using firebase auth
        _auth.verifyPhoneNumber(
            phoneNumber: newPhoneNumber,
            timeout: _autoVerificationTimeout,
            verificationCompleted: (auth.AuthCredential _newCredential) {
              log.d('auto verification of current phone number completed');
              if (!denied) {
                // User has given SMS read premissions, proceed with auto verification.
                _onAutoVerifyNewNumberCompleted(
                  authCredential: _newCredential,
                  resultUser: result.user,
                );
              }
            },
            verificationFailed: (auth.FirebaseAuthException authException) {
              // error thrown when the new phone number has failed to verify.
              log.e(
                  'Error auto-verifying new phone number: ${authException.message}');
              _changeNumberCompleter.completeError(authException);
            },
            codeSent: (String verificationId, [int forceResendingToken]) {
              _onNewNumberCodeSent(verificationId, ctx, result.user);
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              verificationId = verificationId;
              log.d('New number verification timeout');
            });
      }
    }).catchError((e) async {
      log.e('_onAutoVerifyCurrentNumberCompleted | Error: ${e.code}');
      _changeNumberCompleter.completeError(e);
    });
  }

  /// Automatically authenticate new phone number.
  ///
  /// Updates user data after successful authentication.
  /// Requires SMS permissions to auto verify phone number.
  /// Auto verify only works for android phones.
  /// Show error dialog on authentication error.
  void _onAutoVerifyNewNumberCompleted({
    auth.AuthCredential authCredential,
    @required auth.User resultUser,
  }) {
    log.i('_onAutoVerifyNewNumberCompleted | credentials: $authCredential,');
    // Update firebase_auth user phonenumber.
    resultUser.updatePhoneNumber(authCredential).then((_) {
      log.d('credential update success');
      _changeNumberCompleter.complete(resultUser);
    }).catchError((e) {
      log.e('_onAutoVerifyNewNumberCompleted | Error: ${e.code}');
      _changeNumberCompleter.completeError(e);
    });
  }

  /// Delete account after succesful reauthentication
  ///
  /// Prompt user to manually enter the verification code.
  /// Delete user firebase_auth data.
  /// Shows error dialog if an error occured.
  void _onCloseAccountCodeSent(String verificationId, BuildContext ctx,
      [int forceResendingToken]) async {
    log.i(
        '_onCloseAccountcodeSent | verificationId: $verificationId, context: $ctx, forceResend: $forceResendingToken');
    auth.AuthCredential _credential;

    log.d('showing dialog to take input from the user');
    // Show prompt dialog to take user input.
    var promptResponse = await _dialogService.showTextInputDialog(
        title: I18n.of(ctx).dialogsSmsVerificationPromptCloseAccountTitle,
        description:
            I18n.of(ctx).dialogsSmsVerificationPromptCloseAccountMessage,
        confirmationTitle: I18n.of(ctx).buttonsDoneButton,
        cancelTitle: I18n.of(ctx).buttonsCancelButton,
        dialogType: 'phone_verification_prompt');

    log.d('smsCode inputed: ${promptResponse.fieldOne}');

    if (!promptResponse.confirmed ||
        promptResponse.fieldOne == null ||
        promptResponse.fieldOne.isEmpty) {
      // User has not entered a code.
      log.d('user canceled verification');

      _closeAccountCompleter.complete(null);
    } else {
      // Generate credentials from infor received by user.
      _credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: promptResponse.fieldOne);

      _auth.currentUser
          .reauthenticateWithCredential(_credential)
          .then((result) {
        if (result != null) {
          _closeAccountCompleter.complete(result.user);
        }
      }).catchError((e) async {
        log.e('_onCloseAccountCodeSent | Error: $e');

        _closeAccountCompleter.completeError(e);
      });
    }
  }

  /// Manually reauthenticate current phone number.
  ///
  /// Prompt user to manually enter the verification code.
  /// Reauthenticate user and start new number verification process.
  /// Shows error dialog if an error occured.
  void _onCurrentNumberCodeSent(String verificationId, BuildContext ctx,
      String newPhoneNumber, bool denied,
      [int forceResendingToken]) async {
    log.i(
        '_onCurrentNumberCodeSent | verificationId: $verificationId, context: $ctx, newPhoneNumber: $newPhoneNumber, denied: $denied, forceResend: $forceResendingToken');
    auth.AuthCredential _credential;
    // Display a promtp dialog to the user for code verification.
    var promptResponse = await _dialogService.showTextInputDialog(
        title: I18n.of(ctx).dialogsSmsVerificationPromptOldPhone,
        confirmationTitle: I18n.of(ctx).buttonsDoneButton,
        cancelTitle: I18n.of(ctx).buttonsCancelButton,
        dialogType: 'phone_verification_prompt');

    log.d('smsCode inputed: ${promptResponse.fieldOne}');

    if (!promptResponse.confirmed ||
        promptResponse.fieldOne == null ||
        promptResponse.fieldOne.isEmpty) {
      // user has not entered a code
      log.d('user canceled verification');

      _changeNumberCompleter.complete(null);
    } else {
      _credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: promptResponse
              .fieldOne); // Generate credentials used to authenticate phone number.

      _auth.currentUser
          .reauthenticateWithCredential(_credential)
          .then((result) {
        if (result != null) {
          log.d('current number reauthenticated');
          // Verify & authenticate new phone number.
          _auth.verifyPhoneNumber(
              phoneNumber: newPhoneNumber,
              timeout: _autoVerificationTimeout,
              verificationCompleted: (auth.AuthCredential _credential) {
                if (!denied) {
                  _onAutoVerifyNewNumberCompleted(
                      authCredential: _credential, resultUser: result.user);
                }
              },
              verificationFailed: (auth.FirebaseAuthException authException) {
                log.e(
                    'New phone number verification failed: ${authException.message}');
                _changeNumberCompleter.completeError(authException);
              },
              codeSent: (String verificationId, [int forceResendingToken]) {
                _onNewNumberCodeSent(verificationId, ctx, result.user);
              },
              codeAutoRetrievalTimeout: (String verificationId) {
                verificationId = verificationId;
              });
        }
      }).catchError((e) async {
        log.e('_onCurrentNumberCodeSent | Error: ${e.code}');
        _changeNumberCompleter.completeError(e);
      });
    }
  }

  /// Update user data after succesful verification.
  ///
  /// Prompt user to manually enter the verification code.
  /// Updates user data if authentication is successfull.
  /// Shows error dialog if an error occured.
  void _onNewNumberCodeSent(
      String verificationId, BuildContext ctx, auth.User resultUser,
      [int forceResendingToken]) async {
    log.i(
        '_onNewNumberCodeSent | verificationId: $verificationId, context: $ctx, resultUser: $resultUser, forceResend: $forceResendingToken');
    auth.AuthCredential _credential;

    var promptResponse = await _dialogService.showTextInputDialog(
        title: I18n.of(ctx).dialogsSmsVerificationPromptNewPhone,
        confirmationTitle: I18n.of(ctx).buttonsDoneButton,
        cancelTitle: I18n.of(ctx).buttonsCancelButton,
        dialogType: 'phone_verification_prompt');

    log.d('smsCode inputed: ${promptResponse.fieldOne}');
    if (!promptResponse.confirmed ||
        promptResponse.fieldOne == null ||
        promptResponse.fieldOne.isEmpty) {
      // user has not entered a code
      log.d('user canceled verification');
      _changeNumberCompleter.complete(null);
    } else {
      _credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: promptResponse
              .fieldOne); // Generate credentials using verification ID.

      resultUser.updatePhoneNumber(_credential).then((_) {
        log.d('credential update success');
        // Notify completer listeners.
        _changeNumberCompleter.complete(resultUser);
      }).catchError((e) {
        log.e('_onNewNumberCodeSent | Error: ${e.code}');
        _changeNumberCompleter.completeError(e);
      });
    }
  }

  /// Sign user in after successful authentication.
  ///
  /// Prompt user to manually enter the verification code.
  /// Sign user if authentication is successfull.
  /// Shows error dialog if an error occured.
  void _onLoginCodeSent(String verificationId, BuildContext ctx,
      [int forceResendingToken]) async {
    log.i(
        '_onLoginCodeSent | verificationId: $verificationId, context: $ctx, forceResendingToken: $forceResendingToken');
    auth.AuthCredential _credential;

    // Show a text input dialog so user can enter the verification code manually.
    var promptResponse = await _dialogService.showTextInputDialog(
        title: I18n.of(ctx).dialogsSmsVerificationPromptLogin,
        confirmationTitle: I18n.of(ctx).buttonsDoneButton,
        cancelTitle: I18n.of(ctx).buttonsCancelButton,
        dialogType: 'phone_verification_prompt');

    log.d('code entered by user: ${promptResponse.fieldOne}');

    if (!promptResponse.confirmed ||
        promptResponse.fieldOne == null ||
        promptResponse.fieldOne.isEmpty) {
      // User has not entered a code.
      log.d('user canceled verification');

      _loginCompleter.complete(null);
    } else {
      // User entered a valid code.
      log.d('user entered a valid code');
      _credential = auth.PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: promptResponse.fieldOne);
      log.d('credential created: $_credential');
      _auth
          .signInWithCredential(_credential)
          .then((auth.UserCredential result) {
        if (result != null) {
          // Sign the user in using the credentials from firebaseAuth

          _loginCompleter.complete(result.user);
        }
      }).catchError((e) {
        log.e('_onLoginCodeSent | error: ${e.code}');
        _loginCompleter.completeError(e);
      });
    }
  }

  /// Show error dialog when authenification has failed.
  void _onVerificationFailed({
    var authException,
    BuildContext context,
  }) async {
    log.i(
        '_onVerificationFailed | authException: $authException, context: $context');
    log.e('_onVerificationFailed | Error: ${authException.code}');
    String description = I18n.of(context).dialogsSmsVerificationError;
    switch (authException.code.toString()) {
      // Change the message shown to users based on the error code.
      case 'invalid-verification-code':
        description = I18n.of(context).dialogsSmsInvalidCode;
        break;
      case 'user-disabled':
        description = I18n.of(context).dialogsSmsUserDisabled;
        break;
      case 'invalid-credential':
        description = I18n.of(context).dialogsSmsInvalidCredentials;
        break;
      case 'user-not-found':
        description = I18n.of(context).dialogsSmsUserNotFound;
        break;
      case 'user-mismatch':
        description = I18n.of(context).dialogsSmsUserMismatch;
        break;
      case 'credential-already-in-use':
        description = I18n.of(context).dialogsSmsCredentialInUse;
        break;
      case 'invalid-phone-number':
        description = I18n.of(context).dialogsSmsInvalidPhoneNumber;
        break;
      case 'invalid-email':
        description = I18n.of(context).dialogsSmsInvalidEmail;
        break;
      case 'wrong-password':
        description = I18n.of(context).dialogsSmsWrongPassword;
        break;
      case 'invalid-verification-id':
        description = I18n.of(context).dialogsSmsInvalidCode;
        break;
      case 'email-already-in-use':
        description = I18n.of(context).dialogsSmsEmailInUse;
        break;
      case 'requires-recent-login':
        description = I18n.of(context).dialogsSmsRecentLoginRequired;
        break;
      case 'weak-password':
        description = I18n.of(context).dialogsSmsWeakPassword;
        break;
      case 'network-request-failed':
        description = I18n.of(context).dialogsSmsNetworkError;
        break;
      case 'phone-number-mismatch':
        description = I18n.of(context).dialogsSmsInvalidPhoneNumber;
        break;
      case 'operation-not-allowed':
        description = I18n.of(context).dialogsOperationNotAllowed;
        break;
      default:
        I18n.of(context).dialogsSmsVerificationError;
    }

    await _dialogService.showErrorDialog(
        title: I18n.of(context).dialogsSmsVerificationFailedPromptTitle,
        description: description,
        buttonTitle: I18n.of(context).buttonsOkayButton,
        dialogType: 'phone_auth_failed');
  }
}
