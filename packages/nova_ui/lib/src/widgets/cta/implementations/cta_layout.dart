import 'package:flutter/material.dart';
import 'package:nova_ui/gen/fonts.gen.dart';
import 'package:nova_ui/nova_ui.dart';

class CtaLayout extends StatefulWidget {
  const CtaLayout({
    super.key,
    required this.onTapped,
    required this.data,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.content,
  });

  final void Function() onTapped;
  final CtaData data;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Widget? content;

  @override
  State<CtaLayout> createState() => _CtaLayoutState();
}

class _CtaLayoutState extends State<CtaLayout> {
  bool onTapped = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (details) => setState(() {
        onTapped = true;
      }),
      onPanCancel: () => setState(() {
        onTapped = false;
      }),
      onTap: () => widget.onTapped(),
      child: AnimatedScale(
        scale: onTapped ? 0.95 : 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.decelerate,
        child: Container(
          height: widget.data.height,
          width: widget.data.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: widget.borderColor ?? Colors.transparent,
              width: widget.borderColor != null ? 1 : 0,
            ),
            color: widget.backgroundColor ?? Colors.red,
          ),
          child: Center(
            child:
                widget.content ??
                Text(
                  widget.data.text,
                  style: TextStyle(
                    color: widget.textColor ?? Colors.white,
                    fontSize: 16,
                    fontFamily: FontFamily.nsm,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
