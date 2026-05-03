// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectModelAdapter extends TypeAdapter<SubjectModel> {
  @override
  final int typeId = 0;

  @override
  SubjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectModel(
      id: fields[0] as String,
      name: fields[1] as String,
      color: fields[2] as String,
      icon: fields[3] as String,
      topics: (fields[4] as List).cast<TopicModel>(),
<<<<<<< HEAD
      totalTopics: fields[5] as int?,
      completedTopics: fields[6] as int?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
      chapters: (fields[9] as List).cast<ChapterModel>(),
      batch: fields[10] as String?,
=======
      totalTopics: fields[5] as int,
      completedTopics: fields[6] as int,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      chapters: (fields[9] as List).cast<ChapterModel>(),
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
    );
  }

  @override
  void write(BinaryWriter writer, SubjectModel obj) {
    writer
<<<<<<< HEAD
      ..writeByte(11)
=======
      ..writeByte(10)
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.topics)
      ..writeByte(5)
      ..write(obj.totalTopics)
      ..writeByte(6)
      ..write(obj.completedTopics)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
<<<<<<< HEAD
      ..write(obj.chapters)
      ..writeByte(10)
      ..write(obj.batch);
=======
      ..write(obj.chapters);
>>>>>>> 3a7f1f8f3040601e3ab37a111741457fabfb31f1
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
