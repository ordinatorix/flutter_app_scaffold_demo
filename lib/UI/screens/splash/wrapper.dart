import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logger.dart';

import '../../base_view_screen.dart';
import 'scr_splash.dart';

import 'mdl_wrapper.dart';

final log = getLogger('Wrapper');

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log.i('building wrapper');

    return BaseView<WrapperViewModel>(
      onModelDependencyChange: (model) {
        model.isStorageReady = Provider.of<bool>(context);
        model.initModel();
      },
      onModelUpdate: (model) {
        model.isStorageReady = Provider.of<bool>(context);
        model.initModel();
      },
      builder: (context, model, child) {
        return SplashScreen();
      },
    );
  }
}
