import 'dart:async';

import 'package:flutter/material.dart';

abstract class Widgetable {
  Widget build({
    required int section,
    required int index,
    FutureOr<void> Function()? onClick,
    Animation<double>? animation,
  });
}
