import 'package:flutter/material.dart';
import '../models/allenamento.dart';
import '../services/database_helper.dart';

class CreaAllenamentoScreen extends StatefulWidget {
  const CreaAllenamentoScreen({super.key});
 //schermata per la creazione di un nuovo allenamento
  @override
  _CreaAllenamentoScreenState createState() => _CreaAllenamentoScreenState();
}

class _CreaAllenamentoScreenState extends State<CreaAllenamentoScreen> {
  final _formKey = GlobalKey<FormState>(); //chiave globale per la validazione del modulo
  final _nomeController = TextEditingController(); //i controllori dei vari campi
  final _durataController = TextEditingController();
  final _calorieController = TextEditingController();
  final _noteController = TextEditingController();
  String _tipo = 'Corsa'; //variabile per memorizzare il tipo di allenamento selezionato (default è Corsa)
  DateTime _data = DateTime.now(); //variabile per memorizzare la data dell'allenamento

  Future<void> _salvaAllenamento() async { //salva il nuovo allenamento nel database
    if (!_formKey.currentState!.validate()) return; //valida tutti i campi del modulo; se non validi, la funzione si interrompe

    final nuovoAllenamento = Allenamento( //crea un nuovo oggetto Allenamento con i dati inseriti
      nome: _nomeController.text,
      tipo: _tipo,
      data: _data,
      durata: int.parse(_durataController.text), //converte il testo in un numero intero per durata e calorie
      calorie: int.parse(_calorieController.text),
      note: _noteController.text,
    );

    await DatabaseHelper().insertAllenamento(nuovoAllenamento); //inserisce il nuovo allenamento nel database

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Allenamento salvato.')));
    Navigator.pop(context); //torna alla schermata precedente
  }

  Future<void> _scegliData() async { //permette all'utente di selezionare una data tramite un selettore
    final dataScelta = await showDatePicker( //mostra il selettore di data come un calendario
      context: context,
      initialDate: _data, //data iniziale pre-selezionata (oggi) e sotto i limiti degli anni
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataScelta != null) { //se l'utente ha selezionato una data
      setState(() => _data = dataScelta); //aggiorna la data e ricostruisce il widget
    }
  }

  @override
  Widget build(BuildContext context) { //costruisce l'interfaccia utente della schermata
    return Scaffold( //la struttura base di una schermata Flutter
      appBar: AppBar(title: Text('Nuovo Allenamento')),
      body: SingleChildScrollView( //permette lo scroll del contenuto se supera le dimensioni dello schermo
        padding: EdgeInsets.all(16),
        child: Form( //widget che raggruppa e valida i campi di input
          key: _formKey, //assegna la chiave per la validazione del modulo
          child: Column(
            children: [
              TextFormField( //campo di testo per il nome dell'allenamento
                controller: _nomeController, //collega il campo al controllore del testo
                decoration: InputDecoration(labelText: 'Nome allenamento'),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci un nome' : null, //validatore per campo obbligatorio
              ),
              SizedBox(height: 12),
              ListTile( //elemento lista per mostrare la data e permettere di modificarla
                title: Text('Data: ${_data.day}-${_data.month}-${_data.year}'), //mostra la data formattata
                trailing: Icon(Icons.calendar_today),
                onTap: _scegliData, //al tocco, apre il selettore di data
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>( //praticamente lo spinner per Flutter, un menu a tendina per scegliere il tipo di allenamento
                value: _tipo, //valore attualmente selezionato
                items: ['Corsa', 'Pesi', 'Ginnastica']
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))) //mappa ogni opzione in un DropdownMenuItem
                    .toList(),
                onChanged: (val) => setState(() => _tipo = val!), //aggiorna il tipo selezionato quando cambia il valore
                decoration: InputDecoration(labelText: 'Tipo di allenamento'),
              ),
              SizedBox(height: 12),
              TextFormField( //campo di testo per la durata
                controller: _durataController,
                decoration: InputDecoration(labelText: 'Durata (minuti)'),
                keyboardType: TextInputType.number, //tastiera numerica
                validator: (value) => value == null || value.isEmpty ? 'Inserisci la durata' : null, //validatore per campo obbligatorio
              ),
              SizedBox(height: 12),
              TextFormField( //campo di testo per le calorie
                controller: _calorieController,
                decoration: InputDecoration(labelText: 'Calorie bruciate'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Inserisci le calorie' : null,
              ),
              SizedBox(height: 12),
              TextFormField( //campo di testo per le note
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Note'),
                maxLines: 3, //permette l'inserimento su più righe (max 3)
              ),
              SizedBox(height: 20),
              ElevatedButton( //pulsante per salvare l'allenamento
                onPressed: _salvaAllenamento, //chiama la funzione per salvare l'allenamento al tocco
                child: Text('Salva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}