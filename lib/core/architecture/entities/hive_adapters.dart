import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:delivery_app/core/architecture/entities/location_entity.dart';
import 'package:delivery_app/core/architecture/entities/notification_entity.dart';
import 'package:delivery_app/core/architecture/entities/order_entity.dart';
import 'package:delivery_app/core/architecture/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/entities/user_entity.dart';

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
    return TripEntity(
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
      ..writeBool(obj.isPendingSync);
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
    return UserEntity(
      id: reader.readString(),
      name: reader.readString(),
      email: reader.readString(),
      phone: reader.readString(),
      walletBalance: reader.readDouble(),
      avatarUrl: reader.readBool() ? reader.readString() : null,
      isLoggedIn: reader.readBool(),
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
    writer.writeBool(obj.isLoggedIn);
  }
}

class NotificationEntityAdapter extends TypeAdapter<NotificationEntity> {
  @override
  final int typeId = 6;

  @override
  NotificationEntity read(BinaryReader reader) {
    return NotificationEntity(
      id: reader.readString(),
      title: reader.readString(),
      body: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      tripId: reader.readBool() ? reader.readString() : null,
      isRead: reader.readBool(),
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
    writer.writeBool(obj.isRead);
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
    return PendingSyncEntity(
      id: reader.readString(),
      action: reader.read() as SyncAction,
      payload: jsonDecode(reader.readString()) as Map<String, dynamic>,
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, PendingSyncEntity obj) {
    writer
      ..writeString(obj.id)
      ..write(obj.action)
      ..writeString(jsonEncode(obj.payload))
      ..writeString(obj.createdAt.toIso8601String());
  }
}
