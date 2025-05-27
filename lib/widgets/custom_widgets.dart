import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/audio_service.dart';

enum ButtonVariant { primary, secondary, outline, text }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
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

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
    _audioService.playButtonSound();
    _audioService.vibrateButton();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  Color _getTextColor(BuildContext context, bool isEnabled) {
    final theme = Theme.of(context);

    if (!isEnabled) {
      return Colors.grey.shade600;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        return Colors.white; // Blanc sur fond coloré
      case ButtonVariant.secondary:
        return Colors.white; // Blanc sur fond secondaire
      case ButtonVariant.outline:
        return theme.primaryColor; // Couleur primaire sur fond transparent
      case ButtonVariant.text:
        return theme.primaryColor; // Couleur primaire sur fond transparent
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Widget buttonChild = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.variant == ButtonVariant.primary
                    ? Colors.white
                    : theme.primaryColor,
              ),
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 16, // Augmenté de 14 à 16
                fontWeight: FontWeight.w700, // Plus gras
                letterSpacing: 0.5, // Plus d'espacement
                color: _getTextColor(context, isEnabled), // Couleur explicite
                shadows: widget.variant == ButtonVariant.primary
                    ? [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ]
                    : null, // Ombre pour les boutons primaires
              ),
              textAlign: TextAlign.center,
            ),
          );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.width,
            height: widget.height ?? 56,
            child: _buildButton(context, buttonChild, isEnabled),
          ),
        );
      },
    );
  }

  Widget _buildButton(BuildContext context, Widget child, bool isEnabled) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return Container(
          decoration: BoxDecoration(
            gradient: isEnabled ? AppTheme.primaryGradient : null,
            color: isEnabled ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              onTapDown: isEnabled ? _onTapDown : null,
              onTapUp: isEnabled ? _onTapUp : null,
              onTapCancel: isEnabled ? _onTapCancel : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL,
                  vertical: AppTheme.spacingM,
                ),
                child: Center(child: child),
              ),
            ),
          ),
        );

      case ButtonVariant.secondary:
        return GestureDetector(
          onTapDown: isEnabled ? _onTapDown : null,
          onTapUp: isEnabled ? _onTapUp : null,
          onTapCancel: isEnabled ? _onTapCancel : null,
          child: ElevatedButton(
            onPressed: isEnabled ? widget.onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXL,
                vertical: AppTheme.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              elevation: 2,
            ),
            child: child,
          ),
        );

      case ButtonVariant.outline:
        return GestureDetector(
          onTapDown: isEnabled ? _onTapDown : null,
          onTapUp: isEnabled ? _onTapUp : null,
          onTapCancel: isEnabled ? _onTapCancel : null,
          child: OutlinedButton(
            onPressed: isEnabled ? widget.onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(
                color: isEnabled
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXL,
                vertical: AppTheme.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: child,
          ),
        );

      case ButtonVariant.text:
        return GestureDetector(
          onTapDown: isEnabled ? _onTapDown : null,
          onTapUp: isEnabled ? _onTapUp : null,
          onTapCancel: isEnabled ? _onTapCancel : null,
          child: TextButton(
            onPressed: isEnabled ? widget.onPressed : null,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXL,
                vertical: AppTheme.spacingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: child,
          ),
        );
    }
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final IconData? prefixIcon;
  final bool isEnabled;

  const CustomDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: isEnabled
              ? theme.primaryColor.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingXS,
        ),
        child: Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(
                prefixIcon,
                color: isEnabled ? theme.primaryColor : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacingS),
            ],
            Expanded(
              child: DropdownButton<T>(
                value: value,
                hint: Text(
                  hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isEnabled ? theme.primaryColor : Colors.grey.shade400,
                ),
                style: theme.textTheme.bodyLarge,
                items: items,
                onChanged: isEnabled ? onChanged : null,
                dropdownColor: theme.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.elevation,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 4.0,
      end: (widget.elevation ?? 4.0) + 4.0,
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: widget.margin ?? const EdgeInsets.all(AppTheme.spacingS),
            elevation: _elevationAnimation.value,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: widget.onTap != null
                  ? (_) => _animationController.forward()
                  : null,
              onTapUp: widget.onTap != null
                  ? (_) => _animationController.reverse()
                  : null,
              onTapCancel: widget.onTap != null
                  ? () => _animationController.reverse()
                  : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
              child: Container(
                padding:
                    widget.padding ?? const EdgeInsets.all(AppTheme.spacingM),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class GradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;

  const GradientContainer({
    super.key,
    required this.child,
    this.gradient,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusM,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
        child: child,
      ),
    );
  }
}
