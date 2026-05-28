part of 'app_mode_cubit.dart';

class AppModeState extends Equatable {
  const AppModeState({required this.mode});

  final AppMode mode;

  bool get isDriver => mode.isDriver;

  AppModeState copyWith({AppMode? mode}) =>
      AppModeState(mode: mode ?? this.mode);

  @override
  List<Object?> get props => [mode];
}
