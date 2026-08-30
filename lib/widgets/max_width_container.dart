import 'package:flutter/material.dart';

class MaxWidthContainer extends StatelessWidget {
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );

    return Align(
      alignment: Alignment.topCenter,
      child: padding != null ? Padding(padding: padding!, child: content) : content,
    );
  }
}

