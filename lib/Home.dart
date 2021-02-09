import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/helper/AnotacaoHelper.dart';
import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

TextEditingController _tituloController = TextEditingController();

TextEditingController _descricaoController = TextEditingController();
var _db = AnotacaoHelper();
List<Anotacao> _anotacoes = List<Anotacao>();

_recuperarAnotacao() async {
  List anotacoesRuperadas = await _db.recuperarAnotacoes();
  List<Anotacao> listaTemporaria = List<Anotacao>();

  for(var item in anotacoesRuperadas)
  {
    Anotacao anotacao = Anotacao.fromMap(item);
    listaTemporaria.add(anotacao);

  }
  setState(() {
      _anotacoes = listaTemporaria;
  });
  listaTemporaria = null;

  return anotacoesRuperadas;

}

_removerAnotacao(int id) async{

await _db.removerAnotacao(id);

}


_salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async{
  String titulo = _tituloController.text;
  String descricao = _descricaoController.text;
  
  if(anotacaoSelecionada ==null)
  {
    Anotacao anotacao = Anotacao(titulo,descricao,DateTime.now().toString());
    _db.salvarAnotacao(anotacao);
  }
  else{
    anotacaoSelecionada.titulo = titulo;
    anotacaoSelecionada.descricao = descricao;
    anotacaoSelecionada.data = DateTime.now().toString();
    int resultado = await _db.atualizarAnotacao(anotacaoSelecionada) ;
  }



_tituloController.clear();
_descricaoController.clear();
_recuperarAnotacao();
}
_exibeTelaCadastro({Anotacao anotacao}){

  String TextoSalvarAtualizar = "";
  if(anotacao == null){
  _tituloController.text = "";
  _descricaoController.text = "";
  TextoSalvarAtualizar = "Salvar";
  }
  else
  {
 _tituloController.text = anotacao.titulo;
  _descricaoController.text = anotacao.descricao;
  TextoSalvarAtualizar = "Atualizar";
  }

  showDialog(context: context,
  builder: (context){
        return AlertDialog(
          title: Text("$TextoSalvarAtualizar"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Titulo",
                  hintText: "Digite titulo.."
                ),
              ),
                TextField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  labelText: "Descricao",
                  hintText: "Digite descricao.."
                ),
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: ()=> Navigator.pop(context), 
            child: Text("Cancelar")
            ),
             FlatButton(
              onPressed: (){ 
                _salvarAtualizarAnotacao(anotacaoSelecionada :anotacao);
              }, 
            child: Text("$TextoSalvarAtualizar")
            ),
          ],
        );
      }
);



}

_formatarData(String data){

  initializeDateFormatting("pt_BR");
  var formatador = DateFormat.yMMMEd("pt_BR");
  DateTime dataConvertida = DateTime.parse(data);
  String dataFormatada = formatador.format(dataConvertida);
  return dataFormatada;

}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacao();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Anotações"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
       children: [
         Expanded(child: ListView.builder(
           itemCount: _anotacoes.length,
           itemBuilder: (context,index){

             final anotacao = _anotacoes[index];
             return Card(
               child: ListTile(title: Text(anotacao.titulo),
               subtitle: Text("${anotacao.data} - ${anotacao.descricao}") ,
               trailing:  Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   GestureDetector(
                     onTap: (){
                       _exibeTelaCadastro(anotacao:anotacao);
                     },
                     child: Padding(padding: EdgeInsets.only(right: 16),
                     child: Icon(
                       Icons.edit,
                       color: Colors.green,
                     ),
                     ),
                   ),
                    GestureDetector(
                     onTap: (){
                       _removerAnotacao( anotacao.id);
                     },
                     child: Padding(padding: EdgeInsets.only(right: 0),
                     child: Icon(
                       Icons.remove_circle,
                       color: Colors.red,
                     ),
                     ),
                   )
                 ],
               ),
               ),
               

             );
           }
           )
           )
       ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: () {
              _exibeTelaCadastro();
          }
          ),
    );
  }
}
