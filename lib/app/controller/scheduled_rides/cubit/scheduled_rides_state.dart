part of 'scheduled_rides_cubit.dart';

@immutable
sealed class ScheduledRidesState {}

final class ScheduledRidesInitial extends ScheduledRidesState {}

final class ScheduledRidesLoading extends ScheduledRidesState {}

final class ScheduledRidesLoaded extends ScheduledRidesState {}

final class ScheduledRidesLoadingFailed extends ScheduledRidesState {}
