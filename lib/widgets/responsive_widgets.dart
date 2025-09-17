import 'package:flutter/material.dart';
import '../utils/size_config.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  const ResponsiveText(
    this.text, {
    Key? key,
    required this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizeConfig = SizeConfig.of(context);
    return Semantics(
      label: semanticsLabel ?? text,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: TextStyle(
          fontSize: SizeConfig.proportionalFontSize(fontSize),
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? all;
  final double? horizontal;
  final double? vertical;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.all,
    this.horizontal,
    this.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.proportionalWidth(horizontal ?? all ?? 8.0),
        vertical: SizeConfig.proportionalHeight(vertical ?? all ?? 8.0),
      ),
      child: child,
    );
  }
}

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

class ResponsiveIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;
  final Color? color;
  final String? semanticsLabel;

  const ResponsiveIconButton({
    Key? key,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    this.color,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: IconButton(
        icon: Icon(icon),
        iconSize: SizeConfig.proportionalFontSize(iconSize),
        onPressed: onPressed,
        color: color,
      ),
    );
  }
}
