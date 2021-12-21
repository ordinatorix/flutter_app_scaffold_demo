import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CameraDisplay extends StatelessWidget {
  final bool ready;
  final CameraController control;
  final int timerCount;
  CameraDisplay({
    this.control,
    this.ready,
    this.timerCount,
  });

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    // String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
    // return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final now = Duration(seconds: timerCount);
    final mediaQuery = MediaQuery.of(context);
    if (!ready) {
      return Center(
        child: SpinKitCubeGrid(
          color: Theme.of(context).accentColor,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: mediaQuery.size.width / mediaQuery.size.height,
        child: Stack(children: [
          CameraPreview(control),
          control.value.isRecordingVideo
              ? Positioned(
                  top: mediaQuery.padding.top + mediaQuery.size.height * 0.03,
                  child: Container(
                    width: mediaQuery.size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: SizedBox(
                                    width: 5,
                                  )),
                              Text(
                                ' Rec: ${_printDuration(now)}',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Spacer()
                      ],
                    ),
                  ),
                )
              : SizedBox(),
        ]),
      );
    }
  }
}
