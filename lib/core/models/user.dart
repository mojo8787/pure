import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  @JsonValue('customer')
  customer,
  @JsonValue('technician')
  technician,
  @JsonValue('admin')
  admin,
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    @Default(UserRole.customer) UserRole role,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class CustomerProfile with _$CustomerProfile {
  const factory CustomerProfile({
    required String userId,
    required String address,
    required String phone,
    String? city,
    String? postalCode,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _CustomerProfile;

  factory CustomerProfile.fromJson(Map<String, dynamic> json) => 
      _$CustomerProfileFromJson(json);
}

@freezed
class TechnicianProfile with _$TechnicianProfile {
  const factory TechnicianProfile({
    required String userId,
    required String region,
    @JsonKey(name: 'vehicle_plate') String? vehiclePlate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _TechnicianProfile;

  factory TechnicianProfile.fromJson(Map<String, dynamic> json) => 
      _$TechnicianProfileFromJson(json);
} 