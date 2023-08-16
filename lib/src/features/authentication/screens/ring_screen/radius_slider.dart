
import 'package:flutter/foundation.dart';

class RadiusSliderState extends ChangeNotifier {
  bool _radiusSlider = true;

  bool get radiusSlider => _radiusSlider;

  set radiusSlider(bool value) {
    _radiusSlider = value;
    notifyListeners();
  }
}
