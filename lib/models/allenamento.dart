class Allenamento { //modello degli allenamenti, con alcune componenti per permettere di crearli/modificarli/eliminarli
  int? id;
  String nome;
  String tipo;
  DateTime data;
  int durata; // in minuti
  int calorie;
  String note;

  Allenamento({ //nota: required vuole dire che è obbligatoria
    this.id,
    required this.nome,
    required this.tipo,
    required this.data,
    required this.durata,
    required this.calorie,
    required this.note,
  });

  Map<String, dynamic> toMap() { //converte il singolo elemento in Map, rendendo l'oggetto generato usabile
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'data': data.toIso8601String(), //per le date si usa questo
      'durata': durata,
      'calorie': calorie,
      'note': note,
    };
  }

  factory Allenamento.fromMap(Map<String, dynamic> map) { //permette di generare le singole istanze del modello
    return Allenamento(
      id: map['id'],
      nome: map['nome'],
      tipo: map['tipo'],
      data: DateTime.parse(map['data']),
      durata: map['durata'],
      calorie: map['calorie'],
      note: map['note'],
    );
  }
}
