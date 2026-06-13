// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'air_quality.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HourlyAirQualityAdapter extends TypeAdapter<HourlyAirQuality> {
  @override
  final int typeId = 0;

  @override
  HourlyAirQuality read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HourlyAirQuality(
      time: fields[0] as String,
      pm25: fields[1] as double,
      pm10: fields[2] as double,
      carbonMonoxide: fields[3] as double,
      nitrogenDioxide: fields[4] as double,
      ozone: fields[5] as double,
      dust: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HourlyAirQuality obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.pm25)
      ..writeByte(2)
      ..write(obj.pm10)
      ..writeByte(3)
      ..write(obj.carbonMonoxide)
      ..writeByte(4)
      ..write(obj.nitrogenDioxide)
      ..writeByte(5)
      ..write(obj.ozone)
      ..writeByte(6)
      ..write(obj.dust);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyAirQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedAirQualityDataAdapter extends TypeAdapter<CachedAirQualityData> {
  @override
  final int typeId = 1;

  @override
  CachedAirQualityData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedAirQualityData(
      cityKey: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      hourly: (fields[3] as List).cast<HourlyAirQuality>(),
      cachedAt: fields[4] as String,
      cityName: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CachedAirQualityData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.cityKey)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.hourly)
      ..writeByte(4)
      ..write(obj.cachedAt)
      ..writeByte(5)
      ..write(obj.cityName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedAirQualityDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
