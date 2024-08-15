/*


KEYS

id
uri
siglaTipo
numero
ano
codTipo
descricaoTipo
ementa
ementaDetalhada
keywords
dataApresentacao
uriOrgaoNumerador
uriPropAnterior
uriPropPrincipal
uriPropPosterior
urlInteiroTeor
ultimoStatus

*/

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:libjson/utils.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;


//========================================================================//
// Classe para obter URLs
//========================================================================//
class BaseUrls {

  String urlProposicoes(){
    return 'https://dadosabertos.camara.leg.br/arquivos/proposicoes/json/proposicoes-2024.json';
  }

  String urlTemas(){
    return 'https://dadosabertos.camara.leg.br/arquivos/proposicoesTemas/json/proposicoesTemas-2024.json';
  }
}

//========================================================================//
// Ao instânciar essa classe você pode obter um Map<> de um conteúdo JSON
// a fonte pode ser um ARQUIVO local ou um URL.
//========================================================================//
class JsonToMap {

  Future<Map<String, dynamic>> fromUrl(String url) async {
    // Recebe um url de arquivo JSON, baixa o conteúdo e retorna em forma de mapa.
    Map<String, dynamic> m = {};
    
    try {
      Future<Response> response = getRequest(url);
      Response r = await response;
      m = jsonDecode(utf8.decode(r.bodyBytes));
    } catch (e)  {
      printLine();
      printErro(e.toString());
      printInfo('Verifique o URL ou sua conexção com a internet.');
      printLine();
    }
    return m;
  }

  Map<String, dynamic> fromFileName(String filename) {
    // Recebe o caminho completo de um arquivo JSON no disco e retorna o conteúdo
    // em forma de mapa.
    Map<String, dynamic> m = {};
    File f = File(filename);
    if (f.existsSync() == false) {
      printLine();
      printErro('o arquivo não existe ${filename}');

    } else {
      printInfo('Lendo o arquivo: ${filename}');
      String content = f.readAsStringSync();
      m = jsonDecode(content);
    }
    return m;
  }
}

//========================================================================//
// Dados Camara
//========================================================================//
class CamaraProposicoes {
  
  File fileLocalJson;

  CamaraProposicoes(this.fileLocalJson);

  List<dynamic> getList() {
    return JsonToMap().fromFileName(this.fileLocalJson.path)['dados'];
  }


}

void run() async {

  String url = 'https://dadosabertos.camara.leg.br/arquivos/proposicoes/json/proposicoes-2024.json';
  
  String filename = 'proposicoes';
  String outputFile = PathUtils().join([getUserDownloads(), 'TESTE', filename]);
  File filePath = File(outputFile);

  if(!filePath.existsSync()){
    createDir(filePath.parent.path);
    downloadFileSync(url, outputFile);
  }
  
  CamaraProposicoes proposicoes = CamaraProposicoes(filePath);

  print(proposicoes.getList());
  


  print('OK');
  return;
  
}
