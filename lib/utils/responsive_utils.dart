// utils/responsive_utils.dart
import 'package:flutter/material.dart';

// রেসপনসিভ টেক্সট উইজেট
class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow overflow;
  final String? semanticsLabel;

  const ResponsiveText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final responsiveFontSize = fontSize * mediaQuery.textScaleFactor;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      semanticsLabel: semanticsLabel,
    );
  }
}

// রেসপনসিভ আইকন বাটন উইজেট
class ResponsiveIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;
  final Color color;
  final String? semanticsLabel;

  const ResponsiveIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 24,
    this.color = Colors.black,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final responsiveIconSize = iconSize * mediaQuery.textScaleFactor;

    return IconButton(
      icon: Icon(icon),
      iconSize: responsiveIconSize,
      onPressed: onPressed,
      color: color,
      splashRadius: responsiveIconSize * 0.7,
      constraints: BoxConstraints(
        minWidth: responsiveIconSize * 1.5,
        minHeight: responsiveIconSize * 1.5,
      ),
      splashColor: color.withOpacity(0.2),
      tooltip: semanticsLabel,
    );
  }
}

// রেসপনসিভ প্যাডিং উইজেট
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double horizontal;
  final double vertical;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.horizontal = 0,
    this.vertical = 0,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final responsiveHorizontal = horizontal * mediaQuery.textScaleFactor;
    final responsiveVertical = vertical * mediaQuery.textScaleFactor;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveHorizontal,
        vertical: responsiveVertical,
      ),
      child: child,
    );
  }
}

// রেসপনসিভ সাইজডবক্স উইজেট
class ResponsiveSizedBox extends StatelessWidget {
  final double height;
  final double width;

  const ResponsiveSizedBox({super.key, this.height = 0, this.width = 0});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final responsiveHeight = height * mediaQuery.textScaleFactor;
    final responsiveWidth = width * mediaQuery.textScaleFactor;

    return SizedBox(height: responsiveHeight, width: responsiveWidth);
  }
}

// ডিভাইস টাইপ চেক করার জন্য হেল্পার ফাংশন
bool isTablet(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final shortestSide = mediaQuery.size.shortestSide;
  return shortestSide > 600;
}

bool isLandscape(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  return mediaQuery.orientation == Orientation.landscape;
}

// রেসপনসিভ ভ্যালু ক্যালকুলেটর
double responsiveValue(BuildContext context, double value) {
  return value * MediaQuery.of(context).textScaleFactor;
}
