import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:blobs/blobs.dart';

// import '../../generated/i18n.dart';
import '../../logger.dart';

final log = getLogger('EmptyState');

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String iconText;
  final String descriptionText;
  final bool showButton;
  final String buttonText;

  EmptyState({
    @required this.icon,
    @required this.iconText,
    this.descriptionText = '',
    this.showButton = false,
    this.buttonText,
  });
  @override
  Widget build(BuildContext context) {
    log.d('building widget');
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Spacer(
            flex: 2,
          ),
          Blob.animatedRandom(
            loop: true,
            size: 300,
            edgesCount: 19,
            minGrowth: 4,
            duration: Duration(seconds: 1),
            styles: BlobStyles(
              color: Theme.of(context).accentColor.withOpacity(0.4),
              fillType: BlobFillType.fill,
              strokeWidth: 3,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 90,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: descriptionText != ''
                        ? Text(
                            iconText,
                            style: Theme.of(context).textTheme.headline5,
                            textAlign: TextAlign.center,
                          )
                        : Text(''),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          Container(
            // color: Colors.blue,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(8.0),
            child: descriptionText != ''
                ? Text(
                    descriptionText ?? '',
                    textAlign: TextAlign.center,
                  )
                : Text(
                    iconText,
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
          ),
          if (showButton)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => AppSettings.openLocationSettings(),
                child: Text(
                  buttonText,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}
