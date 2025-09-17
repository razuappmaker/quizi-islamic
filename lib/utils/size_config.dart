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
  static late double _textScaleFactor;
  static late Orientation _orientation;

  static bool get isTablet => screenWidth != null && screenWidth! > 600;

  static bool get isLargeTablet => screenWidth != null && screenWidth! > 900;

  static bool get isLandscape => _orientation == Orientation.landscape;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    _orientation = _mediaQueryData.orientation;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
    _textScaleFactor = _mediaQueryData.textScaleFactor;
  }

  static double proportionalWidth(double width) {
    final baseWidth = isLandscape ? 720 : 360; // Wider base for landscape
    return screenWidth * (width / baseWidth);
  }

  static double proportionalHeight(double height) {
    final baseHeight = isLandscape ? 360 : 800; // Adjusted for landscape
    return screenHeight * (height / baseHeight);
  }

  static double proportionalFontSize(double size) {
    final scaleFactor = isTablet ? 1.0 : 0.92;
    return (screenWidth / (isLandscape ? 720 : 360)) *
        size *
        scaleFactor *
        _textScaleFactor;
  }

  static SizeConfig of(BuildContext context) {
    init(context);
    return SizeConfig();
  }
}
