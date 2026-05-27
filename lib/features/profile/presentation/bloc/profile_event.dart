part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
    this.isOffline = false,
    this.isRefreshing = false,
  });

  final UserEntity user;
  final bool isOffline;
  final bool isRefreshing;

  ProfileLoaded copyWith({
    UserEntity? user,
    bool? isOffline,
    bool? isRefreshing,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isOffline: isOffline ?? this.isOffline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [user, isOffline, isRefreshing];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
