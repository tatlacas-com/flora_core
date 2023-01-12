import 'package:flutter/material.dart';

abstract class ScreenUtils {
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 758;
  }
}
