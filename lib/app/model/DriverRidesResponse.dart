import 'NewDriverNormalRide.dart';
import 'NewDriverScheduledRide2.dart';
 

class DriverRidesResponse {
  final bool status;
  final String message;
  final List<NewDriverNormalRide> newDriverNormalRides;
  final List<NewDriverScheduledRide> newDriverScheduledRides;

  DriverRidesResponse({
    required this.status,
    required this.message,
    required this.newDriverNormalRides,
    required this.newDriverScheduledRides,
  });

  factory DriverRidesResponse.fromJson(Map<String, dynamic> json) {
    return DriverRidesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      newDriverNormalRides: (json['newDriverNormalRides'] as List<dynamic>?)
              ?.map((item) => NewDriverNormalRide.fromJson(item))
              .toList() ??
          [],
      newDriverScheduledRides: (json['newDriverScheduledRides'] as List<dynamic>?)
              ?.map((item) => NewDriverScheduledRide.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'newDriverNormalRides': newDriverNormalRides.map((ride) => ride.toJson()).toList(),
      'newDriverScheduledRides': newDriverScheduledRides.map((ride) => ride.toJson()).toList(),
    };
  }
}
 