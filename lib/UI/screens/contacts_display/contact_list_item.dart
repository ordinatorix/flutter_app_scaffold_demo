import 'package:flutter/material.dart';

import 'dart:ui';

import '../../../models/contacts.dart';

import '../../../enums/contact_menu_option.dart';

import '../../../logger.dart';

final log = getLogger('CommunityListItem');

class ContactListItem extends StatelessWidget {
  final UserContact contact;
  final Function onSelectedMenuOption;

  ContactListItem({
    @required this.contact,
    @required this.onSelectedMenuOption,
  });

  @override
  Widget build(BuildContext context) {
    log.i('building community List');
    // final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: contact.avatar.isEmpty
            ? CircleAvatar(
                maxRadius: 35,
                backgroundImage: AssetImage('assets/images/default_avatar.png'),
              )
            : CircleAvatar(
                maxRadius: 35,
                backgroundImage: MemoryImage(contact.avatar),
              ),
        title: Text(
          '${contact.displayName}',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        subtitle: Text(
          '${contact.id}',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        trailing: PopupMenuButton(
          icon: Icon(
            Icons.more,
            color: Colors.white,
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            const PopupMenuItem<ContactMenuOption>(
              value: ContactMenuOption.Update,
              child: const Text('Request Location Update'),
            ),
            const PopupMenuItem<ContactMenuOption>(
              value: ContactMenuOption.Emergency,
              child: const Text('Add to Emergency group'),
            ),
            const PopupMenuItem<ContactMenuOption>(
              value: ContactMenuOption.Family,
              child: const Text('Add to family group'),
            ),
          ],
          onSelected: (option) => onSelectedMenuOption(option, contact),
        ),
      ),
    );
  }
}
