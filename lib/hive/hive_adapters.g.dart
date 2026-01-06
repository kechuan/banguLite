// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final typeId = 0;

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
      ..isManuallyImageLoad = fields[7] as bool?
      ..isUpdateAlert = fields[8] as bool?;
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.isManuallyImageLoad)
      ..writeByte(8)
      ..write(obj.isUpdateAlert);
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
  final typeId = 1;

  @override
  AppThemeColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppThemeColor.ice;
      case 1:
        return AppThemeColor.macha;
      case 2:
        return AppThemeColor.sea;
      case 3:
        return AppThemeColor.ruby;
      default:
        return AppThemeColor.ice;
    }
  }

  @override
  void write(BinaryWriter writer, AppThemeColor obj) {
    switch (obj) {
      case AppThemeColor.ice:
        writer.writeByte(0);
      case AppThemeColor.macha:
        writer.writeByte(1);
      case AppThemeColor.sea:
        writer.writeByte(2);
      case AppThemeColor.ruby:
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
  final typeId = 2;

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
  final typeId = 3;

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
  final typeId = 4;

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
      ..write(obj.toARGB32());
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
  final typeId = 5;

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
  final typeId = 7;

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
  final typeId = 8;

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

class SurfTimelineDetailsAdapter extends TypeAdapter<SurfTimelineDetails> {
  @override
  final typeId = 10;

  @override
  SurfTimelineDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurfTimelineDetails(
      detailID: (fields[7] as num?)?.toInt(),
    )
      ..commentDetails = fields[0] as CommentDetails?
      ..title = fields[1] as String?
      ..bangumiSurfTimelineType = fields[2] as BangumiSurfTimelineType?
      ..sourceTitle = fields[3] as String?
      ..sourceID = fields[4] as dynamic
      ..replies = (fields[5] as num?)?.toInt()
      ..updatedAt = (fields[6] as num?)?.toInt();
  }

  @override
  void write(BinaryWriter writer, SurfTimelineDetails obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.commentDetails)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.bangumiSurfTimelineType)
      ..writeByte(3)
      ..write(obj.sourceTitle)
      ..writeByte(4)
      ..write(obj.sourceID)
      ..writeByte(5)
      ..write(obj.replies)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.detailID);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurfTimelineDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommentDetailsAdapter extends TypeAdapter<CommentDetails> {
  @override
  final typeId = 11;

  @override
  CommentDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CommentDetails(
      commentID: (fields[3] as num?)?.toInt(),
    )
      ..rate = (fields[0] as num?)?.toInt()
      ..type = fields[1] as StarType?
      ..contentID = (fields[2] as num?)?.toInt()
      ..userInformation = fields[4] as UserInformation?
      ..comment = fields[5] as String?
      ..commentTimeStamp = (fields[6] as num?)?.toInt()
      ..commentReactions = (fields[7] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry((k as num).toInt(), (v as Set).cast<String>()));
  }

  @override
  void write(BinaryWriter writer, CommentDetails obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.rate)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.contentID)
      ..writeByte(3)
      ..write(obj.commentID)
      ..writeByte(4)
      ..write(obj.userInformation)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.commentTimeStamp)
      ..writeByte(7)
      ..write(obj.commentReactions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BangumiSurfTimelineTypeAdapter
    extends TypeAdapter<BangumiSurfTimelineType> {
  @override
  final typeId = 12;

  @override
  BangumiSurfTimelineType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BangumiSurfTimelineType.all;
      case 1:
        return BangumiSurfTimelineType.subject;
      case 2:
        return BangumiSurfTimelineType.group;
      case 3:
        return BangumiSurfTimelineType.timeline;
      default:
        return BangumiSurfTimelineType.all;
    }
  }

  @override
  void write(BinaryWriter writer, BangumiSurfTimelineType obj) {
    switch (obj) {
      case BangumiSurfTimelineType.all:
        writer.writeByte(0);
      case BangumiSurfTimelineType.subject:
        writer.writeByte(1);
      case BangumiSurfTimelineType.group:
        writer.writeByte(2);
      case BangumiSurfTimelineType.timeline:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BangumiSurfTimelineTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StarTypeAdapter extends TypeAdapter<StarType> {
  @override
  final typeId = 13;

  @override
  StarType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StarType.want;
      case 1:
        return StarType.watched;
      case 2:
        return StarType.watching;
      case 3:
        return StarType.delay;
      case 4:
        return StarType.deprecated;
      case 5:
        return StarType.none;
      default:
        return StarType.want;
    }
  }

  @override
  void write(BinaryWriter writer, StarType obj) {
    switch (obj) {
      case StarType.want:
        writer.writeByte(0);
      case StarType.watched:
        writer.writeByte(1);
      case StarType.watching:
        writer.writeByte(2);
      case StarType.delay:
        writer.writeByte(3);
      case StarType.deprecated:
        writer.writeByte(4);
      case StarType.none:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StarTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
