import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getSaved() async {
  var prefs = await SharedPreferences.getInstance();
  List<String> saved = prefs.getStringList('tags');

  return saved ?? List<String>();
}

Future<void> save(List<String> tags) async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('tags', tags);
}
