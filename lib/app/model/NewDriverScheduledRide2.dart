class NewDriverScheduledRide {
  final int id;
  final int driverId;
  final int rideRequestId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final RideRequest rideRequest;

  NewDriverScheduledRide({
    required this.id,
    required this.driverId,
    required this.rideRequestId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.rideRequest,
  });

  factory NewDriverScheduledRide.fromJson(Map<String, dynamic> json) {
    return NewDriverScheduledRide(
      id: json['id'],
      driverId: json['driver_id'],
      rideRequestId: json['ride_request_id'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      rideRequest: RideRequest.fromJson(json['ride_request']),
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
      'ride_request': rideRequest.toJson(),
    };
  }
}

class RideRequest {
  final int id;
  final int riderId;
  final int serviceId;
  final String datetime;
  final int isSchedule;
  final int rideAttempt;
  final double? startLatitude;
  final double? startLongitude;
  final String startAddress;
  final double? endLatitude;
  final double? endLongitude;
  final String endAddress;
  final int seatCount;
  final String status;

  RideRequest({
    required this.id,
    required this.riderId,
    required this.serviceId,
    required this.datetime,
    required this.isSchedule,
    required this.rideAttempt,
    required this.startLatitude,
    required this.startLongitude,
    required this.startAddress,
    required this.endLatitude,
    required this.endLongitude,
    required this.endAddress,
    required this.seatCount,
    required this.status,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'],
      riderId: json['rider_id'],
      serviceId: json['service_id'],
      datetime: json['datetime'],
      isSchedule: json['is_schedule'],
      rideAttempt: json['ride_attempt'],
      startLatitude: json['start_latitude'] != null
          ? double.tryParse(json['start_latitude'])
          : null,
      startLongitude: json['start_longitude'] != null
          ? double.tryParse(json['start_longitude'])
          : null,
      startAddress: json['start_address'],
      endLatitude: json['end_latitude'] != null
          ? double.tryParse(json['end_latitude'])
          : null,
      endLongitude: json['end_longitude'] != null
          ? double.tryParse(json['end_longitude'])
          : null,
      endAddress: json['end_address'],
      seatCount: json['seat_count'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rider_id': riderId,
      'service_id': serviceId,
      'datetime': datetime,
      'is_schedule': isSchedule,
      'ride_attempt': rideAttempt,
      'start_latitude': startLatitude?.toString(),
      'start_longitude': startLongitude?.toString(),
      'start_address': startAddress,
      'end_latitude': endLatitude?.toString(),
      'end_longitude': endLongitude?.toString(),
      'end_address': endAddress,
      'seat_count': seatCount,
      'status': status,
    };
  }
}
