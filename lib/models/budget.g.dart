// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 2;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Budget(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      limit: fields[3] as double,
      spent: fields[4] as double,
      period: fields[5] as BudgetPeriod,
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime,
      walletId: fields[8] as String?,
      alertsEnabled: fields[9] as bool,
      alertThreshold: fields[10] as double,
      color: fields[11] as String,
      isActive: fields[12] as bool,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      type: fields[15] as BudgetType,
      excludedSubcategories: (fields[16] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.limit)
      ..writeByte(4)
      ..write(obj.spent)
      ..writeByte(5)
      ..write(obj.period)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.walletId)
      ..writeByte(9)
      ..write(obj.alertsEnabled)
      ..writeByte(10)
      ..write(obj.alertThreshold)
      ..writeByte(11)
      ..write(obj.color)
      ..writeByte(12)
      ..write(obj.isActive)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.type)
      ..writeByte(16)
      ..write(obj.excludedSubcategories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
