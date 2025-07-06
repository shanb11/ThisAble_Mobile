import 'package:flutter/material.dart';
import '../../../../core/models/skill.dart';
import '../../../../core/theme/app_colors.dart';

class SelectedSkillChip extends StatefulWidget {
  final Skill skill;
  final VoidCallback onRemove;

  const SelectedSkillChip({
    super.key,
    required this.skill,
    required this.onRemove,
  });

  @override
  State<SelectedSkillChip> createState() => _SelectedSkillChipState();
}

class _SelectedSkillChipState extends State<SelectedSkillChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skill name
            Text(
              widget.skill.name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(width: 5),

            // Remove button
            GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Colors.white.withOpacity(0.4)
                      : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
