import 'package:intl/intl.dart';
import 'package:ofodep/models/country_timezone.dart';
import 'package:ofodep/widgets/gap.dart';

const List<CountryTimezone> timeZonesLatAm = [
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/Buenos_Aires'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/Catamarca'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/Cordoba'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/Jujuy'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/La_Rioja'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/Mendoza'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/Rio_Gallegos'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/Salta'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/San_Juan'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/San_Luis'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/Tucuman'),
  CountryTimezone(country: 'AR', timezone: 'America/Argentina/Ushuaia'),
  CountryTimezone(country: 'PY', timezone: 'America/Asuncion'),
  CountryTimezone(country: 'CO', timezone: 'America/Bogota'),
  CountryTimezone(country: 'VE', timezone: 'America/Caracas'),
  CountryTimezone(country: 'GF', timezone: 'America/Cayenne'),
  CountryTimezone(country: 'GY', timezone: 'America/Guyana'),
  CountryTimezone(country: 'CU', timezone: 'America/Havana'),
  CountryTimezone(country: 'JM', timezone: 'America/Jamaica'),
  CountryTimezone(country: 'BO', timezone: 'America/La_Paz'),
  CountryTimezone(country: 'PE', timezone: 'America/Lima'),
  CountryTimezone(country: 'NI', timezone: 'America/Managua'),
  CountryTimezone(country: 'BR', timezone: 'America/Manaus'),
  CountryTimezone(country: 'MX', timezone: 'America/Mexico_City'),
  CountryTimezone(country: 'MX', timezone: 'America/Monterrey'),
  CountryTimezone(country: 'MX', timezone: 'America/Mazatlan'),
  CountryTimezone(country: 'MX', timezone: 'America/Merida'),
  CountryTimezone(country: 'MX', timezone: 'America/Chihuahua'),
  CountryTimezone(country: 'MX', timezone: 'America/Ojinaga'),
  CountryTimezone(country: 'MX', timezone: 'America/Hermosillo'),
  CountryTimezone(country: 'MX', timezone: 'America/Bahia_Banderas'),
  CountryTimezone(country: 'MX', timezone: 'America/Tijuana'),
  CountryTimezone(country: 'MX', timezone: 'America/Nassau'),
  CountryTimezone(country: 'BS', timezone: 'America/Nassau'),
  CountryTimezone(country: 'PA', timezone: 'America/Panama'),
  CountryTimezone(country: 'SR', timezone: 'America/Paramaribo'),
  CountryTimezone(country: 'HT', timezone: 'America/Port-au-Prince'),
  CountryTimezone(country: 'TT', timezone: 'America/Port_of_Spain'),
  CountryTimezone(country: 'PR', timezone: 'America/Puerto_Rico'),
  CountryTimezone(country: 'CR', timezone: 'America/Regina'),
  CountryTimezone(country: 'DO', timezone: 'America/Santiago'),
  CountryTimezone(country: 'DO', timezone: 'America/Santo_Domingo'),
  CountryTimezone(country: 'AR', timezone: 'America/Sao_Paulo'),
  CountryTimezone(country: 'SV', timezone: 'America/El_Salvador'),
  CountryTimezone(country: 'AR', timezone: 'America/San_Juan'),
  CountryTimezone(country: 'AR', timezone: 'America/San_Luis'),
  CountryTimezone(country: 'EC', timezone: 'America/Guayaquil'),
];

class Currency {
  final String code;
  final String description;

  const Currency({required this.code, required this.description});
}

const List<Currency> americanCurrencies = [
  // América del Norte
  Currency(code: 'MXN', description: 'Peso mexicano'),
  Currency(code: 'USD', description: 'Dólar estadounidense'),
  Currency(code: 'CAD', description: 'Dólar canadiense'),

  // América Central
  Currency(code: 'GTQ', description: 'Quetzal (Guatemala)'),
  Currency(code: 'HNL', description: 'Lempira (Honduras)'),
  Currency(code: 'NIO', description: 'Córdoba (Nicaragua)'),
  Currency(code: 'CRC', description: 'Colón costarricense'),
  Currency(code: 'PAB', description: 'Balboa (Panamá)'),
  Currency(code: 'BZD', description: 'Dólar beliceño'),

  // Caribe
  Currency(code: 'CUP', description: 'Peso cubano'),
  Currency(code: 'DOP', description: 'Peso dominicano'),
  Currency(code: 'HTG', description: 'Gourde (Haití)'),
  Currency(code: 'JMD', description: 'Dólar jamaiquino'),
  Currency(code: 'BSD', description: 'Dólar bahameño'),
  Currency(code: 'BBD', description: 'Dólar barbadense'),
  Currency(code: 'TTD', description: 'Dólar trinitense'),
  Currency(code: 'XCD', description: 'Dólar del Caribe Oriental'),

  // América del Sur
  Currency(code: 'ARS', description: 'Peso argentino'),
  Currency(code: 'BOB', description: 'Boliviano'),
  Currency(code: 'BRL', description: 'Real brasileño'),
  Currency(code: 'CLP', description: 'Peso chileno'),
  Currency(code: 'COP', description: 'Peso colombiano'),
  Currency(code: 'GYD', description: 'Dólar guyanés'),
  Currency(code: 'PYG', description: 'Guaraní (Paraguay)'),
  Currency(code: 'PEN', description: 'Sol (Perú)'),
  Currency(code: 'SRD', description: 'Dólar surinamés'),
  Currency(code: 'UYU', description: 'Peso uruguayo'),
  Currency(code: 'VES', description: 'Bolívar venezolano'),

  // Reutilización del dólar en varios países
  Currency(
      code: 'USD',
      description:
          'Dólar estadounidense (El Salvador, Ecuador,\nPanamá, Puerto Rico, etc.)'),

  // Territorios con otras monedas
  Currency(code: 'EUR', description: 'Euro (Guayana Francesa)'),
  Currency(code: 'BMD', description: 'Dólar bermudeño'),
  Currency(
      code: 'ANG',
      description: 'Florín antillano neerlandés (Curazao, Sint Maarten)'),
  Currency(code: 'AWG', description: 'Florín arubeño'),
  Currency(code: 'FKP', description: 'Libra malvinense (Islas Malvinas)'),
];

const gap = Gap();

String? dayName(int day) {
  switch (day) {
    case 1:
      return 'Lunes';
    case 2:
      return 'Martes';
    case 3:
      return 'Miércoles';
    case 4:
      return 'Jueves';
    case 5:
      return 'Viernes';
    case 6:
      return 'Sábado';
    case 7:
      return 'Domingo';
    default:
      return null;
  }
}

final currencyFormatter = NumberFormat.currency(locale: "en_US", symbol: "\$");
