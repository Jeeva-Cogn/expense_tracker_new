// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinancialGoalAdapter extends TypeAdapter<FinancialGoal> {
  @override
  final int typeId = 7;

  @override
  FinancialGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinancialGoal(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as GoalType,
      targetAmount: fields[4] as double,
      currentAmount: fields[5] as double,
      targetDate: fields[6] as DateTime,
      startDate: fields[7] as DateTime,
      priority: fields[8] as GoalPriority,
      category: fields[9] as String,
      isActive: fields[10] as bool,
      milestones: (fields[11] as List).cast<GoalMilestone>(),
      color: fields[12] as String,
      iconEmoji: fields[13] as String?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FinancialGoal obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.targetAmount)
      ..writeByte(5)
      ..write(obj.currentAmount)
      ..writeByte(6)
      ..write(obj.targetDate)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.milestones)
      ..writeByte(12)
      ..write(obj.color)
      ..writeByte(13)
      ..write(obj.iconEmoji)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalMilestoneAdapter extends TypeAdapter<GoalMilestone> {
  @override
  final int typeId = 8;

  @override
  GoalMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalMilestone(
      id: fields[0] as String,
      name: fields[1] as String,
      targetAmount: fields[2] as double,
      isCompleted: fields[3] as bool,
      completedAt: fields[4] as DateTime?,
      completionNote: fields[5] as String?,
      reward: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GoalMilestone obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.completionNote)
      ..writeByte(6)
      ..write(obj.reward);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 9;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.savings;
      case 1:
        return GoalType.expenseReduction;
      case 2:
        return GoalType.investment;
      case 3:
        return GoalType.debtPayoff;
      case 4:
        return GoalType.incomeIncrease;
      case 5:
        return GoalType.emergency;
      default:
        return GoalType.savings;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.savings:
        writer.writeByte(0);
        break;
      case GoalType.expenseReduction:
        writer.writeByte(1);
        break;
      case GoalType.investment:
        writer.writeByte(2);
        break;
      case GoalType.debtPayoff:
        writer.writeByte(3);
        break;
      case GoalType.incomeIncrease:
        writer.writeByte(4);
        break;
      case GoalType.emergency:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalPriorityAdapter extends TypeAdapter<GoalPriority> {
  @override
  final int typeId = 10;

  @override
  GoalPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalPriority.low;
      case 1:
        return GoalPriority.medium;
      case 2:
        return GoalPriority.high;
      case 3:
        return GoalPriority.critical;
      default:
        return GoalPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, GoalPriority obj) {
    switch (obj) {
      case GoalPriority.low:
        writer.writeByte(0);
        break;
      case GoalPriority.medium:
        writer.writeByte(1);
        break;
      case GoalPriority.high:
        writer.writeByte(2);
        break;
      case GoalPriority.critical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
