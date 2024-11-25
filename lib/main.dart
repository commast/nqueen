import 'package:flutter/material.dart';
import 'package:nqueen/game_board.dart';
void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameBoard(),
    );
  }
}

