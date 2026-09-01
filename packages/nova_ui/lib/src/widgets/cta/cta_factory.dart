import 'package:flutter/cupertino.dart';
import 'package:nova_ui/src/widgets/cta/cta_data.dart';
import 'package:nova_ui/src/widgets/cta/cta_type.dart';
import 'package:nova_ui/src/widgets/cta/implementations/filled_cta.dart';
import 'package:nova_ui/src/widgets/cta/implementations/grayed_out_cta.dart';
import 'package:nova_ui/src/widgets/cta/implementations/social_auth_cta.dart';
import 'package:nova_ui/src/widgets/cta/implementations/outlined_cta.dart';

abstract final class CtaFactory {
  static Widget selectCTA({required CtaType type, required CtaData data}) {
    switch (type) {
      case CtaType.filled:
        return FilledCta(data: data);

      case CtaType.outline:
        return OutlinedCta(data: data);

      case CtaType.grayedOut:
        return GrayedOutCta(data: data);

      case CtaType.googleLogin:
        return SocialAuthCta(data: data, isGoogle: true);

      case CtaType.facebookLogin:
        return SocialAuthCta(data: data, isGoogle: false);
    }
  }
}
