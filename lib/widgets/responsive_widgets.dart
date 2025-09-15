// lib/widgets/responsive_widgets.dart
import 'package:flutter/material.dart';
import '../utils/size_config.dart';

// রেসপনসিভ টেক্সট উইজেট
class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    required this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizeConfig = SizeConfig.of(context);
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: SizeConfig.proportionalFontSize(fontSize),
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

// রেসপনসিভ প্যাডিং উইজেট
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double padding;

  const ResponsivePadding({Key? key, required this.child, this.padding = 8.0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.proportionalWidth(padding)),
      child: child,
    );
  }
}

// রেসপনসিভ SizedBox উইজেট
class ResponsiveSizedBox extends StatelessWidget {
  final double? height;
  final double? width;

  const ResponsiveSizedBox({Key? key, this.height, this.width})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height != null ? SizeConfig.proportionalHeight(height!) : null,
      width: width != null ? SizeConfig.proportionalWidth(width!) : null,
    );
  }
}

// রেসপনসিভ আইকন বাটন
class ResponsiveIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;
  final Color? color;

  const ResponsiveIconButton({
    Key? key,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: SizeConfig.proportionalFontSize(iconSize),
      onPressed: onPressed,
      color: color,
    );
  }
}
