import 'package:apc_schedular/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppShimmer extends StatefulWidget {
  const AppShimmer({super.key, required this.child, this.baseColor});

  final Widget child;
  final Color? baseColor;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppColors.mutedSurface;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-1.0 - _controller.value * 2, 0),
            end: Alignment(1.0 - _controller.value * 2, 0),
            colors: [
              baseColor,
              Colors.white.withValues(alpha: 0.86),
              baseColor,
            ],
            stops: const [0.2, 0.5, 0.8],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 8,
    this.color,
  });

  final double height;
  final double? width;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? AppColors.mutedSurface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class AppPageShimmer extends StatelessWidget {
  const AppPageShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) => const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(height: 44, width: 44, borderRadius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 15, borderRadius: 5),
                  SizedBox(height: 8),
                  ShimmerBox(height: 12, width: 150, borderRadius: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
