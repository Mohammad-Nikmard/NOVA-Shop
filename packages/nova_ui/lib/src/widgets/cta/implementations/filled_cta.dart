import 'package:flutter/material.dart';
import 'package:nova_ui/nova_ui.dart';
import 'package:nova_ui/src/widgets/cta/implementations/cta_layout.dart';

class FilledCta extends StatelessWidget {
  const FilledCta({super.key, required this.data});
  final CtaData data;

  @override
  Widget build(BuildContext context) {
    return CtaLayout(
      backgroundColor: NovaColors.primary900,
      data: data,
      textColor: NovaColors.white,
      onTapped: () => data.onTapped(),
    );
  }
}
