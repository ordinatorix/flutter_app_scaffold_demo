import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/screens/main_tab_page/Filter_tab_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';

import '../../base_view_screen.dart';

import '../../widgets/main_drawer/main_drawer.dart';

import 'mdl_tab_screen.dart';

import '../../../models/user.dart';
import '../../../models/post.dart';

import '../../../generated/i18n.dart';



final log = getLogger('TabsScreen');

class TabsScreen extends StatelessWidget {
  static const routeName = '/tab-screen';

  @override
  Widget build(BuildContext context) {
    log.i('building tab screen');

    return BaseView<TabScreenViewModel>(
      onModelReady: (model) {
        model.args = ModalRoute.of(context).settings.arguments;

        model.initializeModel();
      },
      // onModelDependencyChange: (model) {
      //   log.wtf('change depen tab screen model: ${model.scaffoldKey.currentState}');
      //   model.args = ModalRoute.of(context).settings.arguments;

      //   // model.initializeModel(model.args);
      // },
      // onModelUpdate: (model) {
      //   log.wtf('updating tab screen model: ${model.scaffoldKey.currentState}');
      //   model.initializeModel(model.args);
      //   if (model.args != null) {
      //     model.showInSnackBar(model.args.snackbarMessage);
      //   }
      // },
      builder: (context, model, child) {
        model.postData = Provider.of<List<Post>>(context);
        model.authUser = Provider.of<User>(context);
        log.d('postdata tabscreen: ${model.postData}');
        model.reloadPost(context);

        return model.authUser != null
            ? MultiProvider(
                providers: [
                  StreamProvider<List<User>>.value(
                    initialData: [model.authUser],
                    value: model.databaseService.getUser(user: model.authUser),
                  ),
                ],
                child: WillPopScope(
                  onWillPop: () async {
                    bool popingResult = await model.onWillPop(context);
                    log.d('poping result: $popingResult');
                    return popingResult;
                  },
                  child: Scaffold(
                    key: model.scaffoldKey,
                    extendBodyBehindAppBar:
                        model.selectedPageIndex == 0 ? true : false,
                    appBar: AppBar(
                      iconTheme:
                          IconThemeData(color: Theme.of(context).accentColor),
                      backgroundColor: model.selectedPageIndex == 0
                          ? Colors.transparent
                          : null,
                      elevation: 0,
                      title: model.selectedPageIndex != 0
                          ? Text(
                              model.pages[model.selectedPageIndex]['title'],
                              style: Theme.of(context).textTheme.headline6,
                            )
                          : null,
                      actions: <Widget>[
                        model.selectedPageIndex != 2
                            ? FilterButton(
                                onTap: model.onFilterButtonTap,
                                displayValue: model.dropDownValue,
                              )
                            : const SizedBox(
                                width: 10,
                              )
                      ],
                    ),
                    drawer: MainDrawer(),
                    body: model.pages[model.selectedPageIndex]['page'],
                    bottomNavigationBar: BottomNavigationBar(
                      onTap: model.selectedPage,
                      selectedItemColor: Theme.of(context).accentColor,
                      currentIndex: model.selectedPageIndex,
                      backgroundColor: Theme.of(context).primaryColor,
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.near_me),
                          label: model.pages[0]['title'],
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.list),
                          label: model.pages[1]['title'],
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.group),
                          label: model.pages[2]['title'],
                        ),
                      ],
                    ),
                    floatingActionButton: model.selectedPageIndex != 2
                        ? FloatingActionButton(
                            tooltip: I18n.of(context).tabScreenFabToolTip,
                            onPressed: () {
                              model.onFloatingActionButtonTap();
                            },
                            child: const Icon(Icons.add),
                          )
                        : null,
                  ),
                ),
              )
            : SpinKitCubeGrid(
                color: Theme.of(context).accentColor,
              );
      },
    );
  }
}
