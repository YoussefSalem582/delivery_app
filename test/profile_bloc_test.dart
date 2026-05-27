import 'package:bloc_test/bloc_test.dart';
import 'package:delivery_app/core/architecture/entities/user_entity.dart';
import 'package:delivery_app/core/architecture/repositories/auth_repository.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockNetworkStatus extends Mock implements NetworkStatus {}

void main() {
  late MockAuthRepository authRepository;
  late MockNetworkStatus networkStatus;

  setUp(() {
    authRepository = MockAuthRepository();
    networkStatus = MockNetworkStatus();
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

    blocTest<ProfileBloc, ProfileState>(
      'emits cached user then refreshed profile when data differs',
      build: () {
        when(() => authRepository.cachedUser).thenReturn(cachedUser);
        when(() => authRepository.getProfile()).thenAnswer((_) async => freshUser);
        return ProfileBloc(
          authRepository: authRepository,
          networkStatus: networkStatus,
        );
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
        when(() => authRepository.getProfile()).thenThrow(Exception('network error'));
        return ProfileBloc(
          authRepository: authRepository,
          networkStatus: networkStatus,
        );
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [
        const ProfileLoading(),
        isA<ProfileError>(),
      ],
    );
  });
}
