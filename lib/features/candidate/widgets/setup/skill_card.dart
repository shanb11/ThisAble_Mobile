import 'package:flutter/material.dart';
import '../../../../core/models/skill.dart';
import '../../../../core/theme/app_colors.dart';

class SkillCard extends StatefulWidget {
  final Skill skill;
  final bool isSelected;
  final VoidCallback onTap;

  const SkillCard({
    super.key,
    required this.skill,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 160,
                height: 110,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? const Color(0xFFFFF9F2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.accent
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
                      blurRadius: _isHovered ? 16 : 8,
                      offset:
                          _isHovered ? const Offset(0, 8) : const Offset(0, 4),
                    ),
                  ],
                ),
                transform: _isHovered
                    ? Matrix4.translationValues(0, -5, 0)
                    : Matrix4.identity(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Skill icon
                    Text(
                      widget.skill.icon,
                      style: TextStyle(
                        fontSize: 24,
                        color: widget.isSelected
                            ? AppColors.accent
                            : AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Skill name
                    Text(
                      widget.skill.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
