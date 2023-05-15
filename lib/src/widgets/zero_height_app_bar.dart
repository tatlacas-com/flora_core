import 'package:flutter/material.dart';

class ZeroHeightAppBar extends PreferredSize {
  ZeroHeightAppBar({
    super.key,
  }) : super(
          child: AppBar(
            elevation: 0,
          ),
          preferredSize: const Size.fromHeight(0),
        );
}
