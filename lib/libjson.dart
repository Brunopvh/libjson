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
  String urlProposicoes() {
    return 'https://dadosabertos.camara.leg.br/arquivos/proposicoes/json/proposicoes-2024.json';
  }

  String urlTemas() {
    return 'https://dadosabertos.camara.leg.br/arquivos/proposicoesTemas/json/proposicoesTemas-2024.json';
  }

  String urlAutoresProposicoes() {
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
    } catch (e) {
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

  List<Map<String, dynamic>> getListMap() {
    // Retorna uma lista com mapas dos valores do arquivo.
    if (this._listMap.isEmpty) {
      Map<String, dynamic> _current;
      List<dynamic> get_list = this.getList();
      int max = get_list.length;

      for (int i = 0; i < max; i++) {
        _current = get_list[i];
        this._listMap.add(_current);
      }
    }
    return this._listMap;
  }

  List<String> getKeys() {
    // Retorna uma lista de chaves dos mapas.
    return this.getListMap()[0].keys.toList();
  }

  List<String> valuesInKey(String keyName) {
    // Apartir de uma chave/key - retorna todos os valores correspondentes no arquivo JSON.

    List<String> _values = [];
    String _current;
    int max = this.getListMap().length;

    for (int i = 0; i < max; i++) {
      _current = this.getListMap()[i][keyName].toString();
      _values.add(_current);
    }

    return _values;
  }
}

class GetDados {
  List<Map<String, dynamic>> _listMap = [];
  File filePath;
  late CamaraJsonUtil camaraJsonUtil;

  GetDados(this.filePath) {
    // Criar o objeto para análise e obtenção dos dados apartir de um arquivo JSON qualquer.
    this.camaraJsonUtil =
        CamaraJsonUtil(fileNameJson: this.filePath, keyDados: 'dados');
  }

  List<dynamic> getList() {
    return this.camaraJsonUtil.getList();
  }

  List<Map<String, dynamic>> getListMap() {
    return this.camaraJsonUtil.getListMap();
  }

  List<String> getKeys() {
    return this.camaraJsonUtil.getKeys();
  }

  List<String> valuesInKey(String keyName) {
    // Apartir de uma chave/key - retorna todos os valores correspondentes no arquivo JSON.
    return this.camaraJsonUtil.valuesInKey(keyName);
  }

  FindItens getFind() {
    return FindItens(listItens: this.getListMap());
  }
}

//========================================================================//
// Dados Proposições
//========================================================================//
class Proposicoes extends GetDados {
  Proposicoes(super.filePath);
}

//========================================================================//
// Proposições autores
//========================================================================//
class ProposicoesAutores extends GetDados {
  ProposicoesAutores(super.filePath);
}

//========================================================================//
// Buscar Itens em uma lista de mapas/json
//========================================================================//

class FindItens {
  late List<Map<String, dynamic>> listItens;

  FindItens({required this.listItens});

  bool containsValue({required String key, required String value}) {
    // Verifica se um valor existe em uma chave especifica.
    if (!this.listItens[0].containsKey(key)) {
      return false;
    }

    bool _contains = false;
    int max = this.listItens.length;
    for (int i = 0; i < max; i++) {
      if (this.listItens[i][key].toString().contains(value)) {
        _contains = true;
        break;
      }
    }
    return _contains;
  }

  List<String> getValuesInKey({required key}) {
    // Retorna os valores dos mapas na chave <key>
    List<String> _itens = [];
    int max = this.listItens.length;
    for (int i = 0; i < max; i++) {
      _itens.add(this.listItens[i][key].toString());
    }

    return _itens;
  }

  FindItens getMapsInKey({required String key, required String value}) {
    // Retorna um objeto FindItens com todos os mapas que contém o valor <value>
    // na chave <key>.
    List<Map<String, dynamic>> list_maps_from_key = [];
    if (this.listItens.isEmpty) {
      return FindItens(listItens: []);
    }

    if (!this.listItens[0].keys.toList().contains(key)) {
      return FindItens(listItens: []);
    }

    int max_num = this.listItens.length;
    for (int i = 0; i < max_num; i++) {
      if (this.listItens[i][key].toString().toUpperCase() ==
          value.toUpperCase()) {
        list_maps_from_key.add(this.listItens[i]);
      }
    }
    return FindItens(listItens: list_maps_from_key);
  }

  FindItens getMapsFromValues({required List<String> values, required key}) {
    // Recebe uma lista de valores, se tais valores forem encontrados, será retornado
    // uma lista de mapas com todas a ocorrênias na forma do objeto FindItens().
    List<Map<String, dynamic>> _list = [];
    Map<String, dynamic> current_map;
    int max = this.listItens.length;
    int max_values = values.length;

    for (int i = 0; i < max_values; i++) {
      for (int c = 0; c < max; c++) {
        current_map = this.listItens[c];
        if (current_map[key].toString() == values[i].toString()) {
          _list.add(current_map);
        }
      }
    }

    return FindItens(listItens: _list);
  }
}

class FindElements extends FindItens {
  FindElements({required super.listItens});
}

void run() async {
  printLine();

  PathUtils path_utils = PathUtils();
  BaseUrls base_urls = BaseUrls();
  Directory dirTeste =
      Directory(path_utils.join([getUserDownloads(), 'TESTE-CAMARA']));

  File arquivoProposicoes =
      new File(path_utils.join([dirTeste.path, 'proposicoes.json']));

  File arquivoAutores =
      new File(path_utils.join([dirTeste.path, 'proposicoes-autores.json']));

  // Baixar os arquivos.
  downloadFileSync(base_urls.urlProposicoes(), arquivoProposicoes.path);
  downloadFileSync(base_urls.urlAutoresProposicoes(), arquivoAutores.path);

  if (!arquivoAutores.existsSync()) {
    printErro('O arquivo não existe -> ${arquivoAutores.path}');
    return;
  }

  if (!arquivoProposicoes.existsSync()) {
    printErro('O arquivo não existe -> ${arquivoProposicoes.path}');
    return;
  }

  // Usar os dados
  FindItens autores = ProposicoesAutores(arquivoAutores).getFind();
  FindItens proposicoes = Proposicoes(arquivoProposicoes).getFind();
  FindElements ro = FindElements(
      listItens:
          autores.getMapsInKey(key: 'siglaUFAutor', value: 'RO').listItens);

  File outputFile = File(path_utils.join([dirTeste.path, 'deputados-ro.json']));
  File arquivoNomes = File(path_utils.join([dirTeste.path, 'nomes.txt']));
  List<String> nomes = ro.getValuesInKey(key: 'nomeAutor');
  List<String> exportNomes = [];
  int max = nomes.length;
  for (int i = 0; i < max; i++) {
    if (!exportNomes.contains(nomes[i])) {
      exportNomes.add(nomes[i]);
    }
  }

  exportFile(file: arquivoNomes, textList: exportNomes, replace: true);

  print('OK');
  return;
}
