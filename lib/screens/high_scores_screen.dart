import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HighScoresScreen extends StatelessWidget {
  const HighScoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('High Scores'),
      ),
      body: Consumer<PreferencesService>(
        builder: (context, preferences, _) {
          final scores = preferences.getHighScores();

          if (scores.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No scores yet!\nPlay a quiz to see your scores here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final score = scores[index];
              final scoreRatio = '${score['score']}/${score['total']}';
              final date = DateTime.parse(score['date'] as String);
              final formattedDate = '${date.day}/${date.month}/${date.year}';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  title: Text(score['category'] as String),
                  subtitle: Text(
                    '${score['difficulty']} • $formattedDate',
                  ),
                  trailing: Text(
                    scoreRatio,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
