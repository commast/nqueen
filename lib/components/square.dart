import 'package:flutter/material.dart';
import 'package:nqueen/piece.dart';
class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  const Square({super.key, required this.isWhite,required this.piece});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isWhite ? Colors.brown[300] : Colors.brown[800],
      child: piece != null? Image.asset(piece!.imagePath) : null,
    );
  }
}