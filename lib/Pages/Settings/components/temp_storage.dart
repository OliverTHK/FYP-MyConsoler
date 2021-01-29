import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class TempStorage {
  Future<String> get localPath async {
    final appDir = await getApplicationDocumentsDirectory();
    return appDir.path;
  }

  Future<File> get localFile async {
    final appPath = await localPath;
    return File('$appPath/user_query.csv');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String content = await file.readAsString();
      return content;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> writeLinesData(List<String> linesData) async {
    final file = await localFile;
    return file.writeAsStringSync(linesData.join('\n'));
  }
}
