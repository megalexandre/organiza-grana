import 'dart:math' as math;

import 'package:flutter/material.dart';

class PiggyCoinAnimation extends StatefulWidget {
  const PiggyCoinAnimation({super.key, required this.color, this.size = 56});

  final Color color;
  final double size;

  @override
  State<PiggyCoinAnimation> createState() => _PiggyCoinAnimationState();
}

class _PiggyCoinAnimationState extends State<PiggyCoinAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Coin fall: normalized top position goes from 0 to 0.65 of total height
  late final Animation<double> _coinFall;
  // Coin spin: Y-axis rotation (1.5 full turns)
  late final Animation<double> _coinSpin;
  // Coin opacity: stays 1, fades in final stretch before entering slot
  late final Animation<double> _coinOpacity;
  // Piggy jiggle: slight rotation after coin enters
  late final Animation<double> _piggyJiggle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    const coinInterval = Interval(0.08, 0.65, curve: Curves.easeIn);

    _coinFall = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: coinInterval),
    );

    _coinSpin = Tween<double>(begin: 0.0, end: 3 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: coinInterval),
    );

    _coinOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 75),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.72),
      ),
    );

    _piggyJiggle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: -0.6), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -0.6, end: 0.3), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.0), weight: 20),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 0.88, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final coinSize = size * 0.28;
    // Total stack height: piggy + room above for coin
    final totalHeight = size * 1.55;
    // How far the coin travels (from top=0 to slot position)
    final coinTravelRange = totalHeight - size * 0.35 - coinSize;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final showCoin = t >= 0.08 && t <= 0.72;

        return SizedBox(
          width: size,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Transform.rotate(
                  angle: _piggyJiggle.value * 0.12,
                  child: Icon(
                    Icons.savings_outlined,
                    size: size,
                    color: widget.color,
                  ),
                ),
              ),
              if (showCoin)
                Positioned(
                  top: _coinFall.value * coinTravelRange,
                  left: (size - coinSize) / 2,
                  child: Opacity(
                    opacity: _coinOpacity.value.clamp(0.0, 1.0),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY(_coinSpin.value),
                      child: _Coin(size: coinSize),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber.shade400,
        border: Border.all(color: Colors.amber.shade700, width: size * 0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.6),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'R\$',
          style: TextStyle(
            fontSize: size * 0.32,
            fontWeight: FontWeight.w900,
            color: Colors.amber.shade900,
            height: 1,
          ),
        ),
      ),
    );
  }
}
