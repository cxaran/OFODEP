import 'package:uuid/uuid.dart';

String newRandomSeed() {
  return const Uuid().v4().substring(0, 8);
}

class ParamsComponent {
  const ParamsComponent();

  Map<String, dynamic>? toMap() => null;

  ParamsComponent copyWith() => ParamsComponent();
}
