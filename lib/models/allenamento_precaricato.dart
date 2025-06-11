class AllenamentoPrecaricato { //a differenza di allenamento, qui non possono essere modificati, aggiunti o eliminati, quindi basta solo questo
  final String nome;
  final String tipo;
  final String difficolta;
  final String descrizione;
  bool preferito;

  AllenamentoPrecaricato({
    required this.nome,
    required this.tipo,
    required this.difficolta,
    required this.descrizione,
    this.preferito = false,
  });
}