// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillReminderAdapter extends TypeAdapter<BillReminder> {
  @override
  final int typeId = 9;

  @override
  BillReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillReminder(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      amount: fields[3] as double,
      category: fields[4] as String,
      dueDate: fields[5] as DateTime,
      frequency: fields[6] as ReminderFrequency,
      reminderDays: (fields[7] as List?)?.cast<int>(),
      isActive: fields[8] as bool,
      autoAddExpense: fields[9] as bool,
      walletId: fields[10] as String?,
      lastPaid: fields[11] as DateTime?,
      nextDue: fields[12] as DateTime?,
      color: fields[13] as String,
      icon: fields[14] as String,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BillReminder obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.frequency)
      ..writeByte(7)
      ..write(obj.reminderDays)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.autoAddExpense)
      ..writeByte(10)
      ..write(obj.walletId)
      ..writeByte(11)
      ..write(obj.lastPaid)
      ..writeByte(12)
      ..write(obj.nextDue)
      ..writeByte(13)
      ..write(obj.color)
      ..writeByte(14)
      ..write(obj.icon)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderFrequencyAdapter extends TypeAdapter<ReminderFrequency> {
  @override
  final int typeId = 10;

  @override
  ReminderFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderFrequency.weekly;
      case 1:
        return ReminderFrequency.monthly;
      case 2:
        return ReminderFrequency.quarterly;
      case 3:
        return ReminderFrequency.yearly;
      case 4:
        return ReminderFrequency.custom;
      default:
        return ReminderFrequency.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderFrequency obj) {
    switch (obj) {
      case ReminderFrequency.weekly:
        writer.writeByte(0);
        break;
      case ReminderFrequency.monthly:
        writer.writeByte(1);
        break;
      case ReminderFrequency.quarterly:
        writer.writeByte(2);
        break;
      case ReminderFrequency.yearly:
        writer.writeByte(3);
        break;
      case ReminderFrequency.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
