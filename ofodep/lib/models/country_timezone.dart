class CountryTimezone {
  final String country;
  final String timezone;

  const CountryTimezone({
    required this.country,
    required this.timezone,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryTimezone &&
          runtimeType == other.runtimeType &&
          country == other.country &&
          timezone == other.timezone;

  @override
  int get hashCode => country.hashCode ^ timezone.hashCode;

  bool get isEmpty => country.isEmpty && timezone.isEmpty;
}
