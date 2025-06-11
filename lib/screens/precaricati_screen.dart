import 'package:flutter/material.dart';
import '../models/allenamento_precaricato.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrecaricatiScreen extends StatefulWidget {
  const PrecaricatiScreen({super.key});
  //schermata per visualizzare gli allenamenti precaricati
  @override
  _PrecaricatiScreenState createState() => _PrecaricatiScreenState();
}

class _PrecaricatiScreenState extends State<PrecaricatiScreen> { //prepara le tre caselle per il filtraggio e gestisce lo stato della schermata (e i valori di default)
  final _controllerNome = TextEditingController(); //per nome
  String _filtroDifficolta = 'Tutte'; //per difficoltà
  String _filtroTipo = 'Tutte'; //per tipo

  List<AllenamentoPrecaricato> _allenamentiTotali = []; //lista completa di tutti gli allenamenti precaricati
  List<AllenamentoPrecaricato> _allenamentiFiltrati = []; //lista degli allenamenti da mostrare, dopo aver applicato i filtri (creare due liste non so se è la soluzione migliore)

  int _selectedIndex = 1; //indice per la barra sotto (1 è i precaricati)

  @override
  void initState() { //viene chiamato all'inizializzazione della schermata
    super.initState();
    _caricaAllenamenti(); //carica gli allenamenti precaricati e i preferiti
  }

  void _caricaAllenamenti() async { //tutti gli elementi precaricati. Se avessi avuto più tempo li avrei messi in un db, ma così funziona
    _allenamentiTotali = [
      AllenamentoPrecaricato(
        nome: 'Cardio Facile',
        tipo: 'Corsa',
        difficolta: 'Facile',
        descrizione: 'Allenamento base di corsa per principianti.',
      ),
      AllenamentoPrecaricato(
        nome: 'Circuito Forza',
        tipo: 'Pesi',
        difficolta: 'Intermedio',
        descrizione: 'Allenamento per forza con pesi e squat.',
      ),
      AllenamentoPrecaricato(
        nome: 'HIIT Avanzato',
        tipo: 'Ginnastica',
        difficolta: 'Difficile',
        descrizione: 'Sessione intensa a intervalli ad alta intensità.',
      ),
      AllenamentoPrecaricato(
        nome: 'Sprint 20',
        tipo: 'Corsa',
        difficolta: 'Intermedio',
        descrizione: '20 minuti di sprint alternati a camminata.',
      ),
      AllenamentoPrecaricato(
        nome: 'Gambe e Glutei',
        tipo: 'Pesi',
        difficolta: 'Intermedio',
        descrizione: 'Allenamento con focus su gambe e glutei.',
      ),
      AllenamentoPrecaricato(
        nome: 'Yoga Base',
        tipo: 'Ginnastica',
        difficolta: 'Facile',
        descrizione: 'Stretching e respirazione per principianti.',
      ),
      AllenamentoPrecaricato(
        nome: 'Pesi Intensivi',
        tipo: 'Pesi',
        difficolta: 'Difficile',
        descrizione: 'Allenamento avanzato con carichi pesanti.',
      ),
      AllenamentoPrecaricato(
        nome: 'Corsa Lunga',
        tipo: 'Corsa',
        difficolta: 'Difficile',
        descrizione: '10 km di corsa continua a ritmo costante.',
      ),
      AllenamentoPrecaricato(
        nome: 'Core Stability',
        tipo: 'Ginnastica',
        difficolta: 'Intermedio',
        descrizione: 'Allenamento mirato per addome e schiena.',
      ),
      AllenamentoPrecaricato(
        nome: 'Full Body 30',
        tipo: 'Pesi',
        difficolta: 'Facile',
        descrizione: '30 minuti di esercizi total body a basso impatto.',
      ),
      AllenamentoPrecaricato(
        nome: 'Tabata Training',
        tipo: 'Ginnastica',
        difficolta: 'Difficile',
        descrizione: 'Circuiti intensi a intervalli di 20s/10s.',
      ),
      AllenamentoPrecaricato(
        nome: 'Jogging Relax',
        tipo: 'Corsa',
        difficolta: 'Facile',
        descrizione: 'Sessione leggera per scaricare lo stress.',
      ),
    ];

    await _caricaPreferitiDaMemoria(); //recupera gli allenamenti segnati come preferiti dalla memoria locale. Await attende che l'operazione si svolta prima di continuare
    _applicaFiltri(); //applica i filtri e l'ordinamento iniziale
  }

  void _applicaFiltri() { //filtra e ordina la lista degli allenamenti
    String nome = _controllerNome.text.toLowerCase(); //prende il testo dal campo di ricerca e lo converte in minuscolo (apparentemente il testo serve in minuscolo)

    setState(() { //aggiorna lo stato della UI
      _allenamentiFiltrati = _allenamentiTotali.where((a) { //filtra la lista di tutti gli allenamenti e poi sotto fa le tre verifiche di corrispondenza
        final matchNome = nome.isEmpty || a.nome.toLowerCase().contains(nome); //nome
        final matchDifficolta = _filtroDifficolta == 'Tutte' || a.difficolta == _filtroDifficolta; //difficoltà
        final matchTipo = _filtroTipo == 'Tutte' || a.tipo == _filtroTipo; //tipo
        return matchNome && matchDifficolta && matchTipo; //fa il return di SOLO quelli che corrispondono con tutti i criteri (Tutte vale come jolly)
      }).toList();

      _allenamentiFiltrati.sort((a, b) { //ordina la lista filtrata
        if (a.preferito && !b.preferito) return -1; //i preferiti vanno prima
        if (!a.preferito && b.preferito) return 1; //i non preferiti vanno dopo
        return 0; //mantiene l'ordine originale se entrambi sono preferiti/non preferiti
      });
    });
  }

  void _togglePreferito(AllenamentoPrecaricato a) async { //cambia lo stato di preferito di un allenamento e lo salva
    setState(() {
      a.preferito = !a.preferito; //inverte lo stato di preferito (MOLTO più comodo di settarlo come uno o l'altro)
    });

    final prefs = await SharedPreferences.getInstance(); //ottiene un'istanza di SharedPreferences per la memoria locale
    final nomiPreferiti = _allenamentiTotali //crea una lista dei nomi degli allenamenti preferiti
        .where((a) => a.preferito)
        .map((a) => a.nome)
        .toList();

    await prefs.setStringList('preferiti_precaricati', nomiPreferiti); //salva la lista dei nomi preferiti

    _applicaFiltri(); //riordina la lista per mostrare i preferiti in cima
  }

  void _onItemTapped(int index) { //gestisce il tap sulla BottomNavigationBar
    if (index == 0) { //se l'indice è 0 (Allenamenti)
      Navigator.pop(context); //torna alla schermata precedente
    } else {
      setState(() => _selectedIndex = index); //altrimenti aggiorna l'indice selezionato nella BottomNavigationBar
    }
  }

  Future<void> _caricaPreferitiDaMemoria() async { //carica lo stato dei preferiti dalla memoria locale, per mantenerlo anche alla chiusura dell'app
    final prefs = await SharedPreferences.getInstance(); //ottiene un'istanza di SharedPreferences
    final listaSalvata = prefs.getStringList('preferiti_precaricati') ?? []; //recupera la lista dei nomi preferiti, o una lista vuota se non c'è nulla

    for (var a in _allenamentiTotali) { //per ogni allenamento totale
      a.preferito = listaSalvata.contains(a.nome); //imposta il suo stato preferito in base alla lista salvata
    }
  }


  @override
  Widget build(BuildContext context) { //costruisce l'interfaccia utente della schermata
    return Scaffold(
      appBar: AppBar(title: Text('Allenamenti Precaricati')), //barra superiore con il titolo
      body: Padding( //aggiunge spaziatura per renderlo meno orribile
        padding: const EdgeInsets.all(12.0),
        child: Column( //organizza i widget in una colonna verticale
          children: [
            TextField( //la parte per l'inserimente del nome
              controller: _controllerNome,
              decoration: InputDecoration(
                labelText: 'Cerca per nome', //etichetta del campo di testo predefinita
                prefixIcon: Icon(Icons.search), //icona della lente di ingrandimento, grazie Flutter
              ),
            ),
            SizedBox(height: 12), //spazio verticale
            Row( //i due dropdown per i filtri affiancati
              children: [
                Expanded( //il dropdown occupa lo spazio disponibile
                  child: DropdownButtonFormField<String>(
                    value: _filtroDifficolta, //valore attualmente selezionato
                    items: ['Tutte', 'Facile', 'Intermedio', 'Difficile'] //opzioni del dropdown
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))) //crea le voci del menu
                        .toList(),
                    onChanged: (val) => setState(() => _filtroDifficolta = val!), //aggiorna il filtro quando cambia la selezione
                    decoration: InputDecoration(labelText: 'Difficoltà'), //etichetta del dropdown
                  ),
                ),
                SizedBox(width: 12), //spazio orizzontale
                Expanded( //l'altro dropdown occupa lo spazio disponibile, virtualmente identico
                  child: DropdownButtonFormField<String>(
                    value: _filtroTipo,
                    items: ['Tutte', 'Corsa', 'Pesi', 'Ginnastica']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _filtroTipo = val!),
                    decoration: InputDecoration(labelText: 'Tipologia'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton.icon( //pulsante per applicare i filtri
              onPressed: _applicaFiltri, //chiama la funzione per applicare i filtri quand premuto
              icon: Icon(Icons.filter_alt),
              label: Text('Cerca'), //testo del pulsante
            ),
            SizedBox(height: 12),
            Expanded( //lista di tutti gli allenamenti filtrati e scrollabile (di base sono tutti però, in teoria il "no filtri" è un filtro anch'esso)
              child: _allenamentiFiltrati.isEmpty //controlla se la lista filtrata è vuota
                  ? Center(child: Text('Nessun allenamento trovato.')) //mostra un messaggio se non ci sono allenamenti (in teoria non serve, ma la metto comunque)
                  : ListView.builder( //altrimenti costruisce la lista di allenamenti
                itemCount: _allenamentiFiltrati.length, //numero di elementi nella lista
                itemBuilder: (context, index) { //funzione per costruire ogni singolo elemento della lista
                  final a = _allenamentiFiltrati[index];
                  return Card( //ogni allenamento è visualizzato in una Card
                    child: ExpansionTile( //permette di espandere/comprimere l'elemento dei dettagli
                      title: Row(
                        children: [
                          Expanded( //il testo del nome occupa lo spazio rimanente
                            child: Text('${a.nome} (${a.difficolta})'),
                          ),
                          IconButton( //pulsante renderlo preferito (o togliendo il preferito)
                            icon: Icon(
                              a.preferito ? Icons.star : Icons.star_border, //icona stella piena se preferito, vuota altrimenti
                              color: a.preferito ? Colors.amber : Colors.grey,
                            ),
                            onPressed: () => _togglePreferito(a), //chiama la funzione per gestire i preferiti
                          ),
                        ],
                      ),
                      children: [ //contenuto mostrato quando l'elemento è espanso
                        Padding( //spaziatura interna per la descrizione
                          padding: const EdgeInsets.all(12.0),
                          child: Text(a.descrizione), //testo della descrizione dell'allenamento
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar( //barra di navigazione in basso
        currentIndex: _selectedIndex, //indice della voce attualmente selezionata
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary, //colore dell'icona/testo selezionato
        unselectedItemColor: Colors.grey, //colore dell'icona/testo non selezionato
        items: const [ //le voci della barra di navigazione (solo due per ora, ma è facilmente espandibile)
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Allenamenti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Precaricati',
          ),
        ],
      ),
    );
  }
}
