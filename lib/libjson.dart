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

  String urlAutoresProposicoes(){
    return 'https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/json/proposicoesAutores-2024.json';
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
// Dados Gerais
//========================================================================//
class CamaraJsonUtil {

  List<Map<String, dynamic>> _listMap = []; 
  File fileNameJson;
  String keyDados = 'dados';

  CamaraJsonUtil({required this.fileNameJson, required this.keyDados});

  List<dynamic> getList() {
    // Retorna uma lista bruta com os dados do arquivo.
    return JsonToMap().fromFileName(this.fileNameJson.path)[this.keyDados];
  }

  List<Map<String, dynamic>> getListMap(){
    // Retorna uma lista com mapas dos valores do arquivo.
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
    // Retorna uma lista de chaves dos mapas.
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
// Dados Proposições
//========================================================================//
class CamaraProposicoes {

  List<Map<String, dynamic>> _listMap = []; 
  File fileNameProposicoes;
  late CamaraJsonUtil camaraJsonUtil;

  CamaraProposicoes(this.fileNameProposicoes){
    // Criar o objeto para análise obtenção dos dados apartir do arquivo.
    this.camaraJsonUtil = CamaraJsonUtil(fileNameJson: this.fileNameProposicoes, keyDados: 'dados');
  }

  List<dynamic> getList() {
    return this.camaraJsonUtil.getList();
  }

  List<Map<String, dynamic>> getListMap(){
    return this.camaraJsonUtil.getListMap();
  }

  List<String> getKeys(){
    return this.camaraJsonUtil.getKeys();
  }

  List<String> valuesInKey(String keyName){
    // Apartir de uma chave/key - retorna todos os valores correspondentes no arquivo JSON.
    return this.camaraJsonUtil.valuesInKey(keyName);
  }
}

//========================================================================//
// Proposições autores
//========================================================================//
class CamaraProposicoesAutores {
 
  File fileNameProposicoesAutores;
  late CamaraJsonUtil camaraJsonUtil;

  CamaraProposicoesAutores(this.fileNameProposicoesAutores){
    // Criar o objeto para análise obtenção dos dados apartir do arquivo.
    this.camaraJsonUtil = CamaraJsonUtil(fileNameJson: this.fileNameProposicoesAutores, keyDados: 'dados');
  }

  List<dynamic> getList() {
    return this.camaraJsonUtil.getList();
  }

  List<Map<String, dynamic>> getListMap(){
    return this.camaraJsonUtil.getListMap();
  }

  List<String> getKeys(){
    return this.camaraJsonUtil.getKeys();
  }

  List<String> valuesInKey(String keyName){
    // Apartir de uma chave/key - retorna todos os valores correspondentes no arquivo JSON.
    return this.camaraJsonUtil.valuesInKey(keyName);
  }
}

//========================================================================//
// Buscar Itens em uma lista de mapas/json
//========================================================================//
class FindElements {
  late List<Map<String, dynamic>> listItens;

  FindElements({required this.listItens});

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

  List<String> findContains({required String key, required String value}){
    // Correr cada mapa da lista e procurar pela correspondência <value> na chave <key>
    // adicionar os itens na lista _itens.
    List<String> _itens = [];
    int max = this.listItens.length;
    for(int i=0; i<max; i++){
      if(this.listItens[i][key].toString().contains(value)){
        _itens.add(this.listItens[i][key].toString());
      }
    }

    return _itens;
  }

}


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

  List<String> findContains({required String key, required String value}){
    // Correr cada mapa da lista e procurar pela correspondência <value> na chave <key>
    // adicionar os itens na lista _itens.
    List<String> _itens = [];
    int max = this.listItens.length;
    for(int i=0; i<max; i++){
      if(this.listItens[i][key].toString().contains(value)){
        _itens.add(this.listItens[i][key].toString());
      }
    }

    return _itens;
  }

FindItens findMaps({required String key, required String value}){

  List<Map<String, dynamic>> list_itens = [];
  String _current_str;
  int max = this.listItens.length;
  for(int i=0; i<max; i++){
    _current_str = this.listItens[i][key].toString();
    if(_current_str.contains(value)){
      list_itens.add(this.listItens[i]);
    }
  }

  return FindItens(listItens: list_itens);
}

List<String> valuesInKey({required key}){
  List<String> _itens = [];
  int max = this.listItens.length;
  for(int i=0; i<max; i++){
    _itens.add(this.listItens[i][key].toString());
  }

  return _itens;
}

FindItens getMapsFromValues({required List<String> values, required key}){
  // Recebe uma lista de valores, se tais valores forem encontrados, será retornado
  // uma lista de mapas com todas a ocorrênias na forma do objeto FindItens().
  List<Map<String, dynamic>> _list = [];
  Map<String, dynamic> current_map;
  int max = this.listItens.length;
  int max_values = values.length;

  for(int i=0; i<max_values; i++){
    for(int c=0; c<max; c++){
      current_map = this.listItens[c];
      if(current_map[key].toString() == values[i].toString()){
        _list.add(current_map);
      }
    }
  }

  return FindItens(listItens: _list);
}

}

void run() async {
  printLine();

  PathUtils path_utils = PathUtils();
  BaseUrls urls = BaseUrls();
  String dir_teste = PathUtils().join([getUserDownloads(), 'TESTE-CAMARA']);
  Directory dir_path = Directory(dir_teste);
  dir_path.createSync(recursive: true);

  File filePropocicoes = File(path_utils.join([dir_teste, 'proposicoes.json']));
  File filePropocicoesAutores = File(path_utils.join([dir_teste, 'proposicoes-autores.json']));

  downloadFileSync(urls.urlProposicoes(), filePropocicoes.path);
  downloadFileSync(urls.urlAutoresProposicoes(), filePropocicoesAutores.path);
  
  CamaraProposicoes proposicoes = CamaraProposicoes(filePropocicoes);
  CamaraProposicoesAutores autores = CamaraProposicoesAutores(filePropocicoesAutores);

  FindItens findProposicoes = FindItens(listItens: proposicoes.getListMap());
  FindItens findAutores = FindItens(listItens: autores.getListMap());
  FindItens cristiane = findAutores.findMaps(key: 'nomeAutor', value: 'Cristiane');
  List<String> ementasCristiane = cristiane.valuesInKey(key: 'idProposicao');
  FindItens itensCristiane = findProposicoes.getMapsFromValues(key: 'id', values: ementasCristiane);

  itensCristiane.listItens.forEach((element) => {
    print(element),
    printLine(),
  });

  printLine();
  return;
  
}
