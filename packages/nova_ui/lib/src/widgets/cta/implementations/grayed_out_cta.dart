import 'package:flutter/material.dart';
import 'package:nova_ui/nova_ui.dart';
import 'package:nova_ui/src/widgets/cta/implementations/cta_layout.dart';

class GrayedOutCta extends StatelessWidget {
  const GrayedOutCta({super.key, required this.data});
  final CtaData data;

  @override
  Widget build(BuildContext context) {
    return CtaLayout(
      backgroundColor: NovaColors.primary200,
      textColor: NovaColors.white,
      data: data,
      onTapped: () => data.onTapped(),
    );
  }
}
