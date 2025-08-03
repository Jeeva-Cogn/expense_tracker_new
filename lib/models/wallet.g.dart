// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 3;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      balance: fields[3] as double,
      currency: fields[4] as String,
      color: fields[5] as String,
      icon: fields[6] as String,
      type: fields[7] as WalletType,
      sharedWith: (fields[8] as List?)?.cast<String>(),
      permissions: (fields[9] as Map?)?.cast<String, WalletPermission>(),
      isDefault: fields[10] as bool,
      isSynced: fields[11] as bool,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.icon)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.sharedWith)
      ..writeByte(9)
      ..write(obj.permissions)
      ..writeByte(10)
      ..write(obj.isDefault)
      ..writeByte(11)
      ..write(obj.isSynced)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletTypeAdapter extends TypeAdapter<WalletType> {
  @override
  final int typeId = 4;

  @override
  WalletType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WalletType.personal;
      case 1:
        return WalletType.shared;
      case 2:
        return WalletType.family;
      case 3:
        return WalletType.business;
      default:
        return WalletType.personal;
    }
  }

  @override
  void write(BinaryWriter writer, WalletType obj) {
    switch (obj) {
      case WalletType.personal:
        writer.writeByte(0);
        break;
      case WalletType.shared:
        writer.writeByte(1);
        break;
      case WalletType.family:
        writer.writeByte(2);
        break;
      case WalletType.business:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletPermissionAdapter extends TypeAdapter<WalletPermission> {
  @override
  final int typeId = 5;

  @override
  WalletPermission read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WalletPermission.view;
      case 1:
        return WalletPermission.edit;
      case 2:
        return WalletPermission.admin;
      default:
        return WalletPermission.view;
    }
  }

  @override
  void write(BinaryWriter writer, WalletPermission obj) {
    switch (obj) {
      case WalletPermission.view:
        writer.writeByte(0);
        break;
      case WalletPermission.edit:
        writer.writeByte(1);
        break;
      case WalletPermission.admin:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletPermissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
