/*

getRequest(url);
Directory.current; // Diretório atual
Directory.systemTemp.path // Pasta para diretório temporário.


REFERÊNCIAS
 https://gist.github.com/slightfoot/6f502205aca15e3cbf461df879673b56

*/

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
String getUserHome() {
  var h;
  if (Platform.isMacOS) {
    h = Platform.environment['HOME'];
  } else if (Platform.isLinux) {
    h = Platform.environment['HOME'];
  } else if (Platform.isWindows) {
    h = Platform.environment['UserProfile'];
  } else {
    h = 'não suportado';
  }

  //Directory d = Directory.fromUri(Uri.directory(h));
  return h as String;
}

String getUserDownloads() {
  String d = getUserHome() + Platform.pathSeparator + 'Downloads';
  return d;
}

String getTempDir() {
  String tmpDir =
      Directory.systemTemp.path + Platform.pathSeparator + 'tmp_dir';
  return tmpDir;
}

void createDir(String dir) {
  Directory d = Directory(dir);
  d.create();
}

// Concatena dois diretórios e retorna o conteúdo concatenado em string.
String joinPath(String path1, String path2) {
  return path1 + Platform.pathSeparator + path2;
}

class PathUtils {
  
  String join(List<String> dirs){
    int max = dirs.length;
    String first = dirs[0];

    for(int i=1; i<max; i++){
      first = '${first}${Platform.pathSeparator}${dirs[i]}';
    }

    return first;
  }

}

//========================================================================//
// Download de arquivos.
//========================================================================//
Future<bool> downloadFile(String url, String filename) async {
  printInfo('Baixando: ${url}');
  http.Client client = new http.Client();
  var req = await client.get(Uri.parse(url));
  var bytes = req.bodyBytes;
  File file = new File(filename);
  printInfo('Salvando: $filename');
  await file.writeAsBytes(bytes);
  return true;
}

void downloadFileSync(String url, String filename) {
  printInfo('Baixando: ${url}');
  http.Client client = new http.Client();
  var req = client.get(Uri.parse(url));

  Response r;
  File file = new File(filename);
  req.then((value) {
    printInfo('Salvando: $filename');
    r = value;
    file.writeAsBytes(r.bodyBytes);
  });
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
