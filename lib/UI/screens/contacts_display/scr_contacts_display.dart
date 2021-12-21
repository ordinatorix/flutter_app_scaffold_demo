import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/screens/contacts_display/contact_list_item.dart';
import 'package:flutter_scaffold/UI/widgets/empty_state.dart';
import 'package:flutter_scaffold/enums/view_state.dart';
import 'package:flutter_scaffold/UI/screens/contacts_display/mdl_contact_display.dart';
import 'package:flutter_scaffold/generated/i18n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../logger.dart';
import '../../base_view_screen.dart';

final log = getLogger('ContactsDisplayScreen');

class ContactsDisplayScreen extends StatelessWidget {
  static const routeName = '/contacts-display-screen';

  @override
  Widget build(BuildContext context) {
    return BaseView<ContactsDisplayViewModel>(
      onModelReady: (model) {
        model.initializeModel();
      },
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Contacts'),
          ),
          body: model.state == ViewState.Busy
              ? Center(
                  child: SpinKitCubeGrid(
                    color: Theme.of(context).accentColor,
                  ),
                )
              : model.contactList != null
                  ? Container(
                      margin: EdgeInsets.only(
                        top: 2,
                      ),
                      width: double.infinity,
                      // height: 255,
                      // color: Colors.pink,
                      child: ListView.builder(
                        itemBuilder: (ctx, index) => ContactListItem(
                          contact: model.contactList[index],
                          onSelectedMenuOption: model.onSelectedContactMenu,
                        ),
                        itemCount: model.contactList.length,
                      ),
                    )
                  : EmptyState(
                      icon: Icons.contacts_outlined,
                      iconText:
                          I18n.of(context).contactsDisplayScreenEmptyStateText,
                    ),
        );
      },
    );
  }
}
