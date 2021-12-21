// TODO: use consumer for device location
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';

import '../../../enums/view_state.dart';

import '../../../generated/i18n.dart';

import '../../../models/user.dart';

import '../../base_view_screen.dart';

import 'mdl_change_username.dart';

final log = getLogger('ChangeUsernameScreen');

class ChangeUsernameScreen extends StatelessWidget {
  final User authUser;
  ChangeUsernameScreen({@required this.authUser});

  @override
  Widget build(BuildContext context) {
    return BaseView<ChangeUsernameModel>(
      onModelDisposing: (model) {
        model.disposer();
      },
      onModelDependencyChange: (model) {
        model.userList = Provider.of<List<User>>(context);
        model.deviceLocation = Provider.of<DeviceLocation>(context);
      },
      onModelUpdate: (model) {
        model.userList = Provider.of<List<User>>(context);
        model.deviceLocation = Provider.of<DeviceLocation>(context);
        model.updateUserList(authUser.uid);
      },
      onModelReady: (model) {
        model.initializeModel(authUser);
      },
      builder: (context, model, child) {
        log.d(model.userList);
        return (model.userList.isEmpty || model.userList == null)
            ? Center(
                child: SpinKitCubeGrid(
                  color: Theme.of(context).accentColor,
                ),
              )
            : Stack(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Form(
                    key: model.form,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: model.editedUser.displayName,
                              decoration: InputDecoration(
                                  labelText: I18n.of(context)
                                      .changeUsernameScreenTextFieldLabel),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                model.saveForm(ctx: context);
                              },
                              focusNode: model.usernameFocusNode,
                              keyboardType: TextInputType.text,
                              validator: (value) =>
                                  model.formValidator(value, context),
                              onSaved: (value) {
                                model.editedUser = User(
                                  uid: model.editedUser.uid,
                                  fullName: model.editedUser.fullName,
                                  phone: model.editedUser.phone,
                                  email: model.editedUser.email,
                                  displayName: value,
                                  photoUrl: model.editedUser.photoUrl,
                                  lastKnownLocation: model.deviceLocation ??
                                      model.editedUser.lastKnownLocation,
                                  lastSignInTime: authUser.lastSignInTime,
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              model.saveForm(ctx: context);
                            },
                            child: Text(
                              I18n.of(context).buttonsUpdateAccountButton,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                model.state == ViewState.Busy
                    ? Container(
                        color: Colors.black45,
                        child: Center(
                          child: SpinKitCubeGrid(
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      )
                    : SizedBox(),
              ]);
      },
    );
  }
}
