//TODO: check user adress book and update db accordingly everytime the user opens community page



import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/widgets/empty_state.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


import '../../../base_view_screen.dart';

import 'family_tab/family_group_view.dart';

import '../../../../enums/view_state.dart';

import 'mdl_community_scr.dart';

import '../../../../logger.dart';

final log = getLogger('CommunityScreen');

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    log.i('building community screen');
    final mediaQuery = MediaQuery.of(context);

    return BaseView<CommunityScreenViewModel>(
      onModelReady: (model) {
        model.initializeModel();
      },
      // onModelDependencyChange: (model) {
      //   model.updateModel(context);
      // },
      // onModelUpdate: (model) {
      //   model.updateModel(context);
      // },
      builder: (context, model, child) {
        return model.state == ViewState.Busy
            ? Center(
                child: SpinKitCubeGrid(
                  color: Theme.of(context).accentColor,
                ),
              )
            : DefaultTabController(
                length: 2,
                // child:
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 8),
                // padding: kPaddingTabBar,
                child: Container(
                  // padding: EdgeInsets.only(top: 8,left: 8,right: 8,),
                  // decoration: BoxDecoration(
                  //   color: Colors.blue,
                  //   borderRadius: BorderRadius.all(
                  //     Radius.circular(50),
                  //   ),
                  // ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 8,
                          right: 8,
                        ),
                        child: TabBar(
                          tabs: model.tabsList,
                          // unselectedLabelColor: Colors.white,
                          // labelColor: Colors.black,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(50),
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            FamilyGroupView(
                              // contactsList: model.contactsList,
                              mediaQuery: mediaQuery,
                            ), //first tabBarView (Family page)
                            EmptyState(
                              icon: Icons.construction,
                              iconText: 'Comming soon',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
