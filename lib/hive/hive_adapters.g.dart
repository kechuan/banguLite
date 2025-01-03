// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final int typeId = 0;

  @override
  AppConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfig()
      ..currentThemeColor = fields[0] as BangumiThemeColor?
      ..fontScale = fields[1] as ScaleType?
      ..themeMode = fields[2] as ThemeMode?
      ..customColor = fields[3] as Color?
      ..isSelectedCustomColor = fields[5] as bool?
      ..isfollowThemeColor = fields[6] as bool?;
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.currentThemeColor)
      ..writeByte(1)
      ..write(obj.fontScale)
      ..writeByte(2)
      ..write(obj.themeMode)
      ..writeByte(3)
      ..write(obj.customColor)
      ..writeByte(5)
      ..write(obj.isSelectedCustomColor)
      ..writeByte(6)
      ..write(obj.isfollowThemeColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BangumiThemeColorAdapter extends TypeAdapter<BangumiThemeColor> {
  @override
  final int typeId = 1;

  @override
  BangumiThemeColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BangumiThemeColor.sea;
      case 1:
        return BangumiThemeColor.macha;
      case 2:
        return BangumiThemeColor.ruby;
      default:
        return BangumiThemeColor.sea;
    }
  }

  @override
  void write(BinaryWriter writer, BangumiThemeColor obj) {
    switch (obj) {
      case BangumiThemeColor.sea:
        writer.writeByte(0);
      case BangumiThemeColor.macha:
        writer.writeByte(1);
      case BangumiThemeColor.ruby:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BangumiThemeColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 2;

  @override
  ThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    switch (obj) {
      case ThemeMode.system:
        writer.writeByte(0);
      case ThemeMode.light:
        writer.writeByte(1);
      case ThemeMode.dark:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScaleTypeAdapter extends TypeAdapter<ScaleType> {
  @override
  final int typeId = 3;

  @override
  ScaleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScaleType.min;
      case 1:
        return ScaleType.less;
      case 2:
        return ScaleType.medium;
      case 3:
        return ScaleType.more;
      case 4:
        return ScaleType.max;
      default:
        return ScaleType.min;
    }
  }

  @override
  void write(BinaryWriter writer, ScaleType obj) {
    switch (obj) {
      case ScaleType.min:
        writer.writeByte(0);
      case ScaleType.less:
        writer.writeByte(1);
      case ScaleType.medium:
        writer.writeByte(2);
      case ScaleType.more:
        writer.writeByte(3);
      case ScaleType.max:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScaleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 4;

  @override
  Color read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Color(
      (fields[0] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
