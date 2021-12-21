import 'package:flutter_scaffold/enums/contact_menu_option.dart';
import 'package:flutter_scaffold/enums/view_state.dart';
import 'package:flutter_scaffold/locator.dart';
import 'package:flutter_scaffold/logger.dart';
import 'package:flutter_scaffold/models/contacts.dart';
import 'package:flutter_scaffold/models/user.dart';
import 'package:flutter_scaffold/services/authentication_service.dart';
import 'package:flutter_scaffold/services/contacts_service.dart';
import 'package:flutter_scaffold/services/database_service.dart';
import 'package:flutter_scaffold/UI/base_model.dart';


final log = getLogger('ContactsDisplayViewModel');

class ContactsDisplayViewModel extends BaseModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final AuthService _authService = locator<AuthService>();
  final ContactService _contactService = locator<ContactService>();
  List<UserContact> familyList = [];
  User _authUser;
  List contactList = [];

  void initializeModel() async {
    log.i('initializeModel');
    setState(ViewState.Busy);
    _authUser = _authService.currentAuthenticatedUser();
    log.d('uid: ${_authUser.uid}');
    await _getContacts();

    setState(ViewState.Idle);
  }

  Future<List<UserContact>> _getContacts() async {
    log.i('_getContacts');

    contactList = await _contactService.getAllContacts();

    log.d('length of contacts list to be uploaded: ${contactList.length}');
    _databaseService.addToContacts(
      uid: _authUser.uid,
      userContacts: contactList,
    );
    return contactList;
  }

  void onSelectedContactMenu(ContactMenuOption option, UserContact contact) {
    log.i('onSelectedContactMenu | option: $option, contact: $contact');
    switch (option) {
      case ContactMenuOption.Update:
        log.d('request to update location');
        setState(ViewState.Idle);

        break;
      case ContactMenuOption.Emergency:
        log.d('added to emergency contacts');
        setState(ViewState.Idle);

        break;
      case ContactMenuOption.Family:
        contact.inGroup = true;
        familyList.add(contact);
        log.d('added to family contacts');
        log.d('family contacts list: $familyList');
        _addToFamilyGroup();
        setState(ViewState.Idle);

        break;
      default:
        log.w('default case reached');
    }
  }

  void _addToFamilyGroup() {
    log.i('_addToFamilyGroup');
    if (familyList.isNotEmpty) {
      log.d('adding to family group');
      _databaseService.addContactToGroup(
          uid: _authUser.uid, userContacts: familyList);
    }
  }
}
