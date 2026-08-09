int calculateAge(DateTime birthDate, [DateTime? asOf]) {
  final now = asOf ?? DateTime.now();
  var age = now.year - birthDate.year;
  final birthdayHasOccurredThisYear =
      now.month > birthDate.month ||
      (now.month == birthDate.month && now.day >= birthDate.day);
  if (!birthdayHasOccurredThisYear) age--;
  return age;
}
