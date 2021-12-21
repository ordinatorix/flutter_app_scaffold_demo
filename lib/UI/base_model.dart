import 'package:flutter/widgets.dart';

import '../logger.dart';
import '../enums/view_state.dart';
import '../enums/gps_state.dart';

final log = getLogger('BaseModel');

class BaseModel extends ChangeNotifier {
  ViewState _state = ViewState.Idle;
  ViewState get state => _state;

  GpsState _gpsState = GpsState.Inactive;
  GpsState get gpsState => _gpsState;

  void setState(ViewState viewState) {
    log.i('setState | $viewState');
    _state = viewState;
    log.d('setting state to: $_state');
    notifyListeners();
  }

  void setGpsState(GpsState gpsViewState) {
    log.i('setGpsState | $gpsViewState');
    _gpsState = gpsViewState;
    log.d('setting gps view state to $gpsViewState');
    notifyListeners();
  }
}
