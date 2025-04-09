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
