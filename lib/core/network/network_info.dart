import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Interfaz para verificar el estado de la conexión a Internet
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementación de NetworkInfo utilizando internet_connection_checker
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
