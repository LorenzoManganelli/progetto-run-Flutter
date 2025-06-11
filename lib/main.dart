import 'package:flutter/material.dart';
import 'screens/allenamenti_screen.dart';

void main() {
  runApp(RunPlusPlusApp()); //serve per avviare l'app
}

class RunPlusPlusApp extends StatelessWidget {
  const RunPlusPlusApp({super.key});

  @override
  Widget build(BuildContext context) { //prepara l'applicazione e il layout che useremo
    return MaterialApp(
      title: 'Run++',
      debugShowCheckedModeBanner: false, //check per vedere se è in debug mode
      theme: ThemeData.dark().copyWith( //tema scuro, con sotto i dettagli
        colorScheme: ColorScheme.dark(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
        ),
      ),
      home: AllenamentiScreen(), //la schermata iniziale sarà sempre allenamenti
    );
  }
}
