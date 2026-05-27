import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/core/architecture/entities/user_entity.dart';
import 'package:delivery_app/core/architecture/repositories/auth_repository.dart';
import 'package:delivery_app/core/network/network_status.dart';

part 'profile_event.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required AuthRepository authRepository,
    required NetworkStatus networkStatus,
  })  : _authRepository = authRepository,
        _networkStatus = networkStatus,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileRefreshRequested>(_onRefresh);
  }

  final AuthRepository _authRepository;
  final NetworkStatus _networkStatus;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final isOffline = !(await _networkStatus.isOnline);
    try {
      final cached = _authRepository.cachedUser;
      if (cached != null) {
        emit(ProfileLoaded(user: cached, isOffline: isOffline));
      }
      final user = await _authRepository.getProfile();
      emit(ProfileLoaded(user: user, isOffline: isOffline));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is ProfileLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    try {
      final user = await _authRepository.getProfile(forceRefresh: true);
      final isOffline = !(await _networkStatus.isOnline);
      emit(ProfileLoaded(user: user, isOffline: isOffline));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
