// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 11;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String?,
      currency: fields[3] as String,
      language: fields[4] as String,
      theme: fields[5] as String,
      biometricEnabled: fields[6] as bool,
      notificationsEnabled: fields[7] as bool,
      smsParsingEnabled: fields[8] as bool,
      cloudSyncEnabled: fields[9] as bool,
      cloudProvider: fields[10] as String?,
      categoryNotifications: (fields[11] as Map?)?.cast<String, bool>(),
      budgetAlertThreshold: fields[12] as double,
      showMotivationalQuotes: fields[13] as bool,
      favoriteCategories: (fields[14] as List?)?.cast<String>(),
      dateFormat: fields[15] as String,
      autoBackup: fields[16] as bool,
      backupFrequencyDays: fields[17] as int,
      lastBackup: fields[18] as DateTime?,
      profileImagePath: fields[19] as String?,
      createdAt: fields[20] as DateTime,
      updatedAt: fields[21] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.language)
      ..writeByte(5)
      ..write(obj.theme)
      ..writeByte(6)
      ..write(obj.biometricEnabled)
      ..writeByte(7)
      ..write(obj.notificationsEnabled)
      ..writeByte(8)
      ..write(obj.smsParsingEnabled)
      ..writeByte(9)
      ..write(obj.cloudSyncEnabled)
      ..writeByte(10)
      ..write(obj.cloudProvider)
      ..writeByte(11)
      ..write(obj.categoryNotifications)
      ..writeByte(12)
      ..write(obj.budgetAlertThreshold)
      ..writeByte(13)
      ..write(obj.showMotivationalQuotes)
      ..writeByte(14)
      ..write(obj.favoriteCategories)
      ..writeByte(15)
      ..write(obj.dateFormat)
      ..writeByte(16)
      ..write(obj.autoBackup)
      ..writeByte(17)
      ..write(obj.backupFrequencyDays)
      ..writeByte(18)
      ..write(obj.lastBackup)
      ..writeByte(19)
      ..write(obj.profileImagePath)
      ..writeByte(20)
      ..write(obj.createdAt)
      ..writeByte(21)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
