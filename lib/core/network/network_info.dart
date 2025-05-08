import 'package:connectivity_plus/connectivity_plus.dart';

/// Interfaz para verificar el estado de la conexión a Internet
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementación de NetworkInfo utilizando internet_connection_checker
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
