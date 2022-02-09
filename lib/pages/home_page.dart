import 'package:date_format/date_format.dart';
import 'package:db_sqflite_notas_diarias/helper/anotations_helper_db.dart';
import 'package:db_sqflite_notas_diarias/models/anotation.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

TextEditingController _titleController = TextEditingController();
TextEditingController _descriptionController = TextEditingController();
AnotacoesHelperDb _db = AnotacoesHelperDb();
List<Anotation> anotations = [];

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  _saveOrEditAnotation({Anotation? selectedAnotation}) async {
    Anotation anotation = Anotation(
      title: _titleController.text,
      description: _descriptionController.text,
      date: DateTime.now().toString(),
    );

    if (selectedAnotation == null) {
      //salvando
      bool _isValid = _formKey.currentState!.validate();
      if (!_isValid) {
        return;
      }
      int resultId = await _db.saveAnotation(anotation);
    } else {
      //atualizando
      bool _isValid = _formKey.currentState!.validate();
      if (!_isValid) {
        return;
      }
      selectedAnotation.title = _titleController.text;
      selectedAnotation.description = _descriptionController.text;
      await _db.updateAnotation(selectedAnotation);
    }

    ///na primeira vez que chama o _db, o banco de dados ainda não foi criado,
    ///porém, no _db.saveAnotation ele chama o get do "db" e nesse get, é verificado
    ///se já foi criado um banco de dados e caso não esteja criado ainda, ele cria
    ///um no próprio get

    _titleController.clear();
    _descriptionController.clear();
  }

  _getAnotations() async {
    anotations.clear();
    List restoredAnotations = await _db.getAnotations();

    for (var x = 0; x < restoredAnotations.length; x++) {
      setState(() {
        anotations.add(
          Anotation(
              title: restoredAnotations[x]['title'],
              description: restoredAnotations[x]['description'],
              date: restoredAnotations[x]['date'],
              id: restoredAnotations[x]['id']),
        );
      });
    }

    return anotations;
  }

  _saveOrUpdateNote({Anotation? anotation}) {
    if (anotation == null) {
      //salvando
      _titleController.clear();
      _descriptionController.clear();
    } else {
      //editando
      _titleController.text = anotation.title;
      _descriptionController.text = anotation.description;
    }
    //esse if/else serve só pra verificar quais informações devem ser exibidas
    //quando abrir o showDialog a seguir

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Digite o título';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Digite a descrição';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    bool _isValid = _formKey.currentState!.validate();
                    if (!_isValid) {
                      return;
                    }
                    _saveOrEditAnotation(selectedAnotation: anotation);
                    _getAnotations();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _deleteAnotation({Anotation? selectedAnotation}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Deseja realmente excluir a transação?',
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Não'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      anotations.removeWhere(
                        (element) => element.id == selectedAnotation!.id,
                      );
                    });
                    _db.deleteAnotation(selectedAnotation!);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Sim'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getAnotations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text('Notas diárias'),
      ),
      body: ListView.builder(
        itemCount: anotations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 1,
                  )),
              elevation: 3,
              child: ListTile(
                title: Text(anotations[index].title),
                subtitle: Text('${formatDate(DateTime.parse(
                      anotations[index].date,
                    ), [
                      dd,
                      '/',
                      mm,
                      '/',
                      yyyy,
                      '  ',
                      HH,
                      ':',
                      mm,
                    ])} - ${anotations[index].description}'),
                visualDensity: VisualDensity.compact,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _saveOrUpdateNote(anotation: anotations[index]);
                      },
                      child: const Icon(
                        Icons.edit,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        _deleteAnotation(
                          selectedAnotation: anotations[index],
                        );
                      },
                      child: const Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          _saveOrUpdateNote();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
