import 'package:delivery_app/features/home/shared/data/models/nominatim_place_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NominatimPlaceModel', () {
    test('fromJson parses search result fields', () {
      final model = NominatimPlaceModel.fromJson({
        'place_id': 12345,
        'lat': '30.0444',
        'lon': '31.2357',
        'display_name': 'Tahrir Square, Cairo, Egypt',
        'address': {
          'road': 'Tahrir Square',
          'city': 'Cairo',
          'country': 'Egypt',
        },
      });

      expect(model.placeId, 12345);
      expect(model.lat, closeTo(30.0444, 0.0001));
      expect(model.lng, closeTo(31.2357, 0.0001));
      expect(model.displayName, 'Tahrir Square, Cairo, Egypt');
    });

    test('toEntity builds title and subtitle from address', () {
      final entity = NominatimPlaceModel.fromJson({
        'place_id': 1,
        'lat': '30.1',
        'lon': '31.2',
        'display_name': 'City Mall, Nasr City, Cairo, Egypt',
        'address': {
          'name': 'City Mall',
          'suburb': 'Nasr City',
          'city': 'Cairo',
          'country': 'Egypt',
        },
      }).toEntity();

      expect(entity.id, '1');
      expect(entity.title, 'City Mall');
      expect(entity.subtitle, contains('Cairo'));
      expect(entity.lat, 30.1);
      expect(entity.lng, 31.2);
      expect(entity.displayAddress, contains('City Mall'));
    });

    test('toEntity falls back to display_name when address is empty', () {
      final entity = NominatimPlaceModel.fromJson({
        'place_id': 2,
        'lat': '30.0',
        'lon': '31.0',
        'display_name': 'Unknown Place, Cairo, Egypt',
      }).toEntity();

      expect(entity.title, 'Unknown Place');
      expect(entity.subtitle, isNotEmpty);
    });
  });
}
