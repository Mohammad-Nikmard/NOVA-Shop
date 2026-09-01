import 'package:flutter/material.dart';
import 'package:nova_ui/gen/fonts.gen.dart';
import 'package:nova_ui/nova_ui.dart';
import 'package:nova_ui/src/core/constants/nova_icons.dart';
import 'package:nova_ui/src/widgets/cta/implementations/cta_layout.dart';

class SocialAuthCta extends StatelessWidget {
  const SocialAuthCta({super.key, required this.data, this.isGoogle = true});
  final CtaData data;
  final bool isGoogle;

  @override
  Widget build(BuildContext context) {
    return CtaLayout(
      borderColor: isGoogle ? NovaColors.primary200 : null,
      backgroundColor: isGoogle ? Colors.transparent : NovaColors.blue,
      data: data,
      onTapped: () => data.onTapped(),
      content: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconWidget(
            iconSize: 24,
            svgPath: isGoogle
                ? NovaIcons.google.path
                : NovaIcons.whiteFacebook.path,
          ),
          Text(
            data.text,
            style: TextStyle(
              color: isGoogle ? NovaColors.primary900 : NovaColors.white,
              fontSize: 16,
              fontFamily: FontFamily.nsm,
            ),
          ),
        ],
      ),
    );
  }
}
