import 'package:flutter/material.dart';
import 'package:nova_ui/nova_ui.dart';
import 'package:nova_ui/src/widgets/cta/implementations/cta_layout.dart';

class OutlinedCta extends StatelessWidget {
  const OutlinedCta({super.key, required this.data});
  final CtaData data;

  @override
  Widget build(BuildContext context) {
    return CtaLayout(
      borderColor: NovaColors.primary200,
      textColor: NovaColors.primary900,
      backgroundColor: Colors.transparent,
      data: data,
      onTapped: () => data.onTapped(),
    );
  }
}
