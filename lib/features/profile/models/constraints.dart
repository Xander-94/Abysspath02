// 约束条件层模型
class Constraints {
  final TimeAvailability? timeAvailability;               // 时间可用性 (已有)
  final List<String>? preferredDevices;                 // 偏好设备 (新增)
  final List<String>? acceptedInvestment;               // 可接受投入 (新增)
  final List<String>? preferredLearningTimes;           // 偏好学习时段 (新增)

  const Constraints({
    this.timeAvailability,
    this.preferredDevices,                             // 新增
    this.acceptedInvestment,                           // 新增
    this.preferredLearningTimes,                       // 新增
  });

  Constraints copyWith({
    TimeAvailability? timeAvailability,
    List<String>? preferredDevices,                     // 新增
    List<String>? acceptedInvestment,                   // 新增
    List<String>? preferredLearningTimes,               // 新增
  }) => Constraints(
    timeAvailability: timeAvailability ?? this.timeAvailability,
    preferredDevices: preferredDevices ?? this.preferredDevices,         // 新增
    acceptedInvestment: acceptedInvestment ?? this.acceptedInvestment,     // 新增
    preferredLearningTimes: preferredLearningTimes ?? this.preferredLearningTimes, // 新增
  );

  factory Constraints.fromJson(Map<String, dynamic>? json) => Constraints(
    timeAvailability: json?['time_availability'] == null ? null : TimeAvailability.fromJson(json!['time_availability']),
    // 新增
    preferredDevices: json?['preferred_devices'] == null ? null : List<String>.from(json!['preferred_devices']),
    acceptedInvestment: json?['accepted_investment'] == null ? null : List<String>.from(json!['accepted_investment']),
    preferredLearningTimes: json?['preferred_learning_times'] == null ? null : List<String>.from(json!['preferred_learning_times']),
  );

  Map<String, dynamic> toJson() => {
    'time_availability': timeAvailability?.toJson(),
    'preferred_devices': preferredDevices,                 // 新增
    'accepted_investment': acceptedInvestment,             // 新增
    'preferred_learning_times': preferredLearningTimes,       // 新增
  }..removeWhere((_, v) => v == null);
}


// 时间可用性
class TimeAvailability {
  final int? weeklyHours;                             // 每周可用小时数
  final List<String>? blockedPeriods;                   // 不可用时段列表

  const TimeAvailability({this.weeklyHours, this.blockedPeriods});

  factory TimeAvailability.fromJson(Map<String, dynamic>? json) => TimeAvailability(
    weeklyHours: json?['weekly_hours'],
    blockedPeriods: json?['blocked_periods'] == null ? null : List<String>.from(json!['blocked_periods']),
  );

  Map<String, dynamic> toJson() => {
    'weekly_hours': weeklyHours,
    'blocked_periods': blockedPeriods,
  }..removeWhere((_, v) => v == null);
}


// 资源限制
class ResourceConstraints {
  final List<String>? allowedFormats;                  // 允许内容格式
  final List<String>? deviceTypes;                     // 允许设备类型

  const ResourceConstraints({this.allowedFormats, this.deviceTypes});

  factory ResourceConstraints.fromJson(Map<String, dynamic>? json) => ResourceConstraints(
    allowedFormats: json?['allowed_formats'] == null ? null : List<String>.from(json!['allowed_formats']),
    deviceTypes: json?['device_types'] == null ? null : List<String>.from(json!['device_types']),
  );

  Map<String, dynamic> toJson() => {
    'allowed_formats': allowedFormats,
    'device_types': deviceTypes,
  }..removeWhere((_, v) => v == null);
} 