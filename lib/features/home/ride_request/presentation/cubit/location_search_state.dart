import 'package:equatable/equatable.dart';

import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';

enum LocationSearchField { pickup, dropoff }

enum LocationSearchStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
  offline,
}

class LocationSearchState extends Equatable {
  const LocationSearchState({
    this.status = LocationSearchStatus.idle,
    this.activeField = LocationSearchField.dropoff,
    this.suggestions = const [],
    this.errorMessage,
    this.reverseGeocodedPickup,
  });

  final LocationSearchStatus status;
  final LocationSearchField activeField;
  final List<PlaceSuggestion> suggestions;
  final String? errorMessage;
  final PlaceSuggestion? reverseGeocodedPickup;

  bool get isLoading => status == LocationSearchStatus.loading;

  LocationSearchState copyWith({
    LocationSearchStatus? status,
    LocationSearchField? activeField,
    List<PlaceSuggestion>? suggestions,
    String? errorMessage,
    PlaceSuggestion? reverseGeocodedPickup,
    bool clearError = false,
    bool clearSuggestions = false,
  }) {
    return LocationSearchState(
      status: status ?? this.status,
      activeField: activeField ?? this.activeField,
      suggestions: clearSuggestions ? const [] : suggestions ?? this.suggestions,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      reverseGeocodedPickup:
          reverseGeocodedPickup ?? this.reverseGeocodedPickup,
    );
  }

  @override
  List<Object?> get props => [
        status,
        activeField,
        suggestions,
        errorMessage,
        reverseGeocodedPickup,
      ];
}
