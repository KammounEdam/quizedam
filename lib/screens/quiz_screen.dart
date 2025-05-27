import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../widgets/custom_widgets.dart';
import '../utils/theme.dart';
import '../services/audio_manager.dart';
import 'quiz_results_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String category;
  final String difficulty;
  final bool enableTimer;
  final bool autoAdvance;
  final int timerDuration;

  const QuizScreen({
    super.key,
    required this.questions,
    required this.category,
    required this.difficulty,
    this.enableTimer = true,
    this.autoAdvance = true,
    this.timerDuration = 15,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _hasAnswered = false;
  String? _selectedAnswer;
  late List<Question> _questions;
  late List<String> _userAnswers;
  late List<int> _questionTimes; // Time taken for each question in seconds
  late DateTime _startTime;
  late DateTime _questionStartTime;

  // Services
  final AudioManager _audioManager = AudioManager();

  // Timer properties
  late final int _timerDuration;
  late int _remainingTime;
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  bool _timerExpired = false;

  // Animation controllers
  late AnimationController _questionAnimationController;
  late AnimationController _feedbackAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _questionFadeAnimation;
  late Animation<Offset> _questionSlideAnimation;
  late Animation<double> _feedbackScaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions;
    _userAnswers = List.filled(_questions.length, '');
    _questionTimes = List.filled(_questions.length, 0);
    _startTime = DateTime.now();
    _questionStartTime = DateTime.now();
    _timerDuration = widget.timerDuration;
    _remainingTime = _timerDuration;

    // Initialize audio service
    _audioManager.initialize();

    // Initialize animation controllers
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _timerController = AnimationController(
      duration: Duration(seconds: _timerDuration),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _questionFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeOut,
    ));

    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeOut,
    ));

    _feedbackScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _feedbackAnimationController,
      curve: Curves.elasticOut,
    ));

    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // Set up timer listener
    _timerController.addListener(_onTimerTick);
    _timerController.addStatusListener(_onTimerStatusChanged);

    // Start the first question
    _questionAnimationController.forward();
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    _feedbackAnimationController.dispose();
    _timerController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _startQuestionTimer() {
    _questionStartTime = DateTime.now();
    _remainingTime = _timerDuration;
    _timerExpired = false;
    _timerController.reset();

    // Only start timer if enabled
    if (widget.enableTimer) {
      _timerController.forward();
    }
    _pulseAnimationController.stop();
  }

  void _onTimerTick() {
    if (!mounted) return;

    final elapsed = _timerController.value * _timerDuration;
    final remaining = _timerDuration - elapsed.round();

    setState(() {
      _remainingTime = remaining.clamp(0, _timerDuration);
    });

    // Start pulsing animation when under 5 seconds
    if (_remainingTime <= 5 &&
        _remainingTime > 0 &&
        !_pulseAnimationController.isAnimating) {
      _pulseAnimationController.repeat(reverse: true);
      // Play warning sound and vibration at 5 seconds
      if (_remainingTime == 5) {
        _audioManager.playClick(); // Use click sound for warning
        // Vibration is handled by SoundService
      }
    }
  }

  void _onTimerStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_hasAnswered) {
      _handleTimeExpired();
    }
  }

  void _handleTimeExpired() {
    if (_hasAnswered) return;

    setState(() {
      _timerExpired = true;
      _hasAnswered = true;
      _selectedAnswer = ''; // No answer selected
      _userAnswers[_currentQuestionIndex] = '';
      _questionTimes[_currentQuestionIndex] = _timerDuration;
    });

    _pulseAnimationController.stop();

    // Show "Time's Up!" message briefly
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Time's Up!"),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(milliseconds: 1500),
      ),
    );

    // Auto-advance if enabled, otherwise wait for user action
    if (widget.autoAdvance) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!mounted) return;

        if (_currentQuestionIndex < _questions.length - 1) {
          _nextQuestion();
        } else {
          _showResults();
        }
      });
    }
  }

  Color _getTimerColor() {
    if (_remainingTime >= 10) {
      return AppTheme.successColor;
    } else if (_remainingTime >= 5) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  void _handleAnswer(String selectedAnswer) {
    if (_hasAnswered) return;

    // Stop the timer and calculate time taken
    _timerController.stop();
    _pulseAnimationController.stop();

    final timeTaken = DateTime.now().difference(_questionStartTime).inSeconds;
    final isCorrect =
        selectedAnswer == _questions[_currentQuestionIndex].correctAnswer;

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = selectedAnswer;
      _userAnswers[_currentQuestionIndex] = selectedAnswer;
      _questionTimes[_currentQuestionIndex] = timeTaken;
      if (isCorrect) _score++;
    });

    // Play sound and vibration feedback
    if (isCorrect) {
      _audioManager.playCorrect(); // Sound + vibration handled by SoundService
    } else {
      _audioManager.playWrong(); // Sound + vibration handled by SoundService
    }

    // Trigger feedback animation
    _feedbackAnimationController.forward().then((_) {
      _feedbackAnimationController.reverse();
    });

    // Auto-advance if enabled, otherwise wait for user action
    if (widget.autoAdvance) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!mounted) return;

        if (_currentQuestionIndex < _questions.length - 1) {
          _nextQuestion();
        } else {
          _showResults();
        }
      });
    }
  }

  void _nextQuestion() {
    _questionAnimationController.reset();
    setState(() {
      _currentQuestionIndex++;
      _hasAnswered = false;
      _selectedAnswer = null;
      _timerExpired = false;
    });
    _questionAnimationController.forward();
    _startQuestionTimer();
  }

  void _showResults() {
    final timeTaken = DateTime.now().difference(_startTime);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          questions: _questions,
          userAnswers: _userAnswers,
          score: _score,
          category: widget.category,
          difficulty: widget.difficulty,
          timeTaken: timeTaken,
          questionTimes: _questionTimes,
          timerDuration: _timerDuration,
        ),
      ),
    );
  }

  Color _getAnswerColor(String answer) {
    if (!_hasAnswered) return Colors.transparent;

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrectAnswer = answer == currentQuestion.correctAnswer;
    final isSelectedAnswer = answer == _selectedAnswer;

    if (isSelectedAnswer && isCorrectAnswer) {
      return AppTheme.successColor;
    } else if (isSelectedAnswer && !isCorrectAnswer) {
      return AppTheme.errorColor;
    } else if (!isSelectedAnswer && isCorrectAnswer) {
      return AppTheme.successColor;
    }

    return Colors.grey.shade300;
  }

  IconData? _getAnswerIcon(String answer) {
    if (!_hasAnswered) return null;

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrectAnswer = answer == currentQuestion.correctAnswer;
    final isSelectedAnswer = answer == _selectedAnswer;

    if (isSelectedAnswer && isCorrectAnswer) {
      return Icons.check_circle;
    } else if (isSelectedAnswer && !isCorrectAnswer) {
      return Icons.cancel;
    } else if (!isSelectedAnswer && isCorrectAnswer) {
      return Icons.check_circle;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final theme = Theme.of(context);
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Circular Timer Widget (only show when timer is enabled)
          if (widget.enableTimer)
            Container(
              margin: const EdgeInsets.only(right: AppTheme.spacingM),
              child: _buildCircularTimer(),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
          ),
        ),
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
          child: FadeTransition(
            opacity: _questionFadeAnimation,
            child: SlideTransition(
              position: _questionSlideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppTheme.spacingL),

                    // Question Card
                    AnimatedCard(
                      padding: const EdgeInsets.all(AppTheme.spacingXL),
                      child: Column(
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                          Text(
                            currentQuestion.question,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXL),

                    // Answer Options
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentQuestion.allAnswers.length,
                        itemBuilder: (context, index) {
                          final answer = currentQuestion.allAnswers[index];
                          return _buildAnswerOption(context, answer, index);
                        },
                      ),
                    ),

                    // Next Button (only show when autoAdvance is disabled and question is answered)
                    if (!widget.autoAdvance && _hasAnswered) ...[
                      const SizedBox(height: AppTheme.spacingL),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _audioManager.playClick(); // Play click sound
                            if (_currentQuestionIndex < _questions.length - 1) {
                              _nextQuestion();
                            } else {
                              _showResults();
                            }
                          },
                          icon: Icon(
                              _currentQuestionIndex < _questions.length - 1
                                  ? Icons.arrow_forward
                                  : Icons.flag),
                          label: Text(
                              _currentQuestionIndex < _questions.length - 1
                                  ? 'Next Question'
                                  : 'Show Results'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.spacingM),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusM),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(BuildContext context, String answer, int index) {
    final theme = Theme.of(context);
    final answerColor = _getAnswerColor(answer);
    final answerIcon = _getAnswerIcon(answer);
    final isSelected = answer == _selectedAnswer;

    return AnimatedBuilder(
      animation: _feedbackScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale:
              isSelected && _hasAnswered ? _feedbackScaleAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: _hasAnswered
                    ? answerColor.withOpacity(0.1)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: _hasAnswered
                      ? answerColor
                      : theme.colorScheme.outline.withOpacity(0.3),
                  width: _hasAnswered ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _hasAnswered
                        ? answerColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: _hasAnswered ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _hasAnswered ? null : () => _handleAnswer(answer),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Row(
                      children: [
                        // Option Letter
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _hasAnswered
                                ? answerColor
                                : theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusS),
                          ),
                          child: Center(
                            child: answerIcon != null
                                ? Icon(
                                    answerIcon,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    String.fromCharCode(
                                        65 + index), // A, B, C, D
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _hasAnswered
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: AppTheme.spacingM),

                        // Answer Text
                        Expanded(
                          child: Text(
                            answer,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600, // Plus gras
                              fontSize: 16, // Taille augmentée
                              color: _hasAnswered
                                  ? (_getAnswerColor(answer) ==
                                          AppTheme.successColor
                                      ? Colors.green
                                          .shade800 // Vert plus foncé pour correct
                                      : Colors.red
                                          .shade800) // Rouge plus foncé pour incorrect
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.9), // Plus contrasté
                            ),
                          ),
                        ),

                        // Feedback Icon
                        if (_hasAnswered && answerIcon != null) ...[
                          const SizedBox(width: AppTheme.spacingS),
                          Icon(
                            answerIcon,
                            color: answerColor,
                            size: 24,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircularTimer() {
    final timerColor = _getTimerColor();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _remainingTime <= 10 ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: timerColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // Circular progress indicator
                AnimatedBuilder(
                  animation: _timerAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: _timerAnimation.value,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                      ),
                    );
                  },
                ),

                // Timer text
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: _remainingTime <= 10 ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                  ),
                  child: Text(
                    '${_remainingTime}s',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
