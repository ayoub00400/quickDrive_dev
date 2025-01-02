// ignore_for_file: public_member_api_docs, sort_constructors_first
class EarningModel {
  bool? error;
  String? message;
  num? totalEarnings;
  num? totalMonthlyEarnings;
  num? totalTodayEarnings;

  EarningModel({
    this.error,
    this.message,
    this.totalEarnings,
    this.totalMonthlyEarnings,
    this.totalTodayEarnings,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) => EarningModel(
        error: json['error'] as bool?,
        message: json['message'] as String?,
        totalEarnings: json['total_earnings'],
        totalMonthlyEarnings: json['total_monthly_earnings'],
        totalTodayEarnings: json['total_today_earnings'],
      );

  Map<String, dynamic> toJson() => {
        'error': error,
        'message': message,
        'total_earnings': totalEarnings,
        'total_monthly_earnings': totalMonthlyEarnings,
        'total_today_earnings': totalTodayEarnings,
      };

  @override
  String toString() {
    return 'EarningModel(error: $error, message: $message, totalEarnings: $totalEarnings, totalMonthlyEarnings: $totalMonthlyEarnings, totalTodayEarnings: $totalTodayEarnings)';
  }
}
