import 'package:equatable/equatable.dart';

class Utilities extends Equatable {
  final int num;
  final String id;
  final String name;
  final String icon;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String address;

  const Utilities({
    required this.num,
    required this.id,
    required this.name,
    required this.icon,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.address,
  });

  @override
  List<Object?> get props =>
      [num, id, name, icon, latitude, longitude, phoneNumber, address];
}
