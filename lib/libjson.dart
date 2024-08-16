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
// Dados Proposições
//========================================================================//
class CamaraProposicoes {

  List<Map<String, dynamic>> _listMap = []; 
  File fileLocalJson;

  CamaraProposicoes(this.fileLocalJson);

  List<dynamic> getList() {
    return JsonToMap().fromFileName(this.fileLocalJson.path)['dados'];
  }

  List<Map<String, dynamic>> getListMap(){

    if(this._listMap.isEmpty){
      Map<String, dynamic> _current;
      List<dynamic> get_list = this.getList();
      int max = get_list.length;

      for(int i=0; i<max; i++){
        _current = get_list[i];
        this._listMap.add(_current);
      }
    }
    return this._listMap;
  }

  List<String> getKeys(){
    return this.getListMap()[0].keys.toList();
  }

  List<String> valuesInKey(String keyName){
    // Apartir de uma chave/key - retorna todos os valores correspondentes no arquivo JSON.

    List<String> _values = [];
    String _current;
    int max = this.getListMap().length;

    for(int i=0; i<max; i++){
      _current = this.getListMap()[i][keyName].toString();
      _values.add(_current);
    }

    return _values;
  }

}

//========================================================================//
// Buscar Itens em uma lista de mapas
//========================================================================//
class FindItens {
  late List<Map<String, dynamic>> listItens;

  FindItens({required this.listItens});

  bool containsValue({required String key, required String value}){
    if(!this.listItens[0].containsKey(key)){
      return false;
    }

    bool _contains = false;
    int max = this.listItens.length;
    for(int i=0; i<max; i++){
      if(this.listItens[i][key].toString().contains(value)){
        _contains = true;
        break;
      }
    }
    return _contains;
  }


}

void run() async {
  printLine();
  String url = BaseUrls().urlProposicoes();
  String filename = 'proposicoes.json';
  String outputFile = PathUtils().join([getUserDownloads(), 'TESTE', filename]);
  File filePath = File(outputFile);

  if(!filePath.existsSync()){
    createDir(filePath.parent.path);
    downloadFileSync(url, outputFile);
  }  

  CamaraProposicoes proposicoes = CamaraProposicoes(filePath);
  //List<Map<String, dynamic>> mp = proposicoes.getListMap();

  FindItens f = FindItens(listItens: proposicoes.getListMap());

  print(f.containsValue(key: 'ementa', value: 'Estabelece normas gerais'));

  print('OK');
  printLine();
  return;
  
}
