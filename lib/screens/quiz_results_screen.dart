import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../widgets/custom_widgets.dart';
import '../utils/theme.dart';
import 'quiz_setup_screen.dart';
import 'high_scores_screen.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuizResultsScreen extends StatefulWidget {
  final List<Question> questions;
  final List<String> userAnswers;
  final int score;
  final String category;
  final String difficulty;
  final Duration timeTaken;
  final List<int> questionTimes;
  final int timerDuration;

  const QuizResultsScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.score,
    required this.category,
    required this.difficulty,
    required this.timeTaken,
    required this.questionTimes,
    required this.timerDuration,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score / widget.questions.length,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  String _getPerformanceRating(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (widget.score / widget.questions.length) * 100;
    if (percentage >= 90) return l10n.excellent;
    if (percentage >= 80) return l10n.greatJob;
    if (percentage >= 70) return l10n.goodWork;
    if (percentage >= 60) return l10n.notBad;
    return l10n.keepPracticing;
  }

  Color get _performanceColor {
    final percentage = (widget.score / widget.questions.length) * 100;
    if (percentage >= 80) return AppTheme.successColor;
    if (percentage >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.quizResults,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _performanceColor.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Column(
                      children: [
                        _buildScoreHeader(context),
                        const SizedBox(height: AppTheme.spacingXL),
                        _buildStatsSection(context),
                        const SizedBox(height: AppTheme.spacingXL),
                        _buildQuestionBreakdown(context),
                        const SizedBox(height: AppTheme.spacingXL),
                        _buildActionButtons(context),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreHeader(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (widget.score / widget.questions.length) * 100;

    return AnimatedCard(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(
        children: [
          Icon(
            percentage >= 80
                ? Icons.emoji_events
                : percentage >= 60
                    ? Icons.thumb_up
                    : Icons.school,
            size: 64,
            color: _performanceColor,
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            _getPerformanceRating(context),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _performanceColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            AppLocalizations.of(context)!
                .outOfCorrect(widget.score, widget.questions.length),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Animated Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Text(
                    '${(_progressAnimation.value * 100).round()}%',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _performanceColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      color: Colors.grey.shade300,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          gradient: LinearGradient(
                            colors: [
                              _performanceColor,
                              _performanceColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final averageTime = _getAverageQuestionTime();
    final fastestTime = _getFastestQuestionTime();
    final totalAllocatedTime = widget.questions.length * widget.timerDuration;
    final timeSaved = totalAllocatedTime - widget.timeTaken.inSeconds;

    return Column(
      children: [
        // First row of stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.timer_outlined,
                title: l10n.totalTime,
                value: _formatDuration(widget.timeTaken),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.speed_outlined,
                title: l10n.avgTime,
                value: '${averageTime}s',
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.flash_on_outlined,
                title: l10n.fastest,
                value: '${fastestTime}s',
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingM),

        // Second row of stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.category_outlined,
                title: l10n.category,
                value: widget.category,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.trending_up_outlined,
                title: l10n.difficulty,
                value: widget.difficulty.toUpperCase(),
                color: AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.savings_outlined,
                title: l10n.timeSaved,
                value: timeSaved > 0 ? '${timeSaved}s' : '0s',
                color: timeSaved > 0 ? AppTheme.successColor : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _getAverageQuestionTime() {
    if (widget.questionTimes.isEmpty) return 0;
    final total = widget.questionTimes.reduce((a, b) => a + b);
    return (total / widget.questionTimes.length).round();
  }

  int _getFastestQuestionTime() {
    if (widget.questionTimes.isEmpty) return 0;
    return widget.questionTimes.where((time) => time > 0).isEmpty
        ? 0
        : widget.questionTimes
            .where((time) => time > 0)
            .reduce((a, b) => a < b ? a : b);
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return AnimatedCard(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.quiz_outlined,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingS),
            Text(
              l10n.questionBreakdown,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        ...List.generate(widget.questions.length, (index) {
          final question = widget.questions[index];
          final userAnswer = widget.userAnswers[index];
          final isCorrect = userAnswer == question.correctAnswer;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: AnimatedCard(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Header
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Icon(
                          isCorrect ? Icons.check : Icons.close,
                          color: isCorrect
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Text(
                          '${l10n.question} ${index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isCorrect
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ),
                      // Timer info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                          vertical: AppTheme.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppTheme.spacingXS),
                            Text(
                              widget.questionTimes[index] > 0
                                  ? '${widget.questionTimes[index]}s'
                                  : 'Time up',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Question Text
                  Text(
                    question.question,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // User Answer
                  _buildAnswerRow(
                    context,
                    label: l10n.yourAnswer,
                    answer: userAnswer,
                    isCorrect: isCorrect,
                    isUserAnswer: true,
                  ),

                  // Correct Answer (if user was wrong)
                  if (!isCorrect) ...[
                    const SizedBox(height: AppTheme.spacingS),
                    _buildAnswerRow(
                      context,
                      label: l10n.correctAnswer,
                      answer: question.correctAnswer,
                      isCorrect: true,
                      isUserAnswer: false,
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnswerRow(
    BuildContext context, {
    required String label,
    required String answer,
    required bool isCorrect,
    required bool isUserAnswer,
  }) {
    final theme = Theme.of(context);
    final color = isCorrect ? AppTheme.successColor : AppTheme.errorColor;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final preferencesService =
        Provider.of<PreferencesService>(context, listen: false);

    return Column(
      children: [
        // Primary Action - Play Again
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: l10n.playAgain,
            icon: Icons.refresh,
            variant: ButtonVariant.primary,
            height: 56,
            onPressed: () {
              Navigator.pushReplacement(
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
                text: l10n.saveScore,
                icon: Icons.save_outlined,
                variant: ButtonVariant.outline,
                onPressed: () async {
                  await preferencesService.saveHighScore({
                    'category': widget.category,
                    'difficulty': widget.difficulty,
                    'score': widget.score,
                    'total': widget.questions.length,
                    'date': DateTime.now().toIso8601String(),
                  });

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.scoreSaved),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: CustomButton(
                text: l10n.viewHighScores,
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
          ],
        ),

        const SizedBox(height: AppTheme.spacingM),

        // Back to Home
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: l10n.backToHome,
            icon: Icons.home_outlined,
            variant: ButtonVariant.text,
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      ],
    );
  }
}
