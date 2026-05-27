import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/profile/shared/domain/usecases/get_profile_usecase.dart';

part 'profile_event.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfileUseCase getProfile,
    required RefreshProfileUseCase refreshProfile,
    required AuthRepository authRepository,
    required NetworkStatus networkStatus,
  })  : _getProfile = getProfile,
        _refreshProfile = refreshProfile,
        _authRepository = authRepository,
        _networkStatus = networkStatus,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileRefreshRequested>(_onRefresh);
  }

  final GetProfileUseCase _getProfile;
  final RefreshProfileUseCase _refreshProfile;
  final AuthRepository _authRepository;
  final NetworkStatus _networkStatus;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final isOffline = !(await _networkStatus.isOnline);
    final cached = _authRepository.cachedUser;
    if (cached != null) {
      emit(ProfileLoaded(user: cached, isOffline: isOffline));
    }
    final result = await _getProfile(const NoParams());
    result.fold(
      (Failure failure) => emit(ProfileError(failure.message)),
      (UserEntity user) => emit(ProfileLoaded(user: user, isOffline: isOffline)),
    );
  }

  Future<void> _onRefresh(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    if (current is ProfileLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    final result = await _refreshProfile(const RefreshProfileParams());
    final isOffline = !(await _networkStatus.isOnline);
    result.fold(
      (Failure failure) => emit(ProfileError(failure.message)),
      (UserEntity user) => emit(ProfileLoaded(user: user, isOffline: isOffline)),
    );
  }
}
