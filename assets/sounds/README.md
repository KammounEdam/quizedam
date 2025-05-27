# 🎵 Audio Files for Quiz App

## Required Audio Files

Place audio files in this directory with these names (any supported format):

### 1. correct.[format]
- **Purpose**: Sound played when user answers correctly
- **Recommended**: Success sound, ding, chime, positive beep
- **Duration**: 0.5-2 seconds
- **Volume**: Medium

### 2. wrong.[format]
- **Purpose**: Sound played when user answers incorrectly
- **Recommended**: Error sound, buzz, negative beep
- **Duration**: 0.5-2 seconds
- **Volume**: Medium

### 3. click.[format]
- **Purpose**: Sound played when user taps buttons
- **Recommended**: Click, tap, pop sound
- **Duration**: 0.1-0.5 seconds
- **Volume**: Low-Medium

## 🎵 Supported Audio Formats

The app automatically detects and plays the first available format:

### ✅ **Supported Formats** (in order of preference):
1. **OGG** - Best compression, open source, small file size
2. **MP3** - Universal compatibility, good compression
3. **WAV** - Highest quality, larger file size
4. **AAC** - Good quality, optimized for mobile

### 📱 **Platform Compatibility**:
- **Android**: OGG, MP3, WAV, AAC, FLAC
- **iOS**: MP3, WAV, AAC, AIFF
- **Web**: OGG, MP3, WAV
- **Desktop**: OGG, MP3, WAV, FLAC

## 📥 Where to Download Free Sounds

### Recommended Sites:
1. **Freesound.org** - Free sounds with Creative Commons license
2. **Pixabay.com/music** - Royalty-free sounds
3. **Zapsplat.com** - Professional sound library (free account)
4. **OpenGameArt.org** - Game audio resources

### Search Terms:
- **For correct.mp3**: "success", "ding", "chime", "positive", "correct"
- **For wrong.mp3**: "error", "buzz", "wrong", "negative", "fail"
- **For click.mp3**: "click", "tap", "button", "pop", "ui"

## 🔧 Audio Specifications

### **Any of these formats**:
- **OGG**: Recommended for best compression
- **MP3**: Universal compatibility
- **WAV**: Best quality (larger files)
- **AAC**: Mobile optimized

### **Technical specs**:
- **Sample Rate**: 44.1 kHz or 48 kHz
- **Bit Rate**: 128 kbps or higher (for compressed formats)
- **Channels**: Mono or Stereo
- **Max File Size**: 100 KB per file (recommended)

## 📱 Fallback Behavior

If audio files are not found, the app will use system sounds:
- **correct.mp3** → System alert sound
- **wrong.mp3** → System click sound
- **click.mp3** → System click sound

## 🎯 Quick Setup

1. Download 3 audio files from the recommended sites (any supported format)
2. Rename them to: `correct.[format]`, `wrong.[format]`, `click.[format]`
   - Examples: `correct.ogg`, `wrong.wav`, `click.mp3`
3. Place them in this `assets/sounds/` directory
4. Run `flutter clean` and rebuild the app
5. Test sounds in the app settings

### 💡 **Pro Tips**:
- **Use OGG** for best file size and quality balance
- **Use WAV** for maximum quality (games, professional apps)
- **Use MP3** for maximum compatibility
- **Mix formats** - the app will find and use any available format!
