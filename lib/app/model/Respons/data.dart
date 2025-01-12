// class DriverRidesResponse {
//   bool status;
//   String message;
//   List<NewDriverScheduledRide> newDriverScheduledRides;

//   DriverRidesResponse({required this.status, required this.message, required this.newDriverScheduledRides});

//   factory DriverRidesResponse.fromJson(Map<String, dynamic> json) {
//     return DriverRidesResponse(
//       status: json['status'],
//       message: json['message'],
//       newDriverScheduledRides: (json['newDriverScheduledRides'] as List)
//           .map((e) => NewDriverScheduledRide.fromJson(e))
//           .toList(),
//     );
//   }
// }

// class NewDriverScheduledRide {
//   int id;
//   int driverId;
//   int rideRequestId;
//   String status;
//   String createdAt;
//   String updatedAt;
//   RideRequest rideRequest;
//   Driver driver;

//   NewDriverScheduledRide({
//     required this.id,
//     required this.driverId,
//     required this.rideRequestId,
//     required this.status,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.rideRequest,
//     required this.driver,
//   });

//   factory NewDriverScheduledRide.fromJson(Map<String, dynamic> json) {
//     return NewDriverScheduledRide(
//       id: json['id'],
//       driverId: json['driver_id'],
//       rideRequestId: json['ride_request_id'],
//       status: json['status'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       rideRequest: RideRequest.fromJson(json['ride_request']),
//       driver: Driver.fromJson(json['driver']),
//     );
//   }
// }
// class RideRequest {
//   final String startAddress;
//   final String endAddress;

//   RideRequest({
//     required this.startAddress,
//     required this.endAddress,
//   });

//   factory RideRequest.fromJson(Map<String, dynamic> json) {
//     return RideRequest(
//       startAddress: json['start_address'] ?? 'Unknown Address',  // Default if null
//       endAddress: json['end_address'] ?? 'Unknown Address',      // Default if null
//     );
//   }
// }

// class Driver {
//   int id;
//   String firstName;
//   String lastName;
//   String email;
//   String username;
//   String countryCode;
//   String contactNumber;
//   String gender;
//   String? emailVerifiedAt;
//   String? address;
//   String userType;
//   String? playerId;
//   int serviceId;
//   String? fleetId;
//   String latitude;
//   String longitude;
//   String lastNotificationSeen;
//   String status;
//   bool isOnline;
//   bool isAvailable;
//   bool isVerifiedDriver;
//   String uid;
//   String? fcmToken;
//   String displayName;
//   String? loginType;
//   String timezone;
//   String lastActivedAt;
//   String appVersion;
//   String lastLocationUpdateAt;
//   String createdAt;
//   String updatedAt;
//   String? otpVerifyAt;
//   int stateId;
//   String? vehicleImage;
//   String? note;

//   Driver({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.username,
//     required this.countryCode,
//     required this.contactNumber,
//     required this.gender,
//     this.emailVerifiedAt,
//     this.address,
//     required this.userType,
//     this.playerId,
//     required this.serviceId,
//     this.fleetId,
//     required this.latitude,
//     required this.longitude,
//     required this.lastNotificationSeen,
//     required this.status,
//     required this.isOnline,
//     required this.isAvailable,
//     required this.isVerifiedDriver,
//     required this.uid,
//     this.fcmToken,
//     required this.displayName,
//     this.loginType,
//     required this.timezone,
//     required this.lastActivedAt,
//     required this.appVersion,
//     required this.lastLocationUpdateAt,
//     required this.createdAt,
//     required this.updatedAt,
//     this.otpVerifyAt,
//     required this.stateId,
//     this.vehicleImage,
//     this.note,
//   });

//   factory Driver.fromJson(Map<String, dynamic> json) {
//     return Driver(
//       id: json['id'],
//       firstName: json['first_name'],
//       lastName: json['last_name'],
//       email: json['email'],
//       username: json['username'],
//       countryCode: json['country_code'],
//       contactNumber: json['contact_number'],
//       gender: json['gender'],
//       emailVerifiedAt: json['email_verified_at'],
//       address: json['address'],
//       userType: json['user_type'],
//       playerId: json['player_id'],
//       serviceId: json['service_id'],
//       fleetId: json['fleet_id'],
//       latitude: json['latitude'],
//       longitude: json['longitude'],
//       lastNotificationSeen: json['last_notification_seen'],
//       status: json['status'],
//       isOnline: json['is_online'] == 1,
//       isAvailable: json['is_available'] == 1,
//       isVerifiedDriver: json['is_verified_driver'] == 1,
//       uid: json['uid'],
//       fcmToken: json['fcm_token'],
//       displayName: json['display_name'],
//       loginType: json['login_type'],
//       timezone: json['timezone'],
//       lastActivedAt: json['last_actived_at'],
//       appVersion: json['app_version'],
//       lastLocationUpdateAt: json['last_location_update_at'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       otpVerifyAt: json['otp_verify_at'],
//       stateId: json['state_id'],
//       vehicleImage: json['vehicle_image'],
//       note: json['note'],
//     );
//   }
// }
