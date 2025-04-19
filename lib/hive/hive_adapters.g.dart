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
      ..currentThemeColor = fields[0] as AppThemeColor?
      ..fontScale = fields[1] as ScaleType?
      ..themeMode = fields[2] as ThemeMode?
      ..customColor = fields[3] as Color?
      ..isSelectedCustomColor = fields[5] as bool?
      ..isFollowThemeColor = fields[6] as bool?
      ..isManuallyImageLoad = fields[7] as bool?;
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.isFollowThemeColor)
      ..writeByte(7)
      ..write(obj.isManuallyImageLoad);
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

class AppThemeColorAdapter extends TypeAdapter<AppThemeColor> {
  @override
  final int typeId = 1;

  @override
  AppThemeColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppThemeColor.sea;
      case 1:
        return AppThemeColor.macha;
      case 2:
        return AppThemeColor.ruby;
      case 3:
        return AppThemeColor.ice;
      default:
        return AppThemeColor.sea;
    }
  }

  @override
  void write(BinaryWriter writer, AppThemeColor obj) {
    switch (obj) {
      case AppThemeColor.sea:
        writer.writeByte(0);
      case AppThemeColor.macha:
        writer.writeByte(1);
      case AppThemeColor.ruby:
        writer.writeByte(2);
      case AppThemeColor.ice:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeColorAdapter &&
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

class StarBangumiDetailsAdapter extends TypeAdapter<StarBangumiDetails> {
  @override
  final int typeId = 5;

  @override
  StarBangumiDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StarBangumiDetails()
      ..name = fields[0] as String?
      ..coverUrl = fields[1] as String?
      ..eps = (fields[2] as num?)?.toInt()
      ..score = (fields[3] as num?)?.toDouble()
      ..airDate = fields[4] as String?
      ..airWeekday = fields[5] as String?
      ..bangumiID = (fields[7] as num?)?.toInt()
      ..joinDate = fields[8] as String?
      ..finishedDate = fields[9] as String?
      ..rank = (fields[10] as num?)?.toInt();
  }

  @override
  void write(BinaryWriter writer, StarBangumiDetails obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.coverUrl)
      ..writeByte(2)
      ..write(obj.eps)
      ..writeByte(3)
      ..write(obj.score)
      ..writeByte(4)
      ..write(obj.airDate)
      ..writeByte(5)
      ..write(obj.airWeekday)
      ..writeByte(7)
      ..write(obj.bangumiID)
      ..writeByte(8)
      ..write(obj.joinDate)
      ..writeByte(9)
      ..write(obj.finishedDate)
      ..writeByte(10)
      ..write(obj.rank);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StarBangumiDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoginedUserInformationsAdapter
    extends TypeAdapter<LoginedUserInformations> {
  @override
  final int typeId = 7;

  @override
  LoginedUserInformations read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginedUserInformations()
      ..accessToken = fields[0] as String?
      ..expiredTime = (fields[9] as num?)?.toInt()
      ..refreshToken = fields[10] as String?
      ..userInformation = fields[12] as UserInformation?
      ..turnsTileToken = fields[13] as String?;
  }

  @override
  void write(BinaryWriter writer, LoginedUserInformations obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(9)
      ..write(obj.expiredTime)
      ..writeByte(10)
      ..write(obj.refreshToken)
      ..writeByte(12)
      ..write(obj.userInformation)
      ..writeByte(13)
      ..write(obj.turnsTileToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginedUserInformationsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserInformationAdapter extends TypeAdapter<UserInformation> {
  @override
  final int typeId = 8;

  @override
  UserInformation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInformation(
      userID: (fields[0] as num?)?.toInt(),
    )
      ..userName = fields[1] as String?
      ..nickName = fields[2] as String?
      ..avatarUrl = fields[3] as String?
      ..sign = fields[4] as String?
      ..joinedAtTimeStamp = (fields[5] as num?)?.toInt()
      ..group = (fields[6] as num?)?.toInt();
  }

  @override
  void write(BinaryWriter writer, UserInformation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.userID)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.nickName)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.sign)
      ..writeByte(5)
      ..write(obj.joinedAtTimeStamp)
      ..writeByte(6)
      ..write(obj.group);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInformationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
