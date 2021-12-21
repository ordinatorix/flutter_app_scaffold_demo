import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/widgets/empty_state.dart';
import 'package:flutter_scaffold/enums/view_state.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/friends_tab/family_tab/mdl_family_group.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../base_view_screen.dart';
import 'family_card.dart';

import '../../../../../logger.dart';

final log = getLogger('FamilyGroupView');

class FamilyGroupView extends StatelessWidget {
  const FamilyGroupView({
    Key key,
    @required this.mediaQuery,
    // @required this.contactsList,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  // final List<UserContact> contactsList;

  @override
  Widget build(BuildContext context) {
    return BaseView<FamilyGroupViewModel>(
      onModelReady: (model) {
        model.initializeModel();
      },
      onModelDependencyChange: (model) {
        model.updateWidget(context);
      },
      onModelUpdate: (model) {
        model.updateWidget(context);
      },
      builder: (context, model, child) {
        return model.state == ViewState.Busy
            ? Center(
                child: SpinKitCubeGrid(
                  color: Theme.of(context).accentColor,
                ),
              )
            : Stack(
                children: [
                  Container(
                    // color: Colors.lightBlueAccent,
                    margin: EdgeInsets.only(
                      top: mediaQuery.size.height * 0.02,
                    ),
                    width: double.infinity,
                    // height: mediaQuery.size.height * 0.55,
                    // color: Colors.pink,
                    child: model.loadedFamily != null &&
                            model.loadedFamily.isNotEmpty
                        ? ListView.builder(
                            itemBuilder: (ctx, index) => FamilyCard(
                              contact: model.loadedFamily[index],
                            ),
                            itemCount: model.loadedFamily.length,
                          )
                        : EmptyState(
                            icon: Icons.person_search,
                            iconText:
                                'You have not added any contact to your family group.'), // TODO: translate //TODO: change this view to a wireframe view of loading ccontact cards
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: FloatingActionButton(
                      child: Icon(Icons.person_add),
                      onPressed: () {
                        model.showContactsList();
                        // TODO: navigated to contacts list page.
                      },
                    ),
                  )
                ],
              );
      },
    );
  }
}
