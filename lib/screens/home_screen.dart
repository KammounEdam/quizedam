import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import '../utils/theme.dart';
import '../services/audio_manager.dart';
import 'quiz_setup_screen.dart';
import 'settings_screen.dart';
import 'high_scores_screen.dart';
import 'about_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final AudioManager _audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Quiz Master',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppTheme.spacingM),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                _audioManager.playClick(); // Play click sound
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),

                // Hero Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeroSection(context),
                  ),
                ),

                SizedBox(height: size.height * 0.08),

                // Action Buttons
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildActionButtons(context),
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // Features Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildFeaturesSection(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // App Logo/Icon with gradient background
        GradientContainer(
          gradient: AppTheme.primaryGradient,
          borderRadius: AppTheme.radiusXL,
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Icon(
            Icons.quiz_outlined,
            size: 80,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: AppTheme.spacingXL),

        // Welcome Text
        Text(
          l10n.welcomeTitle,
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppTheme.spacingM),

        Text(
          l10n.welcomeSubtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Primary Action - Start Quiz
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: l10n.startQuiz,
            icon: Icons.play_arrow_rounded,
            variant: ButtonVariant.primary,
            height: 60,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizSetupScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        // Secondary Actions
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: l10n.highScores,
                icon: Icons.leaderboard_outlined,
                variant: ButtonVariant.outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HighScoresScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: CustomButton(
                text: l10n.about,
                icon: Icons.info_outline,
                variant: ButtonVariant.outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.features,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.category_outlined,
                title: l10n.multipleCategories,
                description: l10n.multipleCategoriesDesc,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.speed_outlined,
                title: l10n.difficultyLevels,
                description: l10n.difficultyLevelsDesc,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.timer_outlined,
                title: l10n.timedChallenges,
                description: l10n.timedChallengesDesc,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildFeatureCard(
                context,
                icon: Icons.emoji_events_outlined,
                title: l10n.scoreTracking,
                description: l10n.scoreTrackingDesc,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return AnimatedCard(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            description,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
