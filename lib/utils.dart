/*

getRequest(url);
Directory.current; // Diretório atual
Directory.systemTemp.path // Pasta para diretório temporário.


REFERÊNCIAS
 https://gist.github.com/slightfoot/6f502205aca15e3cbf461df879673b56

*/

/*
Autor - Bruno Chaves
2024-08
*/

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

void printLine() {
  print('-------------------------------------------');
}

void printErro(String text) {
  print('[!] Erro: ${text}');
}

void printInfo(String text) {
  print('[+] ${text}');
}

void printMsg(String text) {
  printLine();
  print(text);
  printLine();
}

//========================================================================//
// Retorna o caminho absoluto da pasta HOME do usuário.
//========================================================================//

String getAndroidHomeDir() {
  Directory androidHomeDir = Directory('/storage/emulated/0');
  Directory androidHome = androidHomeDir as Directory;
  if (!androidHome.existsSync()) {
    androidHome.createSync(recursive: true);
  }
  return androidHome.path;
}

String getUserHome() {
  var h;
  if (Platform.isMacOS) {
    h = Platform.environment['HOME'];
  } else if (Platform.isLinux) {
    h = Platform.environment['HOME'];
  } else if (Platform.isWindows) {
    h = Platform.environment['UserProfile'];
  } else if (Platform.isAndroid) {
    h = getAndroidHomeDir();
  } else {
    h = 'não suportado';
  }

  //Directory d = Directory.fromUri(Uri.directory(h));
  return h as String;
}

String getUserDownloads() {
  String d;
  if (Platform.isAndroid) {
    d = getUserHome() + Platform.pathSeparator + 'Download';
  } else {
    d = getUserHome() + Platform.pathSeparator + 'Downloads';
  }
  return d;
}

String getTempDir() {
  Directory d = Directory.systemTemp.createTempSync();
  if(!d.existsSync()){
    d.createSync(recursive: true);
  }

  return d.path;
}

Directory getTemporaryDirectory(){
  Directory d = Directory.systemTemp.createTempSync();
  if(!d.existsSync()){
    d.createSync(recursive: true);
  }

  return d;
}

void createDir(String dir) {
  Directory d = Directory(dir);
  d.create();
}

class PathUtils {
  String join(List<String> dirs) {
    int max = dirs.length;
    String first = dirs[0];

    for (int i = 1; i < max; i++) {
      first = '${first}${Platform.pathSeparator}${dirs[i]}';
    }

    return first;
  }
}

//========================================================================//
// Download de arquivos.
//========================================================================//

void downloadFileSync(String url, String filename) {
  // https://stackoverflow.com/questions/18033151/using-dart-to-download-a-file
  File f = new File(filename);
  if (f.existsSync()) {
    printInfo('O arquivo já existe: ${filename}');
    return;
  }
  printInfo('Baixando: ${url}');

  http.get(Uri.parse(url)).then((value) => {
        printInfo('Salvando arquivo: ${filename}'),
        f.writeAsBytesSync(value.bodyBytes),
      });
}

void download({required String url, required File filePath}) async {
  if (filePath.existsSync()) {
    printInfo('O arquivo já existe: ${filePath.path}');
    return;
  }

  printInfo('Baixando: ${url}');
  Future<Response> response = http.get(Uri.parse(url));
  Response resp = await response;
  printInfo('Salvando arquivo: ${filePath.path}');
  filePath.writeAsBytesSync(resp.bodyBytes);
}

//========================================================================//
// Request de um URL qualquer.
//========================================================================//
Future<Response> getRequest(String url) async {
  // Recebe um URL e retorna um objeto RESPONSE.
  printInfo('Request: ${url}');
  var u = Uri.parse(url);
  var response = await http.get(u);
  var r = response as http.Response;
  return r;
}

//========================================================================//
// Descompactar arquivo .ZIP
//========================================================================//
void unzipFile(String filezip, String outputdir) {
  File zipFile = new File(filezip);
  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
  Directory outDir = Directory(outputdir);

  // Criar o diretório de saída caso não exista.
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  for (var file in archive) {
    final filename = file.name;
    final data = file.content;
    final outputFile = File('${outDir.path}${Platform.pathSeparator}$filename');
    //await outputFile.writeAsBytes(data);
    outputFile.writeAsBytesSync(data);
    print('Extraindo: $filename');
  }
}

//========================================================================//
// JSON UTILS LOCAL
//========================================================================//
class JsonUtils {
  JsonUtils();

  String mapToJson({required Map<String, dynamic> map}) {
    //Converte um mapa em JSON/String.
    return JsonEncoder.withIndent("  ").convert(map);
  }

  Map<String, dynamic> jsonToMap({required String dataJson}) {
    return jsonDecode(dataJson);
  }

  bool exportMapToFile(
      {required Map<String, dynamic> map,
      required File outputFile,
      bool replace = false}) {
    // Converte um mapa em Json e salva em um arquivo no disco.
    if (replace == false) {
      if (outputFile.existsSync()) {
        printErro('O arquivo já existe: ${outputFile.path}');
        return false;
      }
    }

    printInfo('Exportando arquivo: ${outputFile.path}');
    outputFile.writeAsStringSync(this.mapToJson(map: map));
    return true;
  }
}

//========================================================================//
// SALVAR STRINGS EM ARQUIVOS
//========================================================================//
bool exportFile(
    {required File file,
    required List<String> textList,
    bool replace = false}) {
  if (replace == false) {
    if (file.existsSync()) {
      printInfo('Arquivo já existe: ${file.path}');
      return false;
    }
  }

  int max_num = textList.length;
  printInfo('Exportando arquivo: ${file.path}');
  for (int i = 0; i < max_num; i++) {
    file.writeAsStringSync("${textList[i]}\n", mode: FileMode.append);
  }

  return true;
}
