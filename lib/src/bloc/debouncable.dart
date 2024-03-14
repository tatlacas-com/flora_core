import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:rxdart/rxdart.dart';

EventTransformer<Event> debouncable<Event>(
    {Duration duration = const Duration(milliseconds: 600)}) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}
