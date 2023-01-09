import 'package:equatable/equatable.dart';

class ApiError extends Equatable {
  final String? message;
  final int? code;

  const ApiError(this.message, this.code);

  const ApiError.empty() : this('no data found', 404);

  const ApiError.unknown() : this('Unknown error', 400);

  @override
  List<Object?> get props => [message, code];
}
