import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// One dhikr or dua: Arabic text, Amharic meaning, how many times to say it.
class Dhikr {
  const Dhikr({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.amharic,
    this.translit = '',
    required this.repeat,
    required this.source,
    this.audio = '',
  });

  final String id;
  final String category;
  final String title;
  final String arabic;
  final String amharic;

  /// Amharic letters that show how the Arabic is read aloud.
  final String translit;
  final int repeat;
  final String source;

  /// Recitation: an https link, an asset path (assets/audio/...), or empty for none.
  final String audio;

  /// Unique across the app, used for favourites and counters.
  String get key => '$category:$id';

  factory Dhikr.fromJson(Map<String, dynamic> json, {required String category}) {
    return Dhikr(
      id: json['id'] as String,
      category: category,
      title: json['title'] as String? ?? '',
      arabic: json['ar'] as String,
      amharic: json['am'] as String,
      translit: json['translit'] as String? ?? '',
      repeat: json['repeat'] as int? ?? 1,
      source: json['source'] as String? ?? '',
      audio: json['audio'] as String? ?? '',
    );
  }
}

class AzkarCategory {
  const AzkarCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.image,
    required this.items,
  });

  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String image;
  final List<Dhikr> items;
}

/// One of the 99 names of Allah.
class DivineName {
  const DivineName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });

  final int number;
  final String arabic;
  final String transliteration;
  final String meaning;

  factory DivineName.fromJson(Map<String, dynamic> json) {
    return DivineName(
      number: json['n'] as int,
      arabic: json['ar'] as String,
      transliteration: json['tr'] as String,
      meaning: json['am'] as String,
    );
  }
}

class Content {
  const Content({
    required this.categories,
    required this.names,
    required this.duas,
  });

  final List<AzkarCategory> categories;
  final List<DivineName> names;
  final List<Dhikr> duas;

  Iterable<Dhikr> get allAzkar => categories.expand((c) => c.items);

  AzkarCategory? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}

/// Makes Arabic easier to compare for search: removes vowel marks, tatweel and
/// Quranic signs, and unifies the alef, ya and ta marbuta forms. This lets a
/// search typed without vowel marks match the fully marked text.
String normalizeArabic(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    final isMark = (rune >= 0x064B && rune <= 0x065F) || // harakat, shadda, sukun
        rune == 0x0670 || // dagger alef
        (rune >= 0x06D6 && rune <= 0x06ED) || // Quranic marks
        rune == 0x0640; // tatweel
    if (isMark) continue;
    if (rune == 0x0622 || rune == 0x0623 || rune == 0x0625 || rune == 0x0671) {
      out.writeCharCode(0x0627); // all alef forms -> ا
    } else if (rune == 0x0649) {
      out.writeCharCode(0x064A); // ى -> ي
    } else if (rune == 0x0629) {
      out.writeCharCode(0x0647); // ة -> ه
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}

class ContentRepository {
  ContentRepository._();

  /// Loads the bundled JSON files from assets/data.
  static Future<Content> load() async {
    final azkar = await rootBundle.loadString('assets/data/azkar.json');
    final names = await rootBundle.loadString('assets/data/names.json');
    final duas = await rootBundle.loadString('assets/data/duas.json');
    return parse(azkarJson: azkar, namesJson: names, duasJson: duas);
  }

  /// Parses the JSON text. Kept separate from [load] so it can be tested.
  static Content parse({
    required String azkarJson,
    required String namesJson,
    required String duasJson,
  }) {
    final azkar = jsonDecode(azkarJson) as Map<String, dynamic>;
    final rawCategories = azkar['categories'] as List<dynamic>;

    final categories = rawCategories.map((raw) {
      final m = raw as Map<String, dynamic>;
      final id = m['id'] as String;
      final items = (m['items'] as List<dynamic>)
          .map((e) => Dhikr.fromJson(e as Map<String, dynamic>, category: id))
          .toList();
      return AzkarCategory(
        id: id,
        title: m['title'] as String,
        subtitle: m['subtitle'] as String,
        icon: m['icon'] as String,
        image: m['image'] as String,
        items: items,
      );
    }).toList();

    final names = (jsonDecode(namesJson) as List<dynamic>)
        .map((e) => DivineName.fromJson(e as Map<String, dynamic>))
        .toList();

    final duas = (jsonDecode(duasJson) as List<dynamic>)
        .map((e) => Dhikr.fromJson(e as Map<String, dynamic>, category: 'duas'))
        .toList();

    return Content(categories: categories, names: names, duas: duas);
  }
}
