import 'package:flutter/cupertino.dart';

class JumpingDotsProgressIndicator extends StatefulWidget {
  final int numberOfDots;
  final double beginTweenValue = 0.0;
  final double endTweenValue = 8.0;

  JumpingDotsProgressIndicator({
    this.numberOfDots = 3,
  });

  _JumpingDotsProgressIndicatorState createState() =>
      _JumpingDotsProgressIndicatorState(
        numberOfDots: this.numberOfDots,
      );
}

class _JumpingDotsProgressIndicatorState
    extends State<JumpingDotsProgressIndicator> with TickerProviderStateMixin {
  int numberOfDots;
  List<AnimationController> controllers = [];
  List<Animation<double>> animations = [];
  List<Widget> _widgets = [];

  _JumpingDotsProgressIndicatorState({
    required this.numberOfDots,
  });
  Widget build(BuildContext context) {
    return Container();
  }
}