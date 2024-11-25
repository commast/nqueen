import 'package:flutter/material.dart';
import 'dart:math';
import 'package:nqueen/components/square.dart';
import 'package:nqueen/piece.dart';
class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _MyWidgetState();
}
Stopwatch stopwatch = new Stopwatch();

class _MyWidgetState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;
  int n = 8; // 기본 보드 크기
  bool isClear = false; // Clear 상태 체크
  final Random random = Random(); // 랜덤 객체 생성

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }
  void resetButton() {
    setState(() {
      _initializeBoard();
      isClear = false; // 리셋 시 Clear 상태 초기화
    });
  }
  void startTime(){
    stopwatch.start();
  }
  void _initializeBoard() {
    board = List.generate(n, (index) => List.generate(n, (index) => null));
  }

  // 퀸을 놓을 수 있는지 확인하는 함수
  bool canPlaceQueen(int row, int col) {
    for (int i = 0; i < n; i++) {
      if (board[row][i] != null || board[i][col] != null) {
        return false; // 같은 행 또는 열에 이미 퀸이 있음
      }
    }

    for (int i = -n; i <= n; i++) {
      if (row + i >= 0 && row + i < n && col + i >= 0 && col + i < n) {
        if (board[row + i][col + i] != null) {
          return false; // 대각선 오른쪽 아래
        }
      }
      if (row + i >= 0 && row + i < n && col - i >= 0 && col - i < n) {
        if (board[row + i][col - i] != null) {
          return false; // 대각선 왼쪽 아래
        }
      }
    }

    return true; 
  }

  void showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('이 위치에 퀸을 놓을 수 없습니다!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showClearMessage() {
    setState(() {
      isClear = true; // Clear 상태 업데이트
    });
  }

  void _showInputDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('보드 크기 입력'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "n 값을 입력하세요 (예: 8)"),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                setState(() {
                  n = int.tryParse(controller.text) ?? 8;
                  _initializeBoard(); // 보드 초기화
                  isClear = false; // Clear 상태 초기화
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void checkForClear() {
    bool allRowsFilled = true;
    for (int row = 0; row < n; row++) {
      if (!board[row].any((piece) => piece != null)) {
        allRowsFilled = false;
        break;
      }
    }
    if (allRowsFilled) {
      showClearMessage();
    }
  }

  // 백트래킹을 통한 N-Queens 문제 해결
  bool solveNQueens(int row) {
    if (row == n) {
      return true; // 모든 퀸을 놓았음
    }

    // 랜덤 시작 열 생성
    List<int> columns = List.generate(n, (index) => index)..shuffle(random);
    
    for (int col in columns) {
      if (canPlaceQueen(row, col)) {
        board[row][col] = ChessPiece(
          type: ChessPieceType.queen,
          isWhite: false,
          imagePath: 'lib/images/Queen.png',
        );

        if (solveNQueens(row + 1)) {
          return true; // 다음 행으로 진행
        }

        // 백트래킹
        board[row][col] = null;
      }
    }

    return false; // 퀸을 놓을 수 없는 경우
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: const Color.fromRGBO(242, 224, 86, 1)),
            borderRadius: BorderRadius.circular(20),
            color: Colors.amber,
          ),
          child: Text("N-Queen (20210794)"),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _showInputDialog, // n 값 입력 다이얼로그 호출
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: n * n, // n x n 보드
              //physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: n),
              itemBuilder: (context, index) {
                int row = index ~/ n;
                int col = index % n;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (board[row][col] == null && canPlaceQueen(row, col)) {
                        board[row][col] = ChessPiece(
                          type: ChessPieceType.queen,
                          isWhite: false,
                          imagePath: 'lib/images/Queen.png',
                        );
                        checkForClear(); // 퀸을 놓은 후 Clear 체크
                      } else {
                        showError();
                      }
                    });
                  },
                  child: Square(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: resetButton, icon: Icon(Icons.album)),
              IconButton(
                icon: Icon(Icons.ad_units_outlined),
                onPressed: () {
                  stopwatch.reset();
                  startTime(); 
                  resetButton(); 
                  bool result = solveNQueens(0); 
                  stopwatch.stop(); 
                  setState(() {});
                },
              ),
              Text("수행시간: ${stopwatch.elapsed}"),
            ],
          ),
          if (isClear) // Clear 메시지 표시
            Center(
              child: Text(
                'Clear',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  bool isWhite(int index) {
    return (index ~/ n + index) % 2 == 0;
  }
}
