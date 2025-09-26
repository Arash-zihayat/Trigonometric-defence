import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const TrigDefenseApp());
}

class TrigDefenseApp extends StatelessWidget {
  const TrigDefenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trigonometric Defense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'TRIGONOMETRIC\nDEFENSE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Defend using Math!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('START GAME'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showInstructions(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('HOW TO PLAY'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Play'),
          content: const Text(
            '• Your defense is at the center of the circle\n'
            '• Enemies spawn on the circumference\n'
            '• Calculate trigonometric functions to aim\n'
            '• Tap enemies to shoot them\n'
            '• Use sin, cos, and tan to find angles\n'
            '• Survive as long as possible!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}

enum TrigFunction { cos, sin, tan, cot }

class Enemy {
  double angle;
  double radius;
  bool isAlive;
  Color color;
  TrigFunction trigFunction;
  String label;
  
  Enemy({
    required this.angle,
    required this.radius,
    required this.trigFunction,
    this.isAlive = true,
    Color? color,
  }) : color = color ?? _getColorForFunction(trigFunction),
       label = _getLabelForFunction(trigFunction);
  
  static Color _getColorForFunction(TrigFunction func) {
    switch (func) {
      case TrigFunction.cos:
        return Colors.red;
      case TrigFunction.sin:
        return Colors.blue;
      case TrigFunction.tan:
        return Colors.green;
      case TrigFunction.cot:
        return Colors.purple;
    }
  }
  
  static String _getLabelForFunction(TrigFunction func) {
    switch (func) {
      case TrigFunction.cos:
        return 'COS';
      case TrigFunction.sin:
        return 'SIN';
      case TrigFunction.tan:
        return 'TAN';
      case TrigFunction.cot:
        return 'COT';
    }
  }
  
  double get x => radius * cos(angle);
  double get y => radius * sin(angle);
  
  // Calculate the correct trigonometric value (not distance)
  double getCorrectTrigValue() {
    switch (trigFunction) {
      case TrigFunction.cos:
        return cos(angle);
      case TrigFunction.sin:
        return sin(angle);
      case TrigFunction.tan:
        return tan(angle);
      case TrigFunction.cot:
        return 1 / tan(angle);
    }
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  Enemy? currentEnemy;
  int score = 0;
  int lives = 3;
  Timer? questionTimer;
  late AnimationController _rotationController;
  double centerX = 0;
  double centerY = 0;
  final double gameRadius = 150;
  
  // Quiz state
  List<double> answerChoices = [];
  double correctAnswer = 0;
  int timeLeft = 10;
  bool showingQuestion = false;
  
  // Important angles in degrees - only specific angles as requested
  final List<double> importantAngles = [0, 30, 45, 60, 90, 180, 270, 360];
  final List<TrigFunction> trigFunctions = [TrigFunction.cos, TrigFunction.sin, TrigFunction.tan, TrigFunction.cot];
  
  // Helper function to convert decimal to fraction string
  String _decimalToFraction(double value) {
    // Handle special cases
    if (value.abs() < 0.0001) return '0';
    if ((value - 1).abs() < 0.0001) return '1';
    if ((value + 1).abs() < 0.0001) return '-1';
    
    // Common trigonometric fractions
    final commonFractions = {
      0.5: '1/2',
      -0.5: '-1/2',
      0.707: '√2/2',
      -0.707: '-√2/2',
      0.866: '√3/2',
      -0.866: '-√3/2',
      1.732: '√3',
      -1.732: '-√3',
      0.577: '1/√3',
      -0.577: '-1/√3',
      0.333: '1/3',
      -0.333: '-1/3',
      0.667: '2/3',
      -0.667: '-2/3',
    };
    
    // Check for close matches to common fractions
    for (final entry in commonFractions.entries) {
      if ((value - entry.key).abs() < 0.01) {
        return entry.value;
      }
    }
    
    // For other values, try to find simple fractions
    for (int denominator = 2; denominator <= 10; denominator++) {
      for (int numerator = -10; numerator <= 10; numerator++) {
        if (numerator == 0) continue;
        double fraction = numerator / denominator;
        if ((value - fraction).abs() < 0.01) {
          return '$numerator/$denominator';
        }
      }
    }
    
    // If no simple fraction found, return rounded decimal
    return value.toStringAsFixed(3);
  }
  
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNewQuestion();
    });
  }
  
  void _startNewQuestion() {
    final random = Random();
    
    // Select random angle from important angles
    final angleDegrees = importantAngles[random.nextInt(importantAngles.length)];
    final angleRadians = angleDegrees * pi / 180;
    
    // Select random trigonometric function
    final trigFunc = trigFunctions[random.nextInt(trigFunctions.length)];
    
    // Create enemy at the selected angle
    currentEnemy = Enemy(
      angle: angleRadians,
      radius: gameRadius,
      trigFunction: trigFunc,
    );
    
    // Calculate correct answer
    correctAnswer = currentEnemy!.getCorrectTrigValue();
    
    // Generate answer choices
    _generateAnswerChoices();
    
    // Start timer
    timeLeft = 10;
    showingQuestion = true;
    
    _startQuestionTimer();
    
    setState(() {});
  }
  
  void _generateAnswerChoices() {
    final random = Random();
    answerChoices.clear();
    
    // Add correct answer
    answerChoices.add(correctAnswer);
    
    // Generate 3 wrong answers with better logic
    Set<double> usedAnswers = {correctAnswer};
    
    while (answerChoices.length < 4) {
      double wrongAnswer;
      
      // Generate plausible wrong answers based on common trigonometric values
      List<double> commonTrigValues = [
        0, 1, -1,           // 0, ±1
        0.5, -0.5,          // ±1/2
        0.707, -0.707,      // ±√2/2
        0.866, -0.866,      // ±√3/2
        1.732, -1.732,      // ±√3
        0.577, -0.577,      // ±1/√3
        0.333, -0.333,      // ±1/3
        0.667, -0.667,      // ±2/3
      ];
      
      wrongAnswer = commonTrigValues[random.nextInt(commonTrigValues.length)];
      
      // If we still need more variety, add some simple fractions
      if (random.nextBool() && answerChoices.length < 3) {
        List<double> simpleFractions = [0.25, -0.25, 0.75, -0.75, 0.2, -0.2, 0.8, -0.8];
        wrongAnswer = simpleFractions[random.nextInt(simpleFractions.length)];
      }
      
      // Round to 3 decimal places
      wrongAnswer = double.parse(wrongAnswer.toStringAsFixed(3));
      
      // Ensure it's different from existing answers
      if (!usedAnswers.contains(wrongAnswer) && 
          !usedAnswers.any((answer) => (answer - wrongAnswer).abs() < 0.01)) {
        answerChoices.add(wrongAnswer);
        usedAnswers.add(wrongAnswer);
      }
    }
    
    // Shuffle the choices
    answerChoices.shuffle();
  }
  
  void _startQuestionTimer() {
    questionTimer?.cancel();
    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          _timeUp();
        }
      });
    });
  }
  
  void _selectAnswer(double selectedAnswer) {
    questionTimer?.cancel();
    
    if ((selectedAnswer - correctAnswer).abs() < 0.01) {
      // Correct answer
      score += 10;
      _showResult(true, selectedAnswer);
    } else {
      // Wrong answer
      lives--;
      _showResult(false, selectedAnswer);
      if (lives <= 0) {
        _gameOver();
        return;
      }
    }
    
    // Start next question after delay
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _startNewQuestion();
      }
    });
  }
  
  void _timeUp() {
    questionTimer?.cancel();
    lives--;
    _showResult(false, 0, timeUp: true);
    
    if (lives <= 0) {
      _gameOver();
      return;
    }
    
    // Start next question after delay
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _startNewQuestion();
      }
    });
  }
  
  void _showResult(bool correct, double selectedAnswer, {bool timeUp = false}) {
    setState(() {
      showingQuestion = false;
    });
    
    String message;
    if (timeUp) {
      message = 'زمان تمام شد!\nپاسخ صحیح: ${_decimalToFraction(correctAnswer)}';
    } else if (correct) {
      message = 'آفرین! پاسخ درست است\n${currentEnemy!.label}: ${_decimalToFraction(correctAnswer)}';
    } else {
      message = 'پاسخ اشتباه!\nپاسخ صحیح: ${_decimalToFraction(correctAnswer)}\nپاسخ شما: ${_decimalToFraction(selectedAnswer)}';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: correct ? Colors.green : Colors.red,
      ),
    );
  }
  
  void _gameOver() {
    questionTimer?.cancel();
    
    // Ensure we're in a clean state
    setState(() {
      showingQuestion = false;
      currentEnemy = null;
    });
    
    // Use Future.delayed to ensure the dialog shows properly
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('بازی تمام شد!'),
              content: Text('امتیاز نهایی: $score'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to main menu
                  },
                  child: const Text('منوی اصلی'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    _resetGame(); // Restart game
                  },
                  child: const Text('بازی مجدد'),
                ),
              ],
            );
          },
        );
      }
    });
  }
  
  void _resetGame() {
    // Cancel any existing timers
    questionTimer?.cancel();
    
    setState(() {
      currentEnemy = null;
      score = 0;
      lives = 3;
      showingQuestion = false;
      timeLeft = 5;
      answerChoices.clear();
      correctAnswer = 0;
    });
    
    // Start new question after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _startNewQuestion();
      }
    });
  }
  
  @override
  void dispose() {
    questionTimer?.cancel();
    _rotationController.dispose();
    super.dispose();
  }
  
  Widget _buildQuestionUI() {
    if (currentEnemy == null) return const SizedBox();
    
    final angleDegrees = (currentEnemy!.angle * 180 / pi).toInt();
    
    return Column(
      children: [
        // Timer and question
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'زمان باقی‌مانده: $timeLeft ثانیه',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'مقدار ${currentEnemy!.label}($angleDegrees°) چقدر است؟',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Answer choices - ensure exactly 4 options are clearly visible
        Container(
          height: 120, // Reduced height for better fit
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              // Top row - 2 buttons
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: showingQuestion && answerChoices.isNotEmpty ? () => _selectAnswer(answerChoices[0]) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade700,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              answerChoices.isNotEmpty ? _decimalToFraction(answerChoices[0]) : '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: showingQuestion && answerChoices.length > 1 ? () => _selectAnswer(answerChoices[1]) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade700,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              answerChoices.length > 1 ? _decimalToFraction(answerChoices[1]) : '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom row - 2 buttons
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: showingQuestion && answerChoices.length > 2 ? () => _selectAnswer(answerChoices[2]) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade700,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              answerChoices.length > 2 ? _decimalToFraction(answerChoices[2]) : '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: showingQuestion && answerChoices.length > 3 ? () => _selectAnswer(answerChoices[3]) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade700,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              answerChoices.length > 3 ? _decimalToFraction(answerChoices[3]) : '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trigonometric Defense'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Score: $score | Lives: $lives',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            centerX = constraints.maxWidth / 2;
            centerY = constraints.maxHeight / 2;
            
            return Column(
              children: [
                // Game area
                Expanded(
                  flex: 3,
                  child: CustomPaint(
                    painter: GamePainter(
                      currentEnemy: currentEnemy,
                      centerX: centerX,
                      centerY: centerY * 0.6,
                      gameRadius: gameRadius,
                      rotationAnimation: _rotationController,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight * 0.6),
                  ),
                ),
                // Question area
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: showingQuestion && currentEnemy != null
                        ? _buildQuestionUI()
                        : const Center(
                            child: Text(
                              'در حال آماده سازی سوال بعدی...',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final Enemy? currentEnemy;
  final double centerX;
  final double centerY;
  final double gameRadius;
  final AnimationController rotationAnimation;
  
  GamePainter({
    required this.currentEnemy,
    required this.centerX,
    required this.centerY,
    required this.gameRadius,
    required this.rotationAnimation,
  }) : super(repaint: rotationAnimation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw desert sand dunes in background
    _drawDesertBackground(canvas, size, paint);
    
    // Draw game circle boundary (battlefield perimeter)
    paint.color = const Color(0xFF8B4513).withOpacity(0.6); // Brown boundary
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(Offset(centerX, centerY), gameRadius, paint);
    
    // Draw angle markers (compass directions)
    paint.color = const Color(0xFF654321).withOpacity(0.8);
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final x1 = centerX + (gameRadius - 20) * cos(angle);
      final y1 = centerY + (gameRadius - 20) * sin(angle);
      final x2 = centerX + gameRadius * cos(angle);
      final y2 = centerY + gameRadius * sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      
      // Draw angle labels with military styling
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(angle * 180 / pi).toInt()}°',
          style: const TextStyle(
            color: Color(0xFF2F4F2F), // Dark olive green
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final textX = centerX + (gameRadius + 15) * cos(angle) - textPainter.width / 2;
      final textY = centerY + (gameRadius + 15) * sin(angle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(textX, textY));
    }
    
    // Draw military defense base in center
    _drawMilitaryBase(canvas, paint);
    
    // Draw rotating radar/scanner
    _drawRadarScanner(canvas, paint);
    
    // Draw current soldier
    if (currentEnemy != null && currentEnemy!.isAlive) {
      final soldierX = centerX + currentEnemy!.x;
      final soldierY = centerY + currentEnemy!.y;
      
      _drawSoldier(canvas, paint, soldierX, soldierY, currentEnemy!);
    }
    
    // Draw crosshair at center
    paint.color = Colors.white;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX - 10, centerY),
      Offset(centerX + 10, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - 10),
      Offset(centerX, centerY + 10),
      paint,
    );
  }
  
  // Draw desert background with sand dunes
  void _drawDesertBackground(Canvas canvas, Size size, Paint paint) {
    // Draw sand dunes
    paint.color = const Color(0xFFDEB887).withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.65);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.7, size.width, size.height * 0.6);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  
  // Draw military defense base
  void _drawMilitaryBase(Canvas canvas, Paint paint) {
    // Main base structure
    paint.color = const Color(0xFF556B2F); // Dark olive green
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 25, paint);
    
    // Base outline
    paint.color = const Color(0xFF2F4F2F);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(Offset(centerX, centerY), 25, paint);
    
    // Defense towers (4 corners)
    paint.color = const Color(0xFF8B4513); // Saddle brown
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2 + pi / 4;
      final x = centerX + 20 * cos(angle);
      final y = centerY + 20 * sin(angle);
      canvas.drawCircle(Offset(x, y), 6, paint);
    }
    
    // Central command center
    paint.color = const Color(0xFF4682B4); // Steel blue
    canvas.drawCircle(Offset(centerX, centerY), 12, paint);
    
    // Command center details
    paint.color = const Color(0xFF191970); // Midnight blue
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(centerX, centerY), 12, paint);
  }
  
  // Draw rotating radar scanner
  void _drawRadarScanner(Canvas canvas, Paint paint) {
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotationAnimation.value * 2 * pi);
    
    // Radar sweep line
    paint.color = const Color(0xFF00FF00).withOpacity(0.7); // Bright green
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawLine(const Offset(0, 0), Offset(gameRadius * 0.8, 0), paint);
    
    // Radar antenna
    paint.color = const Color(0xFF2F4F2F);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(0, 0), 4, paint);
    
    canvas.restore();
  }
  
  // Draw soldier with military equipment
  void _drawSoldier(Canvas canvas, Paint paint, double x, double y, Enemy soldier) {
    // Soldier body (uniform color based on function type)
    paint.color = soldier.color.withOpacity(0.8);
    paint.style = PaintingStyle.fill;
    
    // Body (rectangle)
    final bodyRect = Rect.fromCenter(
      center: Offset(x, y),
      width: 12,
      height: 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(2)),
      paint,
    );
    
    // Head (circle)
    paint.color = const Color(0xFFDEB887); // Skin tone
    canvas.drawCircle(Offset(x, y - 12), 6, paint);
    
    // Helmet
    paint.color = const Color(0xFF2F4F2F); // Dark olive green
    canvas.drawCircle(Offset(x, y - 12), 7, paint);
    
    // Weapon (rifle)
    paint.color = const Color(0xFF654321); // Brown
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawLine(
      Offset(x + 8, y - 5),
      Offset(x + 15, y - 8),
      paint,
    );
    
    // Function label background
    paint.color = Colors.black.withOpacity(0.7);
    paint.style = PaintingStyle.fill;
    final labelRect = Rect.fromCenter(
      center: Offset(x, y + 15),
      width: 24,
      height: 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(6)),
      paint,
    );
    
    // Function label text
    final textPainter = TextPainter(
      text: TextSpan(
        text: soldier.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textX = x - textPainter.width / 2;
    final textY = y + 15 - textPainter.height / 2;
    textPainter.paint(canvas, Offset(textX, textY));
    
    // Soldier outline
    paint.color = const Color(0xFF2F4F2F);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(2)),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
