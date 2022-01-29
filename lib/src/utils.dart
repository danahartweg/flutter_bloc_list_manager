/// Combines the give [property] and [value] into a storage key
/// (`$property::$value`) to track active conditions.
String generateConditionKey(String property, String? value) {
  return '$property::$value';
}

/// Splits the storage key, returning the associated property and value strings.
List<String> splitConditionKey(String conditionKey) {
  return conditionKey.split('::');
}
