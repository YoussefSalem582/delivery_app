import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/profile/profile_view/presentation/bloc/profile_bloc.dart';
import 'package:delivery_app/features/profile/shared/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockNetworkStatus extends Mock implements NetworkStatus {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockRefreshProfileUseCase extends Mock implements RefreshProfileUseCase {}

void main() {
  late MockAuthRepository authRepository;
  late MockNetworkStatus networkStatus;
  late MockGetProfileUseCase getProfile;
  late MockRefreshProfileUseCase refreshProfile;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const RefreshProfileParams());
  });

  setUp(() {
    authRepository = MockAuthRepository();
    networkStatus = MockNetworkStatus();
    getProfile = MockGetProfileUseCase();
    refreshProfile = MockRefreshProfileUseCase();
    when(() => networkStatus.isOnline).thenAnswer((_) async => true);
  });

  group('ProfileBloc', () {
    final cachedUser = UserEntity(
      id: 'cached',
      name: 'Cached User',
      email: 'cached@delivery.app',
      phone: '+201000000000',
      walletBalance: 50,
    );

    final freshUser = UserEntity(
      id: 'fresh',
      name: 'Fresh User',
      email: 'fresh@delivery.app',
      phone: '+201111111111',
      walletBalance: 75,
    );

    ProfileBloc buildBloc() => ProfileBloc(
          getProfile: getProfile,
          refreshProfile: refreshProfile,
          authRepository: authRepository,
          networkStatus: networkStatus,
        );

    blocTest<ProfileBloc, ProfileState>(
      'emits cached user then refreshed profile when data differs',
      build: () {
        when(() => authRepository.cachedUser).thenReturn(cachedUser);
        when(() => getProfile(any())).thenAnswer((_) async => Right(freshUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [
        const ProfileLoading(),
        ProfileLoaded(user: cachedUser, isOffline: false),
        ProfileLoaded(user: freshUser, isOffline: false),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits ProfileError when getProfile fails',
      build: () {
        when(() => authRepository.cachedUser).thenReturn(null);
        when(() => getProfile(any())).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'network error')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [
        const ProfileLoading(),
        isA<ProfileError>(),
      ],
    );
  });
}
