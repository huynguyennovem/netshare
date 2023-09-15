import 'package:equatable/equatable.dart';

class ApiResponse extends Equatable {
  final String? message;
  final int? code;

  const ApiResponse({required this.message, required this.code});

  const ApiResponse.success() : this(message: 'Success', code: 200);

  const ApiResponse.fail() : this(message: 'Fail', code: 400);

  factory ApiResponse.fromJson(dynamic json) =>
      ApiResponse(message: json['message'], code: json['code']);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['code'] = code;
    return map;
  }

  @override
  List<Object?> get props => [message, code];
}
