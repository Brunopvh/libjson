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


VERSÃO = 2024-08-17

*/

/*
Autor - Bruno Chaves
2024-08
*/

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:libjson/models.dart';
import 'package:libjson/utils.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

//========================================================================//
// Classe para obter URLs da API
//========================================================================//
class UrlsCamara {
  String ementas() {
    return 'https://dadosabertos.camara.leg.br/arquivos/proposicoes/json/proposicoes-2024.json';
  }

  String temas() {
    return 'https://dadosabertos.camara.leg.br/arquivos/proposicoesTemas/json/proposicoesTemas-2024.json';
  }

  String autores() {
    return 'https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/json/proposicoesAutores-2024.json';
  }
}

//========================================================================//

class GetJson {

  String getOnlineJson(String url){
    print('REQUEST: ${url}');
    String e = '{}';
    http.get(Uri.parse(url)).then((response) {
      
      if (response.statusCode == 200) {
        // Convertendo o corpo da resposta para String
        e = response.body;
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Erro na requisição: $error');
    });

    return e;
  }

  Map<String, dynamic> fromUrl(String url) {
    // Recebe um url de arquivo JSON, baixa o conteúdo e retorna em forma de mapa.
    String dataJson = this.getOnlineJson(url);
    var _map = jsonDecode(dataJson);
    return _map as Map<String, dynamic>;
  }

  Map<String, dynamic> fromFileName(String filename) {
    // Recebe o caminho completo de um arquivo JSON no disco 
    //e retorna o conteúdo em forma de mapa.
    Map<String, dynamic> m = {};
    File f = File(filename);

    if (!f.existsSync()) {
      printLine();
      printErro('o arquivo não existe ${filename}');
    } else {
      printInfo('Lendo o arquivo: ${filename}');
      m = jsonDecode(f.readAsStringSync());
    }
    return m;
  }
}

//========================================================================//

class DadosCamara {
  Map<String, dynamic> dadosCamara;

  DadosCamara({required this.dadosCamara});

  List<dynamic> getList(){
    List<dynamic> d = [];

    if(!this.dadosCamara.isEmpty){
      d = this.dadosCamara['dados'];
    }
    return d;
  }

  List<Map<String, dynamic>> getListMap(){
    
    List<dynamic> l = this.getList();
    if(l.isEmpty){
      return [];
    }

    List<Map<String, dynamic>> listMap = [];
    Map<String, dynamic> currentMap;
    int maxNum = l.length;
    for(int i=0; i<maxNum; i++){
      currentMap = l[i];
      listMap.add(currentMap);
    }

    return listMap;
  }

  List<String> getCamaraKeys(){

    List<Map<String, dynamic>> m = this.getListMap();
    if(m.isEmpty){
      return [];
    }

    return m[0].keys.toList();
  }

}

//========================================================================//

class DadosEmenta {

  DadosCamara dados;
  List<Ementa> ementas = [];

  DadosEmenta({required this.dados}){

    List<Map<String, dynamic>> m = this.dados.getListMap();
    int max = m.length;
    if(this.ementas.isEmpty){
      for(int i=0; i<max; i++){
        this.ementas.add(Ementa(ementaItens: m[i]));
      }
    }
  }

  List<String> getIds(){
    List<String> ids = [];
    int max = this.ementas.length;
    for(int i=0; i<max; i++){
      ids.add(this.ementas[i].getId());
    }

    return ids;
  }

  List<Ementa> getEmentas({required List<String> ids}){
    List<Ementa> ementas = [];
    int max = ids.length;
    int count = this.ementas.length;

    for(int i=0; i<max; i++){
      for(int c=0; i<count; c++){
        if(ids[i].toString() == this.ementas[c].getId()){
          ementas.add(this.ementas[c]);
        }
      }
    }

    return ementas;
  }

}

//========================================================================//

class DadosAutor {

  DadosCamara dados;
  List<Autor> autores = [];

  DadosAutor({required this.dados}){

    List<Map<String, dynamic>> m = this.dados.getListMap();
    int max = m.length;
    if(this.autores.isEmpty){
      for(int i=0; i<max; i++){
        this.autores.add(Autor(autorItens: m[i]));
      }
    }
  } // Construtor.

  List<String> getNomes(){
    List<String> nomes = [];
    int max = this.autores.length;
    for(int i=0; i<max; i++){
      nomes.add(this.autores[i].getNome());
    }

    return nomes;
  }

  List<Autor> autorDados({required String nome}){
    List<Autor> a = [];
    int max = this.autores.length;
    for(int i=0; i<max; i++){
      if(this.autores[i].getNome().toUpperCase() == nome.toUpperCase()){
        a.add(this.autores[i]);
      }
    }

    if(a.isEmpty){
      printErro('O nome do autor informado não existe');
      printLine();
    }

    return a;
  }

  List<String> autorProposicoesIds({required String nome}){
    List<String> ids = [];
    List<Autor> autor = this.autorDados(nome: nome);
    int max = autor.length;
    for(int i=0; i<max; i++){
      ids.add(autor[i].idProposicao());
    }
    return ids;
  }

}

void run() async {
  
  await downloadBaseOnline();

  DadosCamara ementas = DadosCamara(dadosCamara: GetJson().fromFileName(baseEmentas()));
  DadosCamara autores = DadosCamara(dadosCamara: GetJson().fromFileName(baseAutores()));

  List<String> cristianeEmentasIds = DadosAutor(dados: autores).autorProposicoesIds(nome: 'Cristiane Lopes');
  List<Ementa> cristianeEmentas = DadosEmenta(dados: ementas).getEmentas(ids: cristianeEmentasIds);

  print(cristianeEmentasIds);

}