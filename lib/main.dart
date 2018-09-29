import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Progress indicators'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Cellular bar progress indicator',
              style: Theme.of(context).textTheme.title,
            ),
            ProgressIndicators(
              numberOfBars: 4,
              color: Colors.grey,
              fontSize: 10.0,
              barSpacing: 2.0,
              beginTweenValue: 5.0,
              endTweenValue: 10.0,
              milliseconds: 200,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ProgressIndicators extends StatefulWidget {
  final int numberOfBars;
  final double fontSize;
  final double barSpacing;
  final Color color;
  final int milliseconds;
  final double beginTweenValue;
  final double endTweenValue;

  ProgressIndicators({
    this.numberOfBars = 3,
    this.fontSize = 10.0,
    this.color = Colors.black,
    this.barSpacing = 0.0,
    this.milliseconds = 250,
    this.beginTweenValue = 5.0,
    this.endTweenValue = 10.0,
  });

  _ProgressIndicatorsState createState() => _ProgressIndicatorsState(
        numberOfBars: this.numberOfBars,
        fontSize: this.fontSize,
        color: this.color,
        barSpacing: this.barSpacing,
        milliseconds: this.milliseconds,
        beginTweenValue: this.beginTweenValue,
        endTweenValue: this.endTweenValue,
      );
}

class _ProgressIndicatorsState extends State<ProgressIndicators>
    with TickerProviderStateMixin {
  int numberOfBars;
  int milliseconds;
  double fontSize;
  double barSpacing;
  Color color;
  double beginTweenValue;
  double endTweenValue;
  List<AnimationController> controllers = new List<AnimationController>();
  List<Animation<double>> animations = new List<Animation<double>>();
  List<Widget> _widgets = new List<Widget>();

  _ProgressIndicatorsState({
    this.numberOfBars,
    this.fontSize,
    this.color,
    this.barSpacing,
    this.milliseconds,
    this.beginTweenValue,
    this.endTweenValue,
  });

  initState() {
    super.initState();
    for (int i = 0; i < numberOfBars; i++) {
      _addAnimationControllers();
      _buildAnimations(i);
      _addListOfDots(i);
    }

    controllers[0].forward();
  }

  void _addAnimationControllers() {
    controllers.add(AnimationController(
        duration: Duration(milliseconds: milliseconds), vsync: this));
  }

  void _addListOfDots(int index) {
    _widgets.add(Padding(
      padding: EdgeInsets.only(right: barSpacing),
      child: _AnimatingBar(
        animation: animations[index],
        fontSize: fontSize,
        color: color,
      ),
    ));
  }

  void _buildAnimations(int index) {
    animations.add(
        Tween(begin: widget.beginTweenValue, end: widget.endTweenValue)
            .animate(controllers[index])
              ..addStatusListener((AnimationStatus status) {
                if (status == AnimationStatus.completed)
                  controllers[index].reverse();
                if (index == numberOfBars - 1 &&
                    status == AnimationStatus.dismissed) {
                  controllers[0].forward();
                }
                if (animations[index].value > widget.endTweenValue / 2 &&
                    index < numberOfBars - 1) {
                  controllers[index + 1].forward();
                }
              }));
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _widgets,
      ),
    );
  }

  dispose() {
    for (int i = 0; i < numberOfBars; i++) controllers[i].dispose();
    super.dispose();
  }
}

class _AnimatingBar extends AnimatedWidget {
  final Color color;
  final double fontSize;
  _AnimatingBar(
      {Key key, Animation<double> animation, this.color, this.fontSize})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Container(
      height: animation.value,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(2.0),
        color: color,
      ),
      width: 5.0,
    );
  }
}
