part of 'scroll_notification_bloc.dart';

sealed class ScrollNotificationState extends Equatable {
  const ScrollNotificationState();

  @override
  List<Object> get props => [];
}

final class ScrollNotificationInitial extends ScrollNotificationState {}

final class ScrolledNotificationState extends ScrollNotificationState {
  const ScrolledNotificationState({required this.scrollInfo});

  final ScrollNotification scrollInfo;
  @override
  List<Object> get props => [scrollInfo.metrics.pixels];
}

final class PostScrolledNotificationState extends ScrollNotificationState {
  const PostScrolledNotificationState({required this.scrollInfo});

  final ScrollNotification scrollInfo;
  @override
  List<Object> get props => [scrollInfo.metrics.pixels];
}
