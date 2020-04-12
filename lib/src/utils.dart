String generateConditionKey(String property, String value) {
  return '$property::$value';
}

List<String> splitConditionKey(String conditionKey) {
  return conditionKey.split('::');
}
