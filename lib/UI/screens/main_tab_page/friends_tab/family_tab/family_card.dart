import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_scaffold/models/contacts.dart';

import '../../../../../logger.dart';

final log = getLogger('FamilyCard');

class FamilyCard extends StatelessWidget {
  const FamilyCard({
    Key key,
    @required this.contact,
  }) : super(key: key);

  final UserContact contact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        // color: Colors.red.withOpacity(0.5),
        height: 100,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(15.0),
              // color: Colors.purpleAccent.withOpacity(0.5),
              // width: 50,
              child: contact.picture == null || contact.picture.isEmpty
                  ? CircleAvatar(
                      maxRadius: 35,
                      child: InkWell(
                        onTap: () {},
                      ),
                      backgroundImage:
                          AssetImage('assets/images/default_avatar.png'),
                    )
                  : CachedNetworkImage(
                      imageUrl: contact.picture,
                      imageBuilder: (context, imgProvider) => CircleAvatar(
                        maxRadius: 35,
                        // child: InkWell(
                        //   onTap: () {
                        //     _navigationService.replaceWith(
                        //         ProfileSettingsScreen.routeName);
                        //   },
                        // ),
                        backgroundImage: imgProvider,
                      ),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircleAvatar(
                        maxRadius: 35,
                        // child: InkWell(
                        //   onTap: () {
                        //     _navigationService.replaceWith(
                        //         ProfileSettingsScreen.routeName);
                        //   },
                        // ),
                        backgroundImage:
                            AssetImage('assets/images/default_avatar.png'),
                      ),
                      errorWidget: (context, url, error) {
                        log.e('Failed to load profile picture');
                        return CircleAvatar(
                          maxRadius: 35,
                          // child: InkWell(
                          //   onTap: () {
                          //     _navigationService.replaceWith(
                          //         ProfileSettingsScreen.routeName);
                          //   },
                          // ),
                          backgroundImage:
                              AssetImage('assets/images/default_avatar.png'),
                        );
                      },
                    ),
            ),
            Container(
              // color: Colors.limeAccent.withOpacity(0.5),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${contact.id}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(
                    'Battery: 70%\nStatus: ${contact.displayName}',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Text(
                    'Last known location: 5 min ago.',
                    style: Theme.of(context).textTheme.bodyText2,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
