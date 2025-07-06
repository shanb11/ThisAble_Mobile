import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Loading Widget - consistent loading states across the app
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primaryOrange,
              ),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Small Loading Indicator - for buttons and small spaces
class SmallLoadingWidget extends StatelessWidget {
  final Color? color;

  const SmallLoadingWidget({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primaryOrange,
        ),
      ),
    );
  }
}

/// Error Widget - consistent error states
class ErrorWidget extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorWidget({
    super.key,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: AppTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(buttonText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty State Widget - when no data available
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.buttonText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.cardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onAction,
                child: Text(buttonText ?? 'Get Started'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Page Loading - full page loading state
class PageLoadingWidget extends StatelessWidget {
  final String? message;

  const PageLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: LoadingWidget(
        message: message ?? 'Loading...',
      ),
    );
  }
}

/// Shimmer Loading - skeleton loading for cards
class ShimmerLoadingWidget extends StatefulWidget {
  final double height;
  final double width;
  final EdgeInsetsGeometry? margin;

  const ShimmerLoadingWidget({
    super.key,
    required this.height,
    required this.width,
    this.margin,
  });

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  AppColors.borderLight,
                  Colors.white,
                  AppColors.borderLight,
                ],
                stops: [
                  _animation.value - 0.3,
                  _animation.value,
                  _animation.value + 0.3,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Job Card Shimmer - loading state for job cards
class JobCardShimmer extends StatelessWidget {
  const JobCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoadingWidget(height: 20, width: 200),
            SizedBox(height: 10),
            ShimmerLoadingWidget(height: 16, width: 150),
            SizedBox(height: 15),
            Row(
              children: [
                ShimmerLoadingWidget(height: 24, width: 80),
                SizedBox(width: 10),
                ShimmerLoadingWidget(height: 24, width: 80),
                SizedBox(width: 10),
                ShimmerLoadingWidget(height: 24, width: 80),
              ],
            ),
            SizedBox(height: 15),
            ShimmerLoadingWidget(height: 14, width: double.infinity),
            SizedBox(height: 5),
            ShimmerLoadingWidget(height: 14, width: 250),
            SizedBox(height: 20),
            ShimmerLoadingWidget(height: 32, width: 100),
          ],
        ),
      ),
    );
  }
}
