enum TipoSuscripcion { general, especial, premium }

extension TipoSuscripcionExtension on TipoSuscripcion {
  String get value {
    switch (this) {
      case TipoSuscripcion.general:
        return 'general';
      case TipoSuscripcion.especial:
        return 'especial';
      case TipoSuscripcion.premium:
        return 'premium';
    }
  }

  static TipoSuscripcion fromString(String value) {
    switch (value) {
      case 'especial':
        return TipoSuscripcion.especial;
      case 'premium':
        return TipoSuscripcion.premium;
      case 'general':
      default:
        return TipoSuscripcion.general;
    }
  }
}

enum EstadoPedido { pendiente, aceptado, encamino, entregado, cancelado }

extension EstadoPedidoExtension on EstadoPedido {
  String get value {
    switch (this) {
      case EstadoPedido.pendiente:
        return 'pendiente';
      case EstadoPedido.aceptado:
        return 'aceptado';
      case EstadoPedido.encamino:
        return 'en_camino';
      case EstadoPedido.entregado:
        return 'entregado';
      case EstadoPedido.cancelado:
        return 'cancelado';
    }
  }

  static EstadoPedido fromString(String value) {
    switch (value) {
      case 'aceptado':
        return EstadoPedido.aceptado;
      case 'en_camino':
        return EstadoPedido.encamino;
      case 'entregado':
        return EstadoPedido.entregado;
      case 'cancelado':
        return EstadoPedido.cancelado;
      case 'pendiente':
      default:
        return EstadoPedido.pendiente;
    }
  }
}

enum MetodoEntrega { delivery, pickup }

extension MetodoEntregaExtension on MetodoEntrega {
  String get value {
    switch (this) {
      case MetodoEntrega.delivery:
        return 'delivery';
      case MetodoEntrega.pickup:
        return 'pickup';
    }
  }

  static MetodoEntrega fromString(String value) {
    switch (value) {
      case 'pickup':
        return MetodoEntrega.pickup;
      case 'delivery':
      default:
        return MetodoEntrega.delivery;
    }
  }
}
