import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconWidget extends StatelessWidget {
  final Color? backgroundColor;
  final double? iconSize;
  final double? padding;
  final String? imagePath;
  final String? svgPath;
  final IconData? iconData;
  final Color? iconColor;
  final String? svgNetworkPath;
  const IconWidget({
    super.key,
    this.backgroundColor,
    this.iconSize,
    this.padding,
    this.imagePath,
    this.svgPath,
    this.iconData,
    this.iconColor,
    this.svgNetworkPath,
  }) : assert(
            (imagePath != null ? 1 : 0) +
                    (svgPath != null ? 1 : 0) +
                    (iconData != null ? 1 : 0) +
                    (svgNetworkPath != null ? 1 : 0) ==
                1,
            'Only one of imagePath, svgPath, or iconData can be not null');

  @override
  Widget build(BuildContext context) {
    final size = iconSize ?? 24;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.transparent,
      ),
      child: Padding(
        padding: padding != null ? EdgeInsets.all(padding!) : EdgeInsets.zero,
        child: imagePath != null
            ? Image.asset(
                imagePath!,
                width: size,
                height: size,
                color: iconColor,
              )
            : svgPath != null
                ? SvgPicture.asset(
                    svgPath!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    colorFilter: iconColor != null
                        ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                        : null,
                  )
                : svgNetworkPath != null
                    ? SvgPicture.network(
                        svgNetworkPath!,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        iconData!,
                        size: size,
                        color: iconColor,
                      ),
      ),
    );
  }
}
