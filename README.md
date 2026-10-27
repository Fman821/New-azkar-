# Daily Azkar (እስላማዊ አዝካር) — V2

A Flutter app for morning, evening and daily adhkar, the 99 names of Allah, and duas.
Arabic text with Amharic meanings, in the dark green and gold style of the original mockup.

## What's in V2

- **Audio**: a ▶ button on items that have a recording. Quran items stream from the internet. Other items use files you add to `assets/audio/` (see that folder's README.txt).
- **Mockup match**: gold diamond badges on tiles, count pills, gold arrow buttons, a gold-ringed tasbih counter, and a diamond emblem on the home screen.
- **Content**: all six azkar sections, the 99 names, and nine duas. Each item has a counter that counts up to its repeat count, and favourites and search work across sections.
- **Fixes**: the app name shows in Amharic, and release builds have the internet permission they need for audio.

## Tabs

| Tab | Contents |
|---|---|
| መነሻ (Home) | Verse of the day, morning and evening shortcuts, 99 names, duas, tasbih counter |
| አዝካር | Six categories: morning, after prayer (noon), evening, home, travel, other |
| ጸሎት | 99 names entry point and the duas |
| ተወዳጅ | Favourites from any section |
| ቅንብር | Name for the greeting, text size, reset counters, app info |

## Build

On a PC (see the chat instructions) or with the GitHub Actions workflow in `.github/workflows/build-apk.yml`, which builds the APK on every push and uploads it as the `daily-azkar-apk` artifact.

```bash
flutter create --project-name daily_azkar --platforms=android,ios .   # only if android/ is missing
flutter pub get
flutter analyze    # lists problems; warnings are not fatal
flutter test
flutter build apk --release
```

`flutter create .` leaves existing files such as `lib/` and `pubspec.yaml` alone.

## Content files

All text is in `assets/data/`:

- `azkar.json`: categories, with each item's `id`, `title`, `ar` (Arabic), `am` (Amharic), `repeat`, `source` and `audio`.
- `names.json`: the 99 names, with `n`, `ar`, `tr` (transliteration) and `am` (Amharic meaning).
- `duas.json`: duas in the same format as `azkar.json` items.

To add or change text, edit these files. No code changes are needed.

## Before publishing: please review

- **Arabic text**: the morning and evening texts come from the original HTML file. The other sections were written from standard collections. Check every Arabic text against a trusted printed source before release.
- **Amharic meanings**: the translations for new sections, the 99 names and the duas were written for this version. Have an Amharic-speaking scholar or native reader check them.
- **Recitation links**: the Quran audio links point to everyayah.com and mp3quran.net. Open each one once to confirm it plays. Check the link terms before publishing.
- **Sources**: the `source` field is a reference only. Confirm each one.
- **Font**: `assets/fonts/Quran.ttf` came from the original HTML file. Check its licence.

## የጠዋትና የማታ ማስታወሻ (Notifications)

- Settings ውስጥ “የጠዋትና የማታ ማስታወሻ” ክፍልን ይክፈቱ።
- መደበኛ ሰዓቶች ጠዋት 06:00 እና ማታ 18:00 ናቸው፤ ከፈለጉ ይቀይሯቸው።
- “ማስታወሻዎችን አብራ” ከመረጡ በኋላ “ማስታወሻውን አስቀምጥ” ይጫኑ።
- የማስታወቂያ ፈቃድ ይፍቀዱ። Android 13+ ላይ POST_NOTIFICATIONS ፈቃድ ያስፈልጋል።
- ይህ የምንጭ ፕሮጀክት የandroid/ እና ios/ platform folders አልያዘም፤ እነዚህን በFlutter ፕሮጀክት ሲገነቡ ማመንጨት እና በተገቢው የAndroid ስሪት ላይ ሙከራ ማድረግ ያስፈልጋል።

## የአዝካር ድምፅ ምንጮች

- Morning/evening adhkar audio: https://makkahlive.net/en/audio/morning-evening-adhkar
- Hisnul Muslim audio examples/data: https://github.com/Seen-Arabic/Morning-And-Evening-Adhkar-DB
- ድምፆችን በassets/audio/ ውስጥ ካስቀመጡ በኋላ በJSON audio መስክ የአካባቢ ፋይል መንገድ ያስገቡ። በመተግበሪያው ውስጥ ከኢንተርኔት ውጭ ለማጫወት የMP3 ፋይሎቹ በassets ውስጥ መካተት አለባቸው። ማንኛውንም ቀረጻ እንደገና ከማሰራጨት በፊት የፈቃድ ሁኔታውን ያረጋግጡ።

## Offline morning/evening recitations
The supplied MakkahLive audio archive contains two complete recordings: morning adhkar (`assets/audio/morning_adhkar.mp3`) and evening adhkar (`assets/audio/evening_adhkar.mp3`). They are bundled as app assets and are playable offline from the top of the corresponding category screen. The recordings are full recitations, not individually timestamped clips for each text item; do not assign arbitrary slices to individual adhkar without verifying the recitation boundaries. Confirm the source's reuse terms before distributing a public release.


## Updated project notes (v1.2.2+5)

- Refined the Sacred Light and Dark Emerald palette values to match the design brief more closely.
- Added bounds checking for saved theme choices, text-size settings, tasbih targets, and persisted counter values.
- Added content tests for Arabic search normalization and bundled morning/evening audio assets.
- Validated the bundled JSON content: six azkar categories, 99 names, 92 dhikr/dua entries, and unique content keys.

### Build and verify

Run these commands from the project root on a machine with the Flutter SDK installed:

```sh
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build apk --release
```

The repository includes a GitHub Actions workflow that builds and uploads the release APK as the `daily-azkar-apk` artifact. The source archive was statically inspected in this update, but the Flutter analyzer, tests, and APK build must still be run in an environment with Flutter installed.
