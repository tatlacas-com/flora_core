import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

abstract class ScreenUtils {
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 758;
  }

}
