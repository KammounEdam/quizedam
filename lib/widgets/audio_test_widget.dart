import 'package:flutter/material.dart';
import '../services/audio_manager.dart';

/// Widget de test pour vérifier que les sons fonctionnent
class AudioTestWidget extends StatelessWidget {
  const AudioTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = AudioManager();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎵 Test Audio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Testez les sons de l\'application:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton son correct
                ElevatedButton.icon(
                  onPressed: () => audioManager.playCorrect(),
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  label: const Text('Correct'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green.shade700,
                  ),
                ),
                
                // Bouton son incorrect
                ElevatedButton.icon(
                  onPressed: () => audioManager.playWrong(),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Incorrect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
                
                // Bouton son clic
                ElevatedButton.icon(
                  onPressed: () => audioManager.playClick(),
                  icon: const Icon(Icons.touch_app, color: Colors.blue),
                  label: const Text('Clic'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Si aucun fichier audio n\'est trouvé,\nles sons système seront utilisés.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
