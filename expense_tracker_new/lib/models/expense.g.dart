// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      category: fields[3] as String,
      subcategory: fields[4] as String?,
      date: fields[5] as DateTime,
      note: fields[6] as String?,
      receiptImagePath: fields[7] as String?,
      type: fields[8] as ExpenseType,
      walletId: fields[9] as String?,
      isRecurring: fields[10] as bool,
      recurringType: fields[11] as RecurringType?,
      smsSource: fields[12] as String?,
      splits: (fields[13] as Map?)?.cast<String, double>(),
      isSynced: fields[14] as bool,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.subcategory)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.receiptImagePath)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.walletId)
      ..writeByte(10)
      ..write(obj.isRecurring)
      ..writeByte(11)
      ..write(obj.recurringType)
      ..writeByte(12)
      ..write(obj.smsSource)
      ..writeByte(13)
      ..write(obj.splits)
      ..writeByte(14)
      ..write(obj.isSynced)
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
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExpenseTypeAdapter extends TypeAdapter<ExpenseType> {
  @override
  final int typeId = 1;

  @override
  ExpenseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseType.income;
      case 1:
        return ExpenseType.expense;
      case 2:
        return ExpenseType.transfer;
      default:
        return ExpenseType.income;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseType obj) {
    switch (obj) {
      case ExpenseType.income:
        writer.writeByte(0);
        break;
      case ExpenseType.expense:
        writer.writeByte(1);
        break;
      case ExpenseType.transfer:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringTypeAdapter extends TypeAdapter<RecurringType> {
  @override
  final int typeId = 4;

  @override
  RecurringType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurringType.daily;
      case 1:
        return RecurringType.weekly;
      case 2:
        return RecurringType.monthly;
      case 3:
        return RecurringType.yearly;
      default:
        return RecurringType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurringType obj) {
    switch (obj) {
      case RecurringType.daily:
        writer.writeByte(0);
        break;
      case RecurringType.weekly:
        writer.writeByte(1);
        break;
      case RecurringType.monthly:
        writer.writeByte(2);
        break;
      case RecurringType.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
