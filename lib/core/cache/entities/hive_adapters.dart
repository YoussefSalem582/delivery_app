import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:delivery_app/core/cache/entities/cache_metadata_entity.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/driver_profile_entity.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_entity.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/location_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/route_cache_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

class LocationEntityAdapter extends TypeAdapter<LocationEntity> {
  @override
  final int typeId = 0;

  @override
  LocationEntity read(BinaryReader reader) {
    return LocationEntity(
      lat: reader.readDouble(),
      lng: reader.readDouble(),
      address: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, LocationEntity obj) {
    writer
      ..writeDouble(obj.lat)
      ..writeDouble(obj.lng)
      ..writeBool(obj.address != null);
    if (obj.address != null) writer.writeString(obj.address!);
  }
}

class TripStatusAdapter extends TypeAdapter<TripStatus> {
  @override
  final int typeId = 1;

  @override
  TripStatus read(BinaryReader reader) {
    return TripStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TripStatus obj) {
    writer.writeByte(obj.index);
  }
}

class TripEntityAdapter extends TypeAdapter<TripEntity> {
  @override
  final int typeId = 2;

  @override
  TripEntity read(BinaryReader reader) {
    final entity = TripEntity(
      id: reader.readString(),
      pickupAddress: reader.readString(),
      dropoffAddress: reader.readString(),
      pickupLat: reader.readDouble(),
      pickupLng: reader.readDouble(),
      dropoffLat: reader.readDouble(),
      dropoffLng: reader.readDouble(),
      status: reader.read() as TripStatus,
      driverName: reader.readBool() ? reader.readString() : null,
      driverPhone: reader.readBool() ? reader.readString() : null,
      fare: reader.readDouble(),
      createdAt: DateTime.parse(reader.readString()),
      updatedAt: DateTime.parse(reader.readString()),
      isPendingSync: reader.readBool(),
    );

    String? driverAvatarUrl;
    double? driverRating;
    String? driverVehicle;
    if (reader.availableBytes > 0) {
      driverAvatarUrl = reader.readBool() ? reader.readString() : null;
    }
    if (reader.availableBytes > 0) {
      driverRating = reader.readBool() ? reader.readDouble() : null;
    }
    if (reader.availableBytes > 0) {
      driverVehicle = reader.readBool() ? reader.readString() : null;
    }

    double? distanceKm;
    int? etaMinutes;
    String? paymentMethodKey;
    String? rideTierKey;
    if (reader.availableBytes > 0) {
      distanceKm = reader.readBool() ? reader.readDouble() : null;
    }
    if (reader.availableBytes > 0) {
      etaMinutes = reader.readBool() ? reader.readInt() : null;
    }
    if (reader.availableBytes > 0) {
      paymentMethodKey = reader.readBool() ? reader.readString() : null;
    }
    if (reader.availableBytes > 0) {
      rideTierKey = reader.readBool() ? reader.readString() : null;
    }

    String? riderId;
    String? driverId;
    double? driverLat;
    double? driverLng;
    if (reader.availableBytes > 0) {
      riderId = reader.readString();
    }
    if (reader.availableBytes > 0) {
      driverId = reader.readBool() ? reader.readString() : null;
    }
    if (reader.availableBytes > 0) {
      driverLat = reader.readBool() ? reader.readDouble() : null;
    }
    if (reader.availableBytes > 0) {
      driverLng = reader.readBool() ? reader.readDouble() : null;
    }

    return entity.copyWith(
      driverAvatarUrl: driverAvatarUrl,
      driverRating: driverRating,
      driverVehicle: driverVehicle,
      distanceKm: distanceKm,
      etaMinutes: etaMinutes,
      paymentMethodKey: paymentMethodKey,
      rideTierKey: rideTierKey,
      riderId: riderId,
      driverId: driverId,
      driverLat: driverLat,
      driverLng: driverLng,
    );
  }

  @override
  void write(BinaryWriter writer, TripEntity obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.pickupAddress)
      ..writeString(obj.dropoffAddress)
      ..writeDouble(obj.pickupLat)
      ..writeDouble(obj.pickupLng)
      ..writeDouble(obj.dropoffLat)
      ..writeDouble(obj.dropoffLng)
      ..write(obj.status)
      ..writeBool(obj.driverName != null);
    if (obj.driverName != null) writer.writeString(obj.driverName!);
    writer.writeBool(obj.driverPhone != null);
    if (obj.driverPhone != null) writer.writeString(obj.driverPhone!);
    writer
      ..writeDouble(obj.fare)
      ..writeString(obj.createdAt.toIso8601String())
      ..writeString(obj.updatedAt.toIso8601String())
      ..writeBool(obj.isPendingSync)
      ..writeBool(obj.driverAvatarUrl != null);
    if (obj.driverAvatarUrl != null) {
      writer.writeString(obj.driverAvatarUrl!);
    }
    writer.writeBool(obj.driverRating != null);
    if (obj.driverRating != null) writer.writeDouble(obj.driverRating!);
    writer.writeBool(obj.driverVehicle != null);
    if (obj.driverVehicle != null) writer.writeString(obj.driverVehicle!);
    writer.writeBool(obj.distanceKm != null);
    if (obj.distanceKm != null) writer.writeDouble(obj.distanceKm!);
    writer.writeBool(obj.etaMinutes != null);
    if (obj.etaMinutes != null) writer.writeInt(obj.etaMinutes!);
    writer.writeBool(obj.paymentMethodKey != null);
    if (obj.paymentMethodKey != null) {
      writer.writeString(obj.paymentMethodKey!);
    }
    writer.writeBool(obj.rideTierKey != null);
    if (obj.rideTierKey != null) writer.writeString(obj.rideTierKey!);
    writer
      ..writeString(obj.riderId)
      ..writeBool(obj.driverId != null);
    if (obj.driverId != null) writer.writeString(obj.driverId!);
    writer.writeBool(obj.driverLat != null);
    if (obj.driverLat != null) writer.writeDouble(obj.driverLat!);
    writer.writeBool(obj.driverLng != null);
    if (obj.driverLng != null) writer.writeDouble(obj.driverLng!);
  }
}

class OrderStatusAdapter extends TypeAdapter<OrderStatus> {
  @override
  final int typeId = 3;

  @override
  OrderStatus read(BinaryReader reader) {
    return OrderStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, OrderStatus obj) {
    writer.writeByte(obj.index);
  }
}

class OrderEntityAdapter extends TypeAdapter<OrderEntity> {
  @override
  final int typeId = 4;

  @override
  OrderEntity read(BinaryReader reader) {
    return OrderEntity(
      id: reader.readString(),
      title: reader.readString(),
      amount: reader.readDouble(),
      status: reader.read() as OrderStatus,
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, OrderEntity obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..writeDouble(obj.amount)
      ..write(obj.status)
      ..writeString(obj.createdAt.toIso8601String());
  }
}

class UserEntityAdapter extends TypeAdapter<UserEntity> {
  @override
  final int typeId = 5;

  @override
  UserEntity read(BinaryReader reader) {
    final entity = UserEntity(
      id: reader.readString(),
      name: reader.readString(),
      email: reader.readString(),
      phone: reader.readString(),
      walletBalance: reader.readDouble(),
      avatarUrl: reader.readBool() ? reader.readString() : null,
      isLoggedIn: reader.readBool(),
    );

    if (reader.availableBytes <= 0) return entity;

    final isDriverRegistered = reader.readBool();
    DriverProfileEntity? driverProfile;
    if (reader.availableBytes > 0 && reader.readBool()) {
      driverProfile = DriverProfileEntity(
        phone: reader.readString(),
        vehicleType: reader.readString(),
        vehicleMakeModel: reader.readString(),
        licensePlate: reader.readString(),
        registeredAt: DateTime.parse(reader.readString()),
        termsAccepted: reader.readBool(),
      );
    }

    return entity.copyWith(
      isDriverRegistered: isDriverRegistered,
      driverProfile: driverProfile,
    );
  }

  @override
  void write(BinaryWriter writer, UserEntity obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.email)
      ..writeString(obj.phone)
      ..writeDouble(obj.walletBalance)
      ..writeBool(obj.avatarUrl != null);
    if (obj.avatarUrl != null) writer.writeString(obj.avatarUrl!);
    writer
      ..writeBool(obj.isLoggedIn)
      ..writeBool(obj.isDriverRegistered)
      ..writeBool(obj.driverProfile != null);
    if (obj.driverProfile != null) {
      final profile = obj.driverProfile!;
      writer
        ..writeString(profile.phone)
        ..writeString(profile.vehicleType)
        ..writeString(profile.vehicleMakeModel)
        ..writeString(profile.licensePlate)
        ..writeString(profile.registeredAt.toIso8601String())
        ..writeBool(profile.termsAccepted);
    }
  }
}

class NotificationEntityAdapter extends TypeAdapter<NotificationEntity> {
  @override
  final int typeId = 6;

  @override
  NotificationEntity read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final body = reader.readString();
    final createdAt = DateTime.parse(reader.readString());
    final tripId = reader.readBool() ? reader.readString() : null;
    final isRead = reader.readBool();
    final type = reader.availableBytes > 0
        ? NotificationType.values[reader.readByte()]
        : NotificationType.inferFromTitleKey(title);
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      tripId: tripId,
      isRead: isRead,
      type: type,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationEntity obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..writeString(obj.body)
      ..writeString(obj.createdAt.toIso8601String())
      ..writeBool(obj.tripId != null);
    if (obj.tripId != null) writer.writeString(obj.tripId!);
    writer
      ..writeBool(obj.isRead)
      ..writeByte(obj.type.index);
  }
}

class SyncActionAdapter extends TypeAdapter<SyncAction> {
  @override
  final int typeId = 7;

  @override
  SyncAction read(BinaryReader reader) {
    return SyncAction.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, SyncAction obj) {
    writer.writeByte(obj.index);
  }
}

class PendingSyncEntityAdapter extends TypeAdapter<PendingSyncEntity> {
  @override
  final int typeId = 8;

  @override
  PendingSyncEntity read(BinaryReader reader) {
    final entity = PendingSyncEntity(
      id: reader.readString(),
      action: reader.read() as SyncAction,
      payload: jsonDecode(reader.readString()) as Map<String, dynamic>,
      createdAt: DateTime.parse(reader.readString()),
    );
    try {
      return entity.copyWith(retryCount: reader.readInt());
    } catch (_) {
      return entity;
    }
  }

  @override
  void write(BinaryWriter writer, PendingSyncEntity obj) {
    writer
      ..writeString(obj.id)
      ..write(obj.action)
      ..writeString(jsonEncode(obj.payload))
      ..writeString(obj.createdAt.toIso8601String())
      ..writeInt(obj.retryCount);
  }
}

class CacheMetadataEntityAdapter extends TypeAdapter<CacheMetadataEntity> {
  @override
  final int typeId = 9;

  @override
  CacheMetadataEntity read(BinaryReader reader) {
    return CacheMetadataEntity(
      key: reader.readString(),
      lastFetchedAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, CacheMetadataEntity obj) {
    writer
      ..writeString(obj.key)
      ..writeString(obj.lastFetchedAt.toIso8601String());
  }
}

class RouteCacheEntityAdapter extends TypeAdapter<RouteCacheEntity> {
  @override
  final int typeId = 10;

  @override
  RouteCacheEntity read(BinaryReader reader) {
    final pointCount = reader.readInt();
    final points = <LatLng>[];
    for (var i = 0; i < pointCount; i++) {
      points.add(LatLng(reader.readDouble(), reader.readDouble()));
    }
    return RouteCacheEntity(
      cacheKey: reader.readString(),
      points: points,
      distanceMeters: reader.readDouble(),
      durationSeconds: reader.readDouble(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, RouteCacheEntity obj) {
    writer.writeInt(obj.points.length);
    for (final p in obj.points) {
      writer
        ..writeDouble(p.latitude)
        ..writeDouble(p.longitude);
    }
    writer
      ..writeString(obj.cacheKey)
      ..writeDouble(obj.distanceMeters)
      ..writeDouble(obj.durationSeconds)
      ..writeString(obj.createdAt.toIso8601String());
  }
}
