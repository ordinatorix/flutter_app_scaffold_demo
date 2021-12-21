
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../generated/i18n.dart';
import '../../../models/post.dart';
import '../../../logger.dart';
import '../../widgets/empty_state.dart';

final log = getLogger('PostEditScreenLoader');

class PostEditScreenLoader extends StatelessWidget {
  final MediaQueryData mediaQuery;
  final UploadProgress uploadProgress;
  final bool showEmptyState;

  PostEditScreenLoader({
    @required this.mediaQuery,
    @required this.uploadProgress,
    @required this.showEmptyState,
  });

  @override
  Widget build(BuildContext context) {
    
    log.d('building screen');
    Widget loader;
    if (showEmptyState) {
      log.d('showing empty state');
      loader = EmptyState(
        icon: Icons.location_disabled_rounded,
        iconText: I18n.of(context).emptyStateLocationNotFound,
        descriptionText: I18n.of(context).emptyStateEnableLocationText,
        showButton: true,
        buttonText: I18n.of(context).dialogsLocationPromptGoToSettings,
        // buttonHandler: AppSettings.openLocationSettings(),
      );
    } else if ((uploadProgress == null || uploadProgress.progress == null)) {
      log.d('showing spinkit');
      loader = SpinKitCubeGrid(
        color: Theme.of(context).accentColor,
      );
    } else {
      log.d('showing media uploader');
      loader = Container(
        // color: Colors.purple,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: mediaQuery.size.height * 0.2,
                  width: mediaQuery.size.height * 0.2,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blueGrey[200],
                    value: uploadProgress.progress,
                  ),
                ),
                Text('${(uploadProgress.progress * 100).roundToDouble()}%'),
              ],
              alignment: Alignment.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ),
              child: Text(
                I18n.of(context).postEditScreenUploadText(
                    uploadProgress.mediaType,
                    '${uploadProgress.currentIndex + 1}',
                    '${uploadProgress.listLength}'),
              ),
            ),
          ],
        ),
      );
    }
    return loader;
  }
}
