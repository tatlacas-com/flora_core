import 'dart:async';

import 'package:flutter/material.dart';

abstract class Widgetable {
  Widget build({
    required int section,
    required int index,
    required BuildContext context,
    FutureOr<void> Function()? onClick,
    Animation<double>? animation,
  });
}
