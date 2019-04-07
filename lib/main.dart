import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro',
      theme: ThemeData(
        primarySwatch: Colors.red,

      ),
      home: MyHomePage(title: 'Pomodoro'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int DEFAULT_TIMER = 1500;
  static const String START_STRING = "Tap to start";
  int _counter = DEFAULT_TIMER; // Start at 25 mins
  int _mins = 0;
  int _seconds = 0;
  String timeString = START_STRING;

  double percentage = 1;
  Timer timer;
  bool isTimerPaused = false;
  bool isTimerStarted = false;

  void toggleTimer() {
    if(!isTimerStarted || isTimerPaused){
      timer = Timer.periodic(Duration(seconds: 1), updateTimer);
      isTimerStarted = true;
      isTimerPaused = false;
    }
    else{
      isTimerPaused = true;
      timer.cancel();
    }
  }

  void updateTimer(Timer timer){
    setState(() {
      if(_counter > 0){
        _counter--;
        percentage = (_counter/ DEFAULT_TIMER);
        _mins = (_counter/60).floor();
        _seconds = _counter % 60;
        timeString = _mins.toString().padLeft(2, '0') + " : " + _seconds.toString().padLeft(2, '0');
      }
      else{
        SystemSound.play(SystemSoundType.click);
      }
    });
  }

  void resetTimer(){
    setState(() {
      _counter = DEFAULT_TIMER;
      isTimerStarted = isTimerPaused = false;
      timeString = START_STRING;
      timer.cancel();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          child: CustomPaint(
            foregroundPainter: TimerPainter(
                percentage: percentage,
                timeString: timeString
            ),
            child: GestureDetector(
              onTap: toggleTimer,
              onDoubleTap: resetTimer,
            ),
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter{
  TimerPainter({this.percentage, this.timeString});
  double percentage;
  String timeString;
  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = new Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    Paint progressPaint = new Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    Offset center  = new Offset(size.width/2, size.height/2);
    double radius  = min(size.width/2,size.height/2);
    double arcAngle = 2*pi* percentage;
    canvas.drawArc(
        new Rect.fromCircle(center: center,radius: radius),
        -pi/2,
        arcAngle,
        false,
        progressPaint
    );
    canvas.drawCircle(
        center,
        radius - 20,
        circlePaint
    );
    final ParagraphBuilder paragraphBuilder = ParagraphBuilder(
      ParagraphStyle(textDirection: TextDirection.ltr, fontSize: 40),
    )
      ..addText(timeString);
    final Paragraph paragraph = paragraphBuilder.build()
      ..layout(ParagraphConstraints(width: size.width));
    Offset paragraphCenter  = new Offset(
        (size.width - paragraph.maxIntrinsicWidth)/2, (size.height - paragraph.height)/2);
    canvas.drawParagraph(
        paragraph, paragraphCenter);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}