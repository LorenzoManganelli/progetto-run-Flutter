import 'package:flutter/material.dart';
import '../models/allenamento.dart';
import '../services/database_helper.dart';
import '../widgets/allenamento_item.dart';
import 'crea_allenamento.dart';
import 'modifica_allenamento.dart';
import 'precaricati_screen.dart';

class AllenamentiScreen extends StatefulWidget {
  const AllenamentiScreen({super.key});
 //schermata principale per la gestione degli allenamenti
  @override
  _AllenamentiScreenState createState() => _AllenamentiScreenState();
}

class _AllenamentiScreenState extends State<AllenamentiScreen> { //gestisce lo stato e la logica della schermata degli allenamenti
  List<Allenamento> _allenamenti = []; //lista degli allenamenti mostrati a schermo
  String _criterioOrdine = 'data'; //criterio attuale per l'ordinamento degli allenamenti (di default è per data)
  int _selectedIndex = 0; //indice per la barra sotto (0 è gli allenamenti)

  @override
  void initState() { //metodo chiamato all'inizializzazione dello stato del widget
    super.initState();
    _caricaAllenamenti(); //carica gli allenamenti dal database all'avvio della schermata
  }

  Future<void> _caricaAllenamenti() async {
    List<Allenamento> lista = await DatabaseHelper().getAllenamenti(); //recupera tutti gli allenamenti dal database
    setState(() { //aggiorna lo stato del widget per ricostruire la UI aggiornata
      _allenamenti = _ordinaAllenamenti(lista, _criterioOrdine); //ordina la lista degli allenamenti e la assegna alla lista visualizzata
    });
  }

  List<Allenamento> _ordinaAllenamenti(List<Allenamento> lista, String criterio) { //ordina la lista
    List<Allenamento> ordinata = [...lista]; //crea una copia della lista per evitare di modificare l'originale
    switch (criterio) { //controlla il criterio di ordinamento
      case 'nome':
        ordinata.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase())); //ordina per nome
        break;
      case 'tipo':
        ordinata.sort((a, b) => a.tipo.toLowerCase().compareTo(b.tipo.toLowerCase())); //ordina per tipo
        break;
      case 'data':
      default:
        ordinata.sort((a, b) => b.data.compareTo(a.data)); //ordina per data, dalla più recente alla più vecchia
    }
    return ordinata; //restituisce la lista ordinata
  }

  void _cambiaOrdine(String criterio) { //cambia il criterio di ordinamento e riordina la lista
    setState(() { //aggiorna lo stato del widget
      _criterioOrdine = criterio; //imposta il nuovo criterio di ordinamento
      _allenamenti = _ordinaAllenamenti(_allenamenti, criterio); //riordina la lista corrente degli allenamenti
    });
  }

  void _vaiACreazione() async { //naviga alla schermata di creazione di un nuovo allenamento
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CreaAllenamentoScreen()),); //apre la schermata CreaAllenamentoScreen e attende il suo completamento
    _caricaAllenamenti(); //ricarica gli allenamenti dopo essere tornati dalla schermata di creazione per visualizzare le modifiche
  }

  void _vaiAModifica(Allenamento allenamento) async { //naviga alla schermata di modifica di un allenamento esistente (identico a sopra, cambia solo la schermata)
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ModificaAllenamentoScreen(allenamento: allenamento)),);
    _caricaAllenamenti();
  }

  void _onItemTapped(int index) { //gestisce la selezione delle voci nella BottomNavigationBar
    setState(() => _selectedIndex = index); //aggiorna l'indice selezionato per evidenziare la voce corretta

    if (index == 1) { //se l'indice è 1 (Precaricati)
      Navigator.push(context, MaterialPageRoute(builder: (_) => PrecaricatiScreen()),); //naviga alla schermata degli allenamenti precaricati
    }
  }

  //costruisce la schermata stessa
  @override
  Widget build(BuildContext context) {
    return Scaffold( //la struttura base di una schermata Flutter
      appBar: AppBar(title: Text('Allenamenti')), //barra in alto
      body: Column( //il contenuto principale della schermata
        children: [
          Expanded( //la lista degli allenamenti personalizzati occupa tutto lo spazio rimanente
            child: _allenamenti.isEmpty //controlla se la lista degli allenamenti è vuota, e se lo è mostra un messaggio al centro
                ? Center(child: Text('Nessun allenamento salvato.'))
                : ListView.builder( //altrimenti questo widget crea la lista degli allenamenti, costruendo un item per ogni elemento
              itemCount: _allenamenti.length, //numero di elementi nella lista
              itemBuilder: (context, index) { //funzione che costruisce il widget per ogni singolo allenamento
                final a = _allenamenti[index]; //allenamento corrente
                return GestureDetector( //semplicemente rende premibile ogni allenamento nella lista per andare nella schermata di modifica
                  onTap: () => _vaiAModifica(a),
                  child: AllenamentoItem(allenamento: a),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), //margini estetici
            child: Row( //organizza i pulsanti di ordinamento e il pulsante aggiungi in una riga orizzontale
              children: [ //pulsanti per ordinare per data, tipo o nome
                _buildOrdinamentoButton('Data', 'data'),
                SizedBox(width: 4),
                _buildOrdinamentoButton('Tipo', 'tipo'),
                SizedBox(width: 4),
                _buildOrdinamentoButton('Nome', 'nome'),
                SizedBox(width: 8),
                FloatingActionButton.small( //pulsante circolare per aggiungere un nuovo allenamento
                  onPressed: _vaiACreazione, //chiama la funzione per navigare alla schermata di creazione
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.add), //la icona +
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar( //il menu in basso per navigare tra le schermate
        currentIndex: _selectedIndex, //l'indice della voce attualmente selezionata
        onTap: _onItemTapped, //gestisce il tocco su una voce della barra di navigazione
        selectedItemColor: Theme.of(context).colorScheme.primary, //colore selezionati
        unselectedItemColor: Colors.grey, //colore non selezionati
        items: const [ //le voci della barra di navigazione
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

  Widget _buildOrdinamentoButton(String testo, String criterio) { //funzione ausiliaria per costruire i pulsanti di ordinamento
    final isSelected = _criterioOrdine == criterio; //verifica se il criterio attuale corrisponde a quello del pulsante
    return Expanded( //il pulsante occupa lo spazio disponibile
      child: ElevatedButton(
        style: ElevatedButton.styleFrom( //il colore dipende se è il criterio di ordinamento attualmente selezionato
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[600],
          foregroundColor: Colors.black,
        ),
        onPressed: () => _cambiaOrdine(criterio), //chiama la funzione per cambiare l'ordine quando il pulsante viene premuto
        child: Text(testo, textAlign: TextAlign.center), //testo del pulsante centrato
      ),
    );
  }
}