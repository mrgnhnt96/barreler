/// Accepts a JSON map and a key, and returns the value associated with the key
///
/// If the value is a string, it returns a list with the string
///
/// If the value is a list, it returns a list with the strings
/// while ignoring empty strings and null values
// ignore: strict_raw_type
List<String>? stringOrList(Map json, String key) {
  if (!json.containsKey(key)) {
    return null;
  }
  final value = json[key];

  if (value is String) {
    return [value];
  }

  if (value is! List) {
    return null;
  }

  Iterable<String> iterate() sync* {
    for (final item in value) {
      if (item is String) {
        if (item.isEmpty) continue;

        yield item;
      }
    }
  }

  return iterate().toList();
}
