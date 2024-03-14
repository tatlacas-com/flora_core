import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

part 'scroll_notification_state.dart';
part 'scroll_notification_event.dart';

class ScrollNotificationBloc
    extends Bloc<ScrollNotificationEvent, ScrollNotificationState> {
  ScrollNotificationBloc() : super(ScrollNotificationInitial()) {
    on<PostScrolledEvent>(_onPostScrolledEvent, transformer: debouncable());
    on<ScrolledEvent>(_onScrolledEvent);
  }

  FutureOr<void> _onScrolledEvent(
      ScrolledEvent event, Emitter<ScrollNotificationState> emit) async {
    emit(PostScrolledNotificationState(scrollInfo: event.scrollInfo));
  }

  FutureOr<void> _onPostScrolledEvent(
      PostScrolledEvent event, Emitter<ScrollNotificationState> emit) async {
    emit(ScrolledNotificationState(scrollInfo: event.scrollInfo));
  }
}
