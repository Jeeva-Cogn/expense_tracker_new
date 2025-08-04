// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SMSTransactionAdapter extends TypeAdapter<SMSTransaction> {
  @override
  final int typeId = 2;

  @override
  SMSTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SMSTransaction(
      id: fields[0] as String,
      rawMessage: fields[1] as String,
      amount: fields[2] as double,
      type: fields[3] as String,
      merchant: fields[4] as String?,
      category: fields[5] as String,
      date: fields[6] as DateTime,
      confidence: fields[7] as double,
      description: fields[8] as String,
      accountNumber: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SMSTransaction obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rawMessage)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.merchant)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.confidence)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.accountNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SMSTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
