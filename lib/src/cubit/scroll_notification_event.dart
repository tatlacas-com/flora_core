part of 'scroll_notification_bloc.dart';

sealed class ScrollNotificationEvent {}

class ScrolledEvent extends ScrollNotificationEvent {
  ScrolledEvent({required this.scrollInfo});

  final ScrollNotification scrollInfo;
}

class PostScrolledEvent extends ScrollNotificationEvent {
  PostScrolledEvent({required this.scrollInfo});
  final ScrollNotification scrollInfo;
}
