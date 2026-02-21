sealed class Failure {
  const Failure(this.message);

  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
