import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  /// ---- Compact scaling ----
  /// baseline width = 360, baseline height = 800 (আগে 640 ছিল)
  /// height এখন অটোমেটিক ছোট দেখাবে

  static double proportionalWidth(double width) {
    return screenWidth * (width / 360);
  }

  static double proportionalHeight(double height) {
    return screenHeight * (height / 800); // Compact look
  }

  static double proportionalFontSize(double size) {
    return (screenWidth / 360) * size * 0.92;
    // 0.92 দিয়ে font সামান্য ছোট করা হলো
  }

  static SizeConfig of(BuildContext context) {
    init(context);
    return SizeConfig();
  }
}
