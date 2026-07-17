import 'package:equatable/equatable.dart';

/// Base failure type returned by repositories (functional error handling).
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'City not found.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred.']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Unable to determine your location.']);
}

class ApiKeyFailure extends Failure {
  const ApiKeyFailure([
    super.message = 'Invalid or missing API key. Check lib/core/constants/app_constants.dart.',
  ]);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([
    super.message = 'Too many requests — the weather API rate limit was hit. Try again shortly.',
  ]);
}
