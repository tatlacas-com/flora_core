import 'dart:async';

import 'package:flutter/material.dart';

abstract class Widgetable {
  Widget build({
    FutureOr<void> Function()? onClick,
  });
}
