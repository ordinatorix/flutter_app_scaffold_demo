import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base_view_screen.dart';

import '../../../enums/view_state.dart';

import '../../../models/user.dart';

import '../../../logger.dart';

import 'mdl_profile_image_input.dart';

final log = getLogger('ProfileImageInput');

class ProfileImageInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log.i('building profile image widget');

    final mediaQuery = MediaQuery.of(context);
    return BaseView<ProfileImageInputViewModel>(
      onModelDependencyChange: (model) {
        model.userList = Provider.of<List<User>>(context);
      },
      onModelUpdate: (model) {
        model.userList = Provider.of<List<User>>(context);
        model.initializeUser();
      },
      builder: (context, model, child) {
        return model.state == ViewState.Busy
            ? Center(child: CircularProgressIndicator())
            : Stack(
                // overflow: Overflow.visible,
                children: <Widget>[
                  model.storedImageFile != null
                      ? CircleAvatar(
                          backgroundColor: Theme.of(context).accentColor,
                          radius: (mediaQuery.size.height -
                                  mediaQuery.padding.top) *
                              0.13,
                          child: CircleAvatar(
                            maxRadius: (mediaQuery.size.height -
                                    mediaQuery.padding.top) *
                                0.1,
                            minRadius: (mediaQuery.size.height -
                                    mediaQuery.padding.top) *
                                0.1,
                            backgroundImage: FileImage(
                              model.storedImageFile,
                            ),
                          ),
                        )
                      : model.editedUser.photoUrl != null &&
                              model.editedUser.photoUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: model.editedUser.photoUrl,
                              imageBuilder: (context, imgProvider) =>
                                  CircleAvatar(
                                backgroundColor: Theme.of(context).accentColor,
                                radius: (mediaQuery.size.height -
                                        mediaQuery.padding.top) *
                                    0.13,
                                child: CircleAvatar(
                                    maxRadius: (mediaQuery.size.height -
                                            mediaQuery.padding.top) *
                                        0.1,
                                    minRadius: (mediaQuery.size.height -
                                            mediaQuery.padding.top) *
                                        0.1,
                                    backgroundImage: imgProvider),
                              ),
                              placeholder: (conext, url) => CircleAvatar(
                                backgroundColor: Theme.of(context).accentColor,
                                radius: (mediaQuery.size.height -
                                        mediaQuery.padding.top) *
                                    0.13,
                                child: CircleAvatar(
                                  maxRadius: (mediaQuery.size.height -
                                          mediaQuery.padding.top) *
                                      0.1,
                                  minRadius: (mediaQuery.size.height -
                                          mediaQuery.padding.top) *
                                      0.1,
                                  backgroundImage: const AssetImage(
                                      'assets/images/default_avatar.png'),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                log.e('error loading profile image from cache');
                                return CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  radius: (mediaQuery.size.height -
                                          mediaQuery.padding.top) *
                                      0.13,
                                  child: CircleAvatar(
                                    maxRadius: (mediaQuery.size.height -
                                            mediaQuery.padding.top) *
                                        0.1,
                                    minRadius: (mediaQuery.size.height -
                                            mediaQuery.padding.top) *
                                        0.1,
                                    backgroundImage: const AssetImage(
                                        'assets/images/default_avatar.png'),
                                  ),
                                );
                              },
                            )
                          : CircleAvatar(
                              backgroundColor: Theme.of(context).accentColor,
                              radius: (mediaQuery.size.height -
                                      mediaQuery.padding.top) *
                                  0.13,
                              child: CircleAvatar(
                                maxRadius: (mediaQuery.size.height -
                                        mediaQuery.padding.top) *
                                    0.1,
                                minRadius: (mediaQuery.size.height -
                                        mediaQuery.padding.top) *
                                    0.1,
                                backgroundImage: const AssetImage(
                                    'assets/images/default_avatar.png'),
                              ),
                            ),
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            offset: Offset(-3, -3),
                            blurRadius: 1,
                            spreadRadius: 1,
                          ),
                        ],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white70,
                          width: 3,
                        ),
                        color: Theme.of(context).accentColor,
                      ),
                      child: TextButton(
                          child: Icon(
                            Icons.edit,
                            color: Colors.black38,
                          ),
                          onPressed: () {
                            model.onEditPictureButtonPressed();
                          }),
                    ),
                    bottom: 5,
                    right: mediaQuery.size.width * -0.1, //-35,
                  ),
                ],
              );
      },
    );
  }
}
