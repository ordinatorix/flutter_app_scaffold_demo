import 'dart:async';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

import '../models/contacts.dart';

import '../logger.dart';

final log = getLogger('ContactService');

class ContactService {
  /// Converts Package contact object to App contact object.
  ///
  /// Extracts each phone number into a stand alone contact.
  Future<List<UserContact>> _userContactFromContact(
      List<Contact> contacts) async {
    log.i('_userContactFromContact | contacts: $contacts');
    List<UserContact> contactList = [];
    log.d('contact length before sorting: ${contacts.length}');
    contacts.forEach((element) {
      element.phones.forEach((phoneNumber) {
        List<Map> postalList = [];

        Map emails = iterableToMap(element.emails);
        Map phones = iterableToMap(element.phones);

        if (element.postalAddresses != null) {
          element.postalAddresses.forEach((element) {
            postalList.add({
              'label': element.label,
              'street': element.street,
              'city': element.city,
              'postalCode': element.postcode,
              'region': element.region,
              'country': element.country,
            });
          });
        }

        UserContact userContact = UserContact(
          id: phoneNumber.value,
          displayName: element.displayName,
          givenName: element.givenName,
          middleName: element.middleName,
          familyName: element.familyName,
          prefix: element.prefix,
          suffix: element.suffix,
          emails: emails,
          phones: phones,
          // element.phones != null
          //     ? Map.fromIterable(element.phones,
          //         key: (v) {
          //           String defaultPhoneLabel = 'Home';
          //           v.label.toString().isNotEmpty
          //               ? defaultPhoneLabel = v.label
          //               : defaultPhoneLabel = 'Home';
          //           return defaultPhoneLabel;
          //         },
          //         value: (v) => v.value)
          //     : null,
          jobTitle: element.jobTitle,
          postalAddresses: postalList,
          avatar: element.avatar,
        );
        contactList.add(userContact);
      });
    });

    return contactList;
  }

  /// Convert iterable to map
  Map iterableToMap(Iterable inputIterable) {
    log.i('iterableToMap | inputIterable: $inputIterable');
    Map newMap;
    return inputIterable != null
        ? newMap = Map.fromIterable(inputIterable,
            key: (k) {
              String defaultEmailLabel = 'Home';
              k.label.toString().isNotEmpty
                  ? defaultEmailLabel = k.label
                  : defaultEmailLabel = 'Home';
              return defaultEmailLabel;
            },
            value: (v) => v.value)
        : newMap;
  }

  /// Convert a map to an iterable
  Iterable mapToIterable(Map inputMap) {
    log.i('mapToIterable | inputMap: $inputMap');
    return inputMap.entries
        .map((entry) => Item(label: entry.key, value: entry.value))
        .toList();
  }

  /// Creates a Contact object for use with the contacts package.
  Contact contactFromUserContact(UserContact userContact) {
    log.i('contactFromUserContact | userContact: $userContact');
    Iterable<Item> userContactEmail = mapToIterable(userContact.emails);
    Iterable<Item> userContactPhones = mapToIterable(userContact.phones);
    final Contact contact = Contact(
      displayName: userContact.displayName ?? null,
      givenName: userContact.givenName ?? null,
      familyName: userContact.familyName ?? null,
      middleName: userContact.middleName ?? null,
      prefix: userContact.prefix ?? null,
      suffix: userContact.suffix ?? null,
      company: userContact.company ?? null,
      jobTitle: userContact.jobTitle ?? null,
      avatar: userContact.avatar,
      birthday: userContact.birthday ?? null,
      androidAccountName: userContact.androidAccountName ?? null,
      emails: userContactEmail,
      phones: userContactPhones,
    );

    return contact;
  }

  /// Check Permissions.
  Future<PermissionStatus> _checkContactPermission() async {
    log.i('_checkContactPermission');
    PermissionStatus finalStatus;
    Completer<PermissionStatus> permissionCompleter = Completer();
    Permission.contacts.status.then((status) {
      if (status == PermissionStatus.granted) {
        permissionCompleter.complete(status);
      } else if (status == PermissionStatus.permanentlyDenied) {
        log.w('permissions permanetly denied');
        finalStatus = status;
        permissionCompleter.complete(status);
        //TODO: show dialog to go to settings
      } else {
        Permission.contacts
            .request()
            .then((value) => permissionCompleter.complete(value));
      }
    });

    finalStatus = await permissionCompleter.future;

    return finalStatus;
  }

  /// Get all contacts on device
  Future<List> getAllContacts() async {
    log.i('getAllContacts');
    List userContactList;
    PermissionStatus status = await _checkContactPermission();
    log.d('status is: $status');
    if (status == PermissionStatus.granted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      log.d('contacts are: $contacts');
      userContactList = await _userContactFromContact(contacts.toList());
    }

    return userContactList;
  }

  /// Get all contacts without thumbnail (faster)
  Future<List> getAllContactsNoThumbnail() async {
    log.i('getAllContactsNoThumbnail');
    Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    List userContactList = await _userContactFromContact(contacts.toList());
    print('done');
    return userContactList;
  }

  /// Android only: Get thumbnail for an avatar afterwards (only necessary if `withThumbnails: false` is used)
  Future<Uint8List> getThumbnailForSpecificContact(
      UserContact userContact) async {
    log.i('getThumbnailForSpecificContact | userContact: $userContact');
    Contact contact = contactFromUserContact(userContact);
    Uint8List avatar = await ContactsService.getAvatar(contact);

    return avatar;
  }

  /// Query contact by name
  Future<List> queryContactByName(String contactName) async {
    log.i('queryContactByName | contactName: $contactName');
    Iterable<Contact> contacts =
        await ContactsService.getContacts(query: contactName);
    return contacts.toList();
  }

  /// Add a contact
  ///
  /// The contact must have a firstName / lastName to be successfully added
  void addContact(UserContact userContact) async {
    log.i('addContact | userContact: $userContact');
    Contact contactToAdd = contactFromUserContact(userContact);
    await ContactsService.addContact(contactToAdd);
  }

  /// Delete a contact
  ///
  /// The contact must have a valid identifier
  void deleteContact(UserContact userContact) async {
    log.i('deleteContact | userContact: $userContact');
    Contact contactToDelete = contactFromUserContact(userContact);
    await ContactsService.deleteContact(contactToDelete);
  }

  /// Update a contact
  ///
  /// The contact must have a valid identifier
  void updateContact(UserContact userContact) async {
    log.i('updateContact | userContact: $userContact');
    Contact contactToUpdate = contactFromUserContact(userContact);
    await ContactsService.updateContact(contactToUpdate);
  }

  /// Usage of the native device form for creating a Contact
  ///
  /// Throws a error if the Form could not be open or the Operation is canceled by the User
  void createContactUsingNativeForm() async {
    log.i('createContactUsingNativeForm');
    await ContactsService.openContactForm();
  }

  /// Usage of the native device form for editing a Contact
  ///
  /// The contact must have a valid identifier
  /// Throws an error if the Form could not be open or the Operation is canceled by the User
  void updateContactUsingNativeForm(UserContact userContact) async {
    log.i('updateContactUsingNativeForm | userContact: $userContact');
    Contact contact = contactFromUserContact(userContact);
    await ContactsService.openExistingContact(contact);
  }
}
