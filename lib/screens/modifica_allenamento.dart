import 'package:flutter/material.dart';
import '../models/allenamento.dart';
import '../services/database_helper.dart';

class ModificaAllenamentoScreen extends StatefulWidget { //schermata per la modifica di un allenamento esistente
  final Allenamento allenamento; //l'allenamento da modificare, passato come parametro obbligatorio

  const ModificaAllenamentoScreen({super.key, required this.allenamento}); //costruttore che richiede l'allenamento

  @override
  _ModificaAllenamentoScreenState createState() => _ModificaAllenamentoScreenState();
}

class _ModificaAllenamentoScreenState extends State<ModificaAllenamentoScreen> { //gestisce lo stato e la logica della schermata di modifica
  final _formKey = GlobalKey<FormState>(); //chiave globale per la validazione del modulo
  late TextEditingController _nomeController; //controllori per il campi
  late TextEditingController _durataController;
  late TextEditingController _calorieController;
  late TextEditingController _noteController;
  late String _tipo; //variabili per memorizzare il tipo e data di allenamento
  late DateTime _data;

  @override
  void initState() { //metodo chiamato all'inizializzazione dello stato del widget
    super.initState();
    final a = widget.allenamento; ////ottiene l'allenamento passato dal widget padre
    _nomeController = TextEditingController(text: a.nome); //inizializza i controllori con i valori presi
    _durataController = TextEditingController(text: a.durata.toString());
    _calorieController = TextEditingController(text: a.calorie.toString());
    _noteController = TextEditingController(text: a.note);
    _tipo = a.tipo;
    _data = a.data;
  }

  Future<void> _salvaModifiche() async { //salva le modifiche apportate all'allenamento nel database
    if (!_formKey.currentState!.validate()) return; //valida i campi del modulo e se non lo sono, la funzione si interrompe

    final allenamentoModificato = Allenamento( //crea un nuovo oggetto Allenamento con i dati aggiornati
      id: widget.allenamento.id, //MA mantiene l'ID originale dell'allenamento
      nome: _nomeController.text,
      tipo: _tipo,
      data: _data,
      durata: int.parse(_durataController.text),
      calorie: int.parse(_calorieController.text),
      note: _noteController.text,
    );

    await DatabaseHelper().updateAllenamento(allenamentoModificato);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Modifiche salvate.')));
    Navigator.pop(context);
  }

  Future<void> _eliminaAllenamento() async { //rimuove l'allenamento
    await DatabaseHelper().deleteAllenamento(widget.allenamento.id!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Allenamento eliminato.')));
    Navigator.pop(context);
  }

  Future<void> _scegliData() async { //uguale a crea
    final dataScelta = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataScelta != null) {
      setState(() => _data = dataScelta);
    }
  }

  //quasi uguale alla creazione
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifica Allenamento')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome allenamento'),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci un nome' : null,
              ),
              SizedBox(height: 12),
              ListTile(
                title: Text('Data: ${_data.day}-${_data.month}-${_data.year}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _scegliData,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                items: ['Corsa', 'Pesi', 'Ginnastica']
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                    .toList(),
                onChanged: (val) => setState(() => _tipo = val!),
                decoration: InputDecoration(labelText: 'Tipo di allenamento'),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _durataController,
                decoration: InputDecoration(labelText: 'Durata (minuti)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Inserisci la durata' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _calorieController,
                decoration: InputDecoration(labelText: 'Calorie bruciate'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Inserisci le calorie' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Note'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton( //avvia il salvataggio
                onPressed: _salvaModifiche,
                child: Text('Salva Modifiche'),
              ),
              SizedBox(height: 8),
              ElevatedButton( //avvia l'eliminazione
                onPressed: _eliminaAllenamento,
                child: Text('Elimina Allenamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
