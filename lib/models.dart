
import 'dart:io';
import 'package:libjson/libjson.dart';
import 'package:libjson/utils.dart';

Directory cacheDir = Directory(PathUtils().join([getUserDownloads(), 'dados-camara']));
File baseEmentas = File(PathUtils().join([cacheDir.path, 'ementas.json']));
File baseAutores = File(PathUtils().join([cacheDir.path, 'autores.json']));

void downloadBaseOnline(){
  if(!baseAutores.existsSync()){
    downloadFileSync(UrlsCamara().autores(), baseAutores.path);
  }

  if(!baseEmentas.existsSync()){
    downloadFileSync(UrlsCamara().ementas(), baseEmentas.path);
  }
}

class Ementa {
  /*
  late String id;
  late String uri;
  late String siglaTipo;
  late String numero;
  late String ano;
  late String codTipo;
  late String descricaoTipo;
  late String ementa;
  late String ementaDetalhada;
  late String keywords;
  late String dataApresentacao;
  late String uriOrgaoNumerador;
  late String uriPropAnterior;
  late String uriPropPrincipal;
  late String uriPropPosterior;
  late String urlInteiroTeor;
  late String ultimoStatus;
  */

  Map<String, dynamic> ementaItens;
  Ementa({required this.ementaItens}){
    if(this.ementaItens.length != 17){
      print('ERRO: uma ementa contém 17 itens - a ementa atual contém ${this.ementaItens.length}');

    }
  }

  String getId(){
    return this.ementaItens['id'].toString();
  }


}

class Autor {
  /*
 
  */

  Map<String, dynamic> autorItens;
  Autor({required this.autorItens}){
    if(this.autorItens.length != 12){
      print('ERRO: um autor contém 12 itens - autor contém ${this.autorItens.length}');
    }
  }

  String getNome(){
    return this.autorItens['nomeAutor'].toString();
  }

  String idProposicao(){
    return this.autorItens['idProposicao'].toString();
  }

}