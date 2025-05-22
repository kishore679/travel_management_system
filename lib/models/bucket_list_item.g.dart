// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket_list_item.dart';

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
      name: fields[0] as String,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      category: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.category);
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

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 1;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      description: fields[0] as String,
      isCompleted: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BucketListItemAdapter extends TypeAdapter<BucketListItem> {
  @override
  final int typeId = 2;

  @override
  BucketListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BucketListItem(
      name: fields[0] as String,
      description: fields[1] as String,
      category: fields[2] as String,
      startDate: fields[3] as DateTime?,
      targetedDate: fields[4] as DateTime?,
      packingList: (fields[5] as List?)?.cast<String>(),
      estimatedBudget: fields[6] as double?,
      dreamingTimeSpan: fields[7] as String?,
      endDate: fields[8] as DateTime?,
      spentBudget: fields[9] as double?,
      expenses: (fields[10] as List?)?.cast<Expense>(),
      activities: (fields[11] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      tripNotes: fields[12] as String?,
      mediaFiles: (fields[13] as List?)?.cast<String>(),
      tripDiary: fields[14] as String?,
      endLocation: fields[15] as String?,
      startLocation: fields[16] as String,
      goals: (fields[17] as List?)?.cast<Goal>(),
    );
  }

  @override
  void write(BinaryWriter writer, BucketListItem obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.targetedDate)
      ..writeByte(5)
      ..write(obj.packingList)
      ..writeByte(6)
      ..write(obj.estimatedBudget)
      ..writeByte(7)
      ..write(obj.dreamingTimeSpan)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.spentBudget)
      ..writeByte(10)
      ..write(obj.expenses)
      ..writeByte(11)
      ..write(obj.activities)
      ..writeByte(12)
      ..write(obj.tripNotes)
      ..writeByte(13)
      ..write(obj.mediaFiles)
      ..writeByte(14)
      ..write(obj.tripDiary)
      ..writeByte(15)
      ..write(obj.endLocation)
      ..writeByte(16)
      ..write(obj.startLocation)
      ..writeByte(17)
      ..write(obj.goals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BucketListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
