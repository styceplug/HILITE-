import 'package:flutter/material.dart';

class PulseLoader extends StatefulWidget {
  const PulseLoader({Key? key}) : super(key: key);

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(color: Colors.black),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}