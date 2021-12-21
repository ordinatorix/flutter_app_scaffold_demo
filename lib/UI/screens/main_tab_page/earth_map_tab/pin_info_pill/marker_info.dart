import 'package:flutter/material.dart';
import 'package:flutter_scaffold/UI/widgets/date_formater/date_formater.dart';
import 'package:flutter_scaffold/logger.dart';
import 'package:flutter_scaffold/models/post.dart' show PinInformation;

final log = getLogger('MarkerInfo');

class MarkerInfo extends StatelessWidget {
  final PinInformation currentlySelectedPin;
  final Function markerTapHandler;
  final Function verifyTapHandler;
  // final Function commentTapHandler;
  MarkerInfo({
    @required this.currentlySelectedPin,
    @required this.markerTapHandler,
    @required this.verifyTapHandler,
    // @required this.commentTapHandler,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    log.i('building marker info');
    if (currentlySelectedPin.post != null) {
      log.d(currentlySelectedPin.post.id);
    } else {
      log.d('no post given');
    }

    return Stack(
      // overflow: Overflow.visible,
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          // color: Colors.green,
          height: mediaQuery.size.height * 0.3,
        ),
        InkWell(
          onTap: () {
            markerTapHandler();
          },
          child: Container(
            height: mediaQuery.size.height * 0.25,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  blurRadius: 20,
                  spreadRadius: 10,
                  offset: Offset(0, 3),
                  color: Colors.grey[900].withOpacity(0.6),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Pill Heading
                Container(
                  // color: Colors.red,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: 50,
                  height: 50,
                  child: Icon(
                    currentlySelectedPin.pinIcon,
                    size: 50,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                //body
                Expanded(
                  child: Container(
                    // color: Colors.blue,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Spacer(
                          flex: 4,
                        ),
                        // timestamp
                        DateFormater(
                          eventTimestamp:
                              currentlySelectedPin.postTimestamp ??
                                  DateTime.now(),
                          showDistance: false,
                        ),

                        Text(
                          currentlySelectedPin.postTitle,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Spacer(),
                        // address
                        Text(
                          '${currentlySelectedPin.address}',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                          overflow: TextOverflow.fade,
                        ),
                        Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: mediaQuery.size.height * 0.21,
          left: mediaQuery.size.width * 0.5,
          // height: 55,
          width: mediaQuery.size.width * 0.45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 60,
                width: 70,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[900].withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context).accentColor),
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(
                    Icons.comment,
                    size: 40,
                    color: Theme.of(context).dialogBackgroundColor,
                  ),
                  onPressed: () {
                    log.d('comment button pressed');
                  },
                ),
              ),
              Spacer(),
              (currentlySelectedPin.post != null &&
                      (currentlySelectedPin.post.status != 'Cleared' ||
                          currentlySelectedPin.post.status != 'Fake'))
                  ? Container(
                      height: 60,
                      width: 70,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[900].withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(25),
                        color: Theme.of(context).accentColor,
                      ),
                      child: IconButton(
                        onPressed: () {
                          verifyTapHandler();
                        },
                        color: Colors.red,
                        focusColor: Colors.green,
                        padding: EdgeInsets.all(0),
                        icon: currentlySelectedPin.post.status == 'Confirmed'
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).dialogBackgroundColor,
                              )
                            : Icon(
                                Icons.thumbs_up_down,
                                color: Theme.of(context).dialogBackgroundColor,
                                size: 40,
                              ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }
}
