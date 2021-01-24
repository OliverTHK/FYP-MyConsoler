import 'package:flutter/material.dart';

class MyElasticScale extends StatefulWidget {
  final Widget child;

  MyElasticScale({@required this.child});

  @override
  _MyElasticScaleState createState() => _MyElasticScaleState();
}

class _MyElasticScaleState extends State<MyElasticScale>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
