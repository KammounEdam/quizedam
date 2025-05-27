import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import '../widgets/custom_widgets.dart';
import 'quiz_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  final QuizService _quizService = QuizService();
  List<Category> _categories = [];
  Category? _selectedCategory;
  String? _selectedDifficulty;
  int _numberOfQuestions = 5;

  final List<String> _difficulties = ['easy', 'medium', 'hard'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _quizService.getCategories();
      setState(() {
        _categories =
            categories.map((category) => Category.fromJson(category)).toList();
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingCategories(e.toString()))),
        );
      }
    }
  }

  void _startQuiz() {
    final l10n = AppLocalizations.of(context)!;
    // Using unawaited Future to handle the async operation
    Future(() async {
      try {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loadingQuestions)),
        );

        final response = await _quizService.getQuestions(
          amount: _numberOfQuestions,
          categoryId: _selectedCategory?.id ?? 0,
          difficulty: _selectedDifficulty ?? 'easy',
        );

        if (!mounted) return;

        // Dismiss loading indicator
        ScaffoldMessenger.of(context).clearSnackBars();

        if (response['results'] == null) {
          throw Exception(l10n.noQuestionsFound);
        }

        final questions = (response['results'] as List)
            .map((q) => Question.fromJson(q))
            .toList();

        if (questions.isEmpty) {
          throw Exception(l10n.noQuestionsAvailable);
        }

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              questions: questions,
              category: _selectedCategory?.name ?? 'General',
              difficulty: _selectedDifficulty ?? 'easy',
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isFormValid =
        _selectedCategory != null && _selectedDifficulty != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.quizSetup,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                AnimatedCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.customizeYourQuiz,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.customizeQuizSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Form Section
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Category Selection
                        _buildSectionLabel(
                            context, l10n.category, Icons.category_outlined),
                        const SizedBox(height: 12),
                        CustomDropdown<Category>(
                          hint: l10n.selectCategory,
                          value: _selectedCategory,
                          prefixIcon: Icons.category_outlined,
                          items: _categories
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category.name),
                                  ))
                              .toList(),
                          onChanged: (Category? value) {
                            setState(() => _selectedCategory = value);
                          },
                        ),

                        const SizedBox(height: 24),

                        // Difficulty Selection
                        _buildSectionLabel(
                            context, l10n.difficulty, Icons.speed_outlined),
                        const SizedBox(height: 12),
                        CustomDropdown<String>(
                          hint: l10n.selectDifficulty,
                          value: _selectedDifficulty,
                          prefixIcon: Icons.speed_outlined,
                          items: _difficulties
                              .map((difficulty) => DropdownMenuItem(
                                    value: difficulty,
                                    child: Text(
                                        _getDifficultyDisplayName(difficulty)),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            setState(() => _selectedDifficulty = value);
                          },
                        ),

                        const SizedBox(height: 24),

                        // Number of Questions
                        _buildSectionLabel(context, l10n.numberOfQuestions,
                            Icons.format_list_numbered),
                        const SizedBox(height: 12),
                        AnimatedCard(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.format_list_numbered,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.questions,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: DropdownButton<int>(
                                  value: _numberOfQuestions,
                                  underline: const SizedBox(),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: theme.colorScheme.primary,
                                  ),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: [5, 10, 15, 20]
                                      .map((number) => DropdownMenuItem(
                                            value: number,
                                            child: Text(number.toString()),
                                          ))
                                      .toList(),
                                  onChanged: (int? value) {
                                    if (value != null) {
                                      setState(
                                          () => _numberOfQuestions = value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Quiz Summary
                        if (isFormValid) _buildQuizSummary(context),
                      ],
                    ),
                  ),
                ),

                // Start Quiz Button
                const SizedBox(height: 24),
                CustomButton(
                  text: l10n.startQuiz,
                  icon: Icons.play_arrow_rounded,
                  variant: ButtonVariant.primary,
                  height: 56,
                  onPressed: isFormValid ? _startQuiz : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizSummary(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AnimatedCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.quizSummary,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
              context, l10n.category, _selectedCategory?.name ?? ''),
          _buildSummaryRow(context, l10n.difficulty,
              _getDifficultyDisplayName(_selectedDifficulty ?? '')),
          _buildSummaryRow(
              context, l10n.questions, _numberOfQuestions.toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyDisplayName(String difficulty) {
    final l10n = AppLocalizations.of(context)!;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return l10n.easy;
      case 'medium':
        return l10n.medium;
      case 'hard':
        return l10n.hard;
      default:
        return difficulty;
    }
  }
}
