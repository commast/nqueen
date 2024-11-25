enum ChessPieceType{queen}

class ChessPiece{
  final ChessPieceType type;
  final bool isWhite;
  final String imagePath;
  bool isQueen;
  ChessPiece({required this.type, required this.isWhite, required this.imagePath,this.isQueen=false});

  
} 