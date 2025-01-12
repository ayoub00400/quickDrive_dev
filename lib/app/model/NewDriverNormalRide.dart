import 'NewDriverScheduledRide2.dart';
import 'Respons/data.dart';

class NewDriverNormalRide {
  final int? id;
  final int? driverId;
  final int? rideRequestId;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? dataCoupon;
  final List<int>? requestedDriverIds;
  final Driver? driver;
  final RideRequest? rideRequest;

  NewDriverNormalRide({
    this.id,
    this.driverId,
    this.rideRequestId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.dataCoupon,
    this.requestedDriverIds,
    this.driver,
    this.rideRequest,
  });

  factory NewDriverNormalRide.fromJson(Map<String, dynamic> json) {
    return NewDriverNormalRide(
      id: json['id'],
      driverId: json['driver_id'],
      rideRequestId: json['ride_request_id'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      dataCoupon: json['data_coupon'],
      requestedDriverIds: json['requested_driver_ids'] != null
          ? (json['requested_driver_ids'] as String)
              .replaceAll(RegExp(r'[\[\]]'), '')
              .split(',')
              .map((e) => int.parse(e.trim()))
              .toList()
          : null,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
      rideRequest: json['ride_request'] != null ? RideRequest.fromJson(json['ride_request']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'ride_request_id': rideRequestId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'data_coupon': dataCoupon,
      'requested_driver_ids': requestedDriverIds?.toString(),
      'driver': driver?.toJson(),
      // 'ride_request': rideRequest?.toJson(),
    };
  }
}

class Driver {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? username;
  final String? countryCode;
  final String? contactNumber;
  final String? gender;
  final String? emailVerifiedAt;
  final String? address;
  final String? userType;
  final String? playerId;
  final int? serviceId;
  final String? latitude;
  final String? longitude;
  final String? lastNotificationSeen;
  final String? status;
  final bool? isOnline;
  final bool? isAvailable;
  final bool? isVerifiedDriver;
  final String? uid;
  final String? fcmToken;
  final String? displayName;
  final String? loginType;
  final String? timezone;
  final String? lastActivedAt;
  final String? appVersion;
  final String? lastLocationUpdateAt;
  final String? createdAt;
  final String? updatedAt;
  final String? otpVerifyAt;
  final int? stateId;
  final String? vehicleImage;
  final String? note;

  Driver({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.username,
    this.countryCode,
    this.contactNumber,
    this.gender,
    this.emailVerifiedAt,
    this.address,
    this.userType,
    this.playerId,
    this.serviceId,
    this.latitude,
    this.longitude,
    this.lastNotificationSeen,
    this.status,
    this.isOnline,
    this.isAvailable,
    this.isVerifiedDriver,
    this.uid,
    this.fcmToken,
    this.displayName,
    this.loginType,
    this.timezone,
    this.lastActivedAt,
    this.appVersion,
    this.lastLocationUpdateAt,
    this.createdAt,
    this.updatedAt,
    this.otpVerifyAt,
    this.stateId,
    this.vehicleImage,
    this.note,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      username: json['username'],
      countryCode: json['country_code'],
      contactNumber: json['contact_number'],
      gender: json['gender'],
      emailVerifiedAt: json['email_verified_at'],
      address: json['address'],
      userType: json['user_type'],
      playerId: json['player_id'],
      serviceId: json['service_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lastNotificationSeen: json['last_notification_seen'],
      status: json['status'],
      isOnline: json['is_online'] == 1,
      isAvailable: json['is_available'] == 1,
      isVerifiedDriver: json['is_verified_driver'] == 1,
      uid: json['uid'],
      fcmToken: json['fcm_token'],
      displayName: json['display_name'],
      loginType: json['login_type'],
      timezone: json['timezone'],
      lastActivedAt: json['last_actived_at'],
      appVersion: json['app_version'],
      lastLocationUpdateAt: json['last_location_update_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      otpVerifyAt: json['otp_verify_at'],
      stateId: json['state_id'],
      vehicleImage: json['vehicle_image'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'username': username,
      'country_code': countryCode,
      'contact_number': contactNumber,
      'gender': gender,
      'email_verified_at': emailVerifiedAt,
      'address': address,
      'user_type': userType,
      'player_id': playerId,
      'service_id': serviceId,
      'latitude': latitude,
      'longitude': longitude,
      'last_notification_seen': lastNotificationSeen,
      'status': status,
      'is_online': isOnline == true ? 1 : 0,
      'is_available': isAvailable == true ? 1 : 0,
      'is_verified_driver': isVerifiedDriver == true ? 1 : 0,
      'uid': uid,
      'fcm_token': fcmToken,
      'display_name': displayName,
      'login_type': loginType,
      'timezone': timezone,
      'last_actived_at': lastActivedAt,
      'app_version': appVersion,
      'last_location_update_at': lastLocationUpdateAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'otp_verify_at': otpVerifyAt,
      'state_id': stateId,
      'vehicle_image': vehicleImage,
      'note': note,
    };
  }
}
