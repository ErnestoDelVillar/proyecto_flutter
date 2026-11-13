/// Fallos del dominio. La capa data traduce a estos tipos
/// las excepciones de infraestructura.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No hay conexión con el servidor.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('El servidor tardó demasiado en responder.');
}

class RateLimitFailure extends Failure {
  const RateLimitFailure()
      : super('Demasiadas solicitudes. Intenta de nuevo más tarde.');
}

class ServerFailure extends Failure {
  const ServerFailure({this.statusCode})
      : super('El servidor respondió con un error.');

  final int? statusCode;
}

class GraphqlFailure extends Failure {
  const GraphqlFailure(super.message);
}

class InvalidDataFailure extends Failure {
  const InvalidDataFailure()
      : super('La respuesta del servidor no tiene el formato esperado.');
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super('Ocurrió un error inesperado.');
}