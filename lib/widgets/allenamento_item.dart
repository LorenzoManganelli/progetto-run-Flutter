import 'package:flutter/material.dart';
import '../models/allenamento.dart';
import 'package:intl/intl.dart';

class AllenamentoItem extends StatelessWidget {
  final Allenamento allenamento;

  const AllenamentoItem({super.key, required this.allenamento});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd-MM-yyyy'); //format della data

    return Card( //l'intero contenuto dell'elemento è racchiuso in una card, cioè il singolo elemento
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile( //un widget che organizza il contenuto della card
        title: Text('${allenamento.nome} (${allenamento.tipo})'),
        subtitle: Text(
          'Data: ${dateFormatter.format(allenamento.data)}\nDurata: ${allenamento.durata} min - ${allenamento.calorie} kcal',
        ),
        isThreeLine: true, //è diviso in tre righe
        trailing: Icon(Icons.chevron_right), //ma che bello, le icone sono già incluse e facili da usare
      ),
    );
  }
}
