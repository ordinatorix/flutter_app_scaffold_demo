import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'base_model.dart';
import '../locator.dart';
import '../logger.dart';

final log = getLogger('BaseView');

class BaseView<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget child) builder;
  final Function(T) onModelReady;
  final Function(T) onModelDependencyChange;
  final Function(T) onModelUpdate;
  final Function(T) onModelDisposing;

  BaseView({
    this.builder,
    this.onModelReady,
    this.onModelDependencyChange,
    this.onModelUpdate,
    this.onModelDisposing,
  });

  @override
  _BaseViewState<T> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseModel> extends State<BaseView<T>> {
  T model = locator<T>();

  @override
  void initState() {
    log.i('initState');
    log.d('initializing baseview:$model');
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    log.i('didChangeDependencies');
    log.d('change dependencies of baseview:$model');
    if (widget.onModelDependencyChange != null) {
      widget.onModelDependencyChange(model);
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant BaseView<T> oldWidget) {
    log.i('didUpdateWidget');
    log.d('update baseview:$model');
    if (widget.onModelUpdate != null) {
      widget.onModelUpdate(model);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    log.i('dispose');
    log.d('disposing baseview:$model');
    if (widget.onModelDisposing != null) {
      widget.onModelDisposing(model);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.i('building baseview');
    return ChangeNotifierProvider<T>(
        create: (context) => model,
        child: Consumer<T>(builder: widget.builder));
  }
}
