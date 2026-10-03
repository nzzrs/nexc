/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

class AIReceiptItem {
  final String name;
  final double quantity;
  final String unit; // 'g', 'kg', 'ml', 'l', 'units'

  AIReceiptItem({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory AIReceiptItem.fromJson(Map<String, dynamic> json) {
    String rawUnit = (json['unit'] as String? ?? 'g').toLowerCase().trim();
    String unit = 'g';
    if (rawUnit == 'unit' || rawUnit == 'units' || rawUnit == 'u' || rawUnit == 'pcs' || rawUnit == 'pc' || rawUnit == 'units') {
      unit = 'units';
    } else if (rawUnit == 'ml' || rawUnit == 'l' || rawUnit == 'milliliter' || rawUnit == 'liter') {
      // Keep ml or l
      unit = rawUnit == 'liter' || rawUnit == 'l' ? 'l' : 'ml';
    } else if (rawUnit == 'kg' || rawUnit == 'kilogram') {
      unit = 'kg';
    } else {
      unit = 'g';
    }
    return AIReceiptItem(
      name: json['name'] as String? ?? 'Unknown',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: unit,
    );
  }
}

class AIProductDetails {
  final String name;
  final double kcal;
  final double proteins;
  final double carbsAvailable;
  final double carbsByDifference;
  final double dietaryFiber;
  final double fats;
  final String defaultUnits;
  final int? unitWeight;
  final int? mlToGFactor;
  final bool isSupplement;
  final bool isPortable;
  final double? edibleQtyPerUnit;
  final bool isStockRaw;

  AIProductDetails({
    required this.name,
    required this.kcal,
    required this.proteins,
    required this.carbsAvailable,
    required this.carbsByDifference,
    required this.dietaryFiber,
    required this.fats,
    required this.defaultUnits,
    this.unitWeight,
    this.mlToGFactor,
    required this.isSupplement,
    required this.isPortable,
    this.edibleQtyPerUnit,
    required this.isStockRaw,
  });

  factory AIProductDetails.fromJson(Map<String, dynamic> json) {
    return AIProductDetails(
      name: json['name'] as String? ?? '',
      kcal: (json['kcal'] as num?)?.toDouble() ?? 0.0,
      proteins: (json['proteins'] as num?)?.toDouble() ?? 0.0,
      carbsAvailable: (json['carbsAvailable'] as num?)?.toDouble() ?? (json['carbs'] as num?)?.toDouble() ?? 0.0,
      carbsByDifference: (json['carbsByDifference'] as num?)?.toDouble() ?? (json['carbs'] as num?)?.toDouble() ?? 0.0,
      dietaryFiber: (json['dietaryFiber'] as num?)?.toDouble() ?? 0.0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0.0,
      defaultUnits: json['defaultUnits'] as String? ?? 'g',
      unitWeight: json['unitWeight'] as int?,
      mlToGFactor: json['mlToGFactor'] as int?,
      isSupplement: json['isSupplement'] as bool? ?? false,
      isPortable: json['isPortable'] as bool? ?? true,
      edibleQtyPerUnit: (json['edibleQtyPerUnit'] as num?)?.toDouble(),
      isStockRaw: json['isStockRaw'] as bool? ?? false,
    );
  }
}

class AIService {
  static Future<List<AIReceiptItem>> parseReceipt({
    required String provider, // 'gemini' or 'openrouter'
    required String apiKey,
    required String model,
    required String imageBase64,
    required String mimeType,
  }) async {
    const prompt = "Analyze this receipt. Extract all items on the receipt. "
        "Regardless of the language of the receipt or the app, you MUST return the name translated to English, "
        "and the unit MUST be exactly one of: 'g', 'kg', 'ml', 'l', or 'units'.";

    final receiptSchema = {
      "type": "OBJECT",
      "properties": {
        "items": {
          "type": "ARRAY",
          "items": {
            "type": "OBJECT",
            "properties": {
              "name": {
                "type": "STRING",
                "description": "Name of the product in English."
              },
              "quantity": {
                "type": "NUMBER",
                "description": "Quantity purchased."
              },
              "unit": {
                "type": "STRING",
                "enum": ["g", "kg", "ml", "l", "units"],
                "description": "Unit of the quantity. Must be exactly 'g', 'kg', 'ml', 'l', or 'units'."
              }
            },
            "required": ["name", "quantity", "unit"]
          }
        }
      },
      "required": ["items"]
    };

    try {
      if (provider == 'gemini') {
        // DEFAULT MODEL: gemini-2.5-flash — do NOT downgrade this without discussion.
        // 1.5-flash lacks multimodal quality needed for receipt parsing.
        final defaultModel = model.isEmpty ? 'gemini-2.5-flash' : model;
        final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$defaultModel:generateContent?key=$apiKey');

        final body = json.encode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inlineData": {
                    "mimeType": mimeType,
                    "data": imageBase64,
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "responseMimeType": "application/json",
            "responseSchema": receiptSchema,
          }
        });

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode != 200) {
          throw Exception("Gemini API error: ${response.statusCode} - ${response.body}");
        }

        final data = json.decode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        final parsed = json.decode(text);
        final list = parsed['items'] as List? ?? [];
        return list.map((e) => AIReceiptItem.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        // OpenRouter
        final defaultModel = model.isEmpty ? 'google/gemini-2.5-flash' : model;
        final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

        final body = json.encode({
          "model": defaultModel,
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": prompt},
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:$mimeType;base64,$imageBase64",
                  }
                }
              ]
            }
          ],
          "response_format": {
            "type": "json_schema",
            "json_schema": {
              "name": "receipt_items",
              "strict": true,
              "schema": receiptSchema,
            }
          }
        });

        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiKey",
          },
          body: body,
        );

        if (response.statusCode != 200) {
          throw Exception("OpenRouter API error: ${response.statusCode} - ${response.body}");
        }

        final data = json.decode(response.body);
        final text = data['choices'][0]['message']['content'] as String;
        final parsed = json.decode(text);
        final list = parsed['items'] as List? ?? [];
        return list.map((e) => AIReceiptItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('SocketException') || errorStr.contains('connection abort') || errorStr.contains('ClientException')) {
        throw Exception("Network connection failed. The AI service aborted the connection. Please check your internet connection and try again.\n\nDetails: $e");
      }
      rethrow;
    }
  }

  static Future<AIProductDetails> autofillProduct({
    required String provider, // 'gemini' or 'openrouter'
    required String apiKey,
    required String model,
    required String productName,
  }) async {
    final prompt = "Predict the nutritional information and properties for a product named '$productName'. "
        "Provide all fields in English. "
        "CRITICAL INSTRUCTIONS:\n"
        "1. 'unitWeight': This is the average weight of one single item/unit of this product in grams. "
        "If it is a piece of food (like banana, apple, egg, slice of bread, burger, etc.), you MUST predict a realistic positive weight of 1 unit in grams (e.g. 120 for banana, 150 for apple, 50 for an egg, 30 for a slice of bread). "
        "Only return null/0 if it is a bulk powder/liquid that is never measured in individual units.\n"
        "2. 'isStockRaw': set to true if the product is typically bought in a raw form with inedible parts (like banana with peel, eggs with shells, bone-in meat, whole oranges). "
        "Set to false if it is 100% edible (like boneless chicken breast, apple, bread, protein powder).";

    final productSchema = {
      "type": "OBJECT",
      "properties": {
        "name": {
          "type": "STRING",
          "description": "Cleaned name of product in English."
        },
        "kcal": {
          "type": "NUMBER",
          "description": "Calories per 100g/ml."
        },
        "proteins": {
          "type": "NUMBER",
          "description": "Proteins in grams per 100g/ml."
        },
        "carbsAvailable": {
          "type": "NUMBER",
          "description": "Available carbohydrates in grams per 100g/ml."
        },
        "carbsByDifference": {
          "type": "NUMBER",
          "description": "Carbohydrates by difference in grams per 100g/ml."
        },
        "dietaryFiber": {
          "type": "NUMBER",
          "description": "Dietary fiber in grams per 100g/ml."
        },
        "fats": {
          "type": "NUMBER",
          "description": "Fats in grams per 100g/ml."
        },
        "defaultUnits": {
          "type": "STRING",
          "enum": ["g", "ml", "units"],
          "description": "Default units."
        },
        "unitWeight": {
          "type": "INTEGER",
          "description": "Weight of 1 unit in grams if defaultUnits is 'units' or if it is commonly measured in units. MUST be a realistic positive integer (e.g. 150 for an apple) or null if not applicable."
        },
        "mlToGFactor": {
          "type": "INTEGER",
          "description": "Weight in grams of 100ml (or density percentage) if defaultUnits is 'ml', else null."
        },
        "isSupplement": {
          "type": "BOOLEAN",
          "description": "Whether this is a supplement."
        },
        "isPortable": {
          "type": "BOOLEAN",
          "description": "Whether this product is portable."
        },
        "edibleQtyPerUnit": {
          "type": "NUMBER",
          "description": "Edible portion ratio (e.g. 0.7 for banana, 1.0 for apple, 0.65 for orange), representing what fraction of the purchased weight is edible. Null if unknown."
        },
        "isStockRaw": {
          "type": "BOOLEAN",
          "description": "Whether the product is bought raw/unpeeled/with bones (e.g. eggs, bananas, bone-in meat)."
        }
      },
      "required": ["name", "kcal", "proteins", "carbsAvailable", "carbsByDifference", "dietaryFiber", "fats", "defaultUnits", "isSupplement", "isPortable", "isStockRaw"]
    };

    if (provider == 'gemini') {
      // DEFAULT MODEL: gemini-2.5-flash — do NOT downgrade this without discussion.
      // 1.5-flash produces poor results for nutritional autofill.
      final defaultModel = model.isEmpty ? 'gemini-2.5-flash' : model;
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$defaultModel:generateContent?key=$apiKey');

      final body = json.encode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "responseMimeType": "application/json",
          "responseSchema": productSchema,
        }
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception("Gemini API error: ${response.statusCode} - ${response.body}");
      }

      final data = json.decode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      final parsed = json.decode(text);
      return AIProductDetails.fromJson(parsed as Map<String, dynamic>);
    } else {
      // OpenRouter
      final defaultModel = model.isEmpty ? 'google/gemini-2.5-flash' : model;
      final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

      final body = json.encode({
        "model": defaultModel,
        "messages": [
          {
            "role": "user",
            "content": prompt,
          }
        ],
        "response_format": {
          "type": "json_schema",
          "json_schema": {
            "name": "product_details",
            "strict": true,
            "schema": productSchema,
          }
        }
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception("OpenRouter API error: ${response.statusCode} - ${response.body}");
      }

      final data = json.decode(response.body);
      final text = data['choices'][0]['message']['content'] as String;
      final parsed = json.decode(text);
      return AIProductDetails.fromJson(parsed as Map<String, dynamic>);
    }
  }

  static Future<Map<String, int?>> disambiguateReceiptItems({
    required String provider,
    required String apiKey,
    required String model,
    required List<Map<String, dynamic>> itemsWithCandidates,
  }) async {
    if (itemsWithCandidates.isEmpty || apiKey.trim().isEmpty) return {};

    final prompt = "You are a grocery item matching assistant. "
        "For each receipt item below, pick the ID of the candidate product that best corresponds to it. "
        "If none of the candidates match, return null for matchedProductId. "
        "Receipt items and their close candidates:\n"
        "${json.encode(itemsWithCandidates)}";

    final schema = {
      "type": "OBJECT",
      "properties": {
        "matches": {
          "type": "ARRAY",
          "items": {
            "type": "OBJECT",
            "properties": {
              "receiptName": {"type": "STRING"},
              "matchedProductId": {"type": "INTEGER", "nullable": true}
            },
            "required": ["receiptName"]
          }
        }
      },
      "required": ["matches"]
    };

    try {
      if (provider == 'gemini') {
        final defaultModel = model.isEmpty ? 'gemini-2.5-flash' : model;
        final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$defaultModel:generateContent?key=$apiKey');

        final body = json.encode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ]
            }
          ],
          "generationConfig": {
            "responseMimeType": "application/json",
            "responseSchema": schema,
          }
        });

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
          final parsed = json.decode(text);
          final matches = parsed['matches'] as List? ?? [];
          final result = <String, int?>{};
          for (final m in matches) {
            final name = m['receiptName'] as String?;
            final id = m['matchedProductId'] as int?;
            if (name != null) {
              result[name.toLowerCase().trim()] = id;
            }
          }
          return result;
        }
      } else {
        // OpenRouter
        final defaultModel = model.isEmpty ? 'google/gemini-2.5-flash' : model;
        final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

        final body = json.encode({
          "model": defaultModel,
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "response_format": {
            "type": "json_schema",
            "json_schema": {
              "name": "receipt_matches",
              "strict": true,
              "schema": schema,
            }
          }
        });

        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiKey",
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final text = data['choices'][0]['message']['content'] as String;
          final parsed = json.decode(text);
          final matches = parsed['matches'] as List? ?? [];
          final result = <String, int?>{};
          for (final m in matches) {
            final name = m['receiptName'] as String?;
            final id = m['matchedProductId'] as int?;
            if (name != null) {
              result[name.toLowerCase().trim()] = id;
            }
          }
          return result;
        }
      }
    } catch (_) {
      // Graceful fallback on network or API failures
    }
    return {};
  }

  /// Build AI user context prompt adhering strictly to privacy permission toggles
  static String buildUserContextPrompt({
    required bool enableAiAssistant,
    required bool enablePreferences,
    required String userPreferences,
    required bool allowMealHistory,
    String? mealHistorySummary,
    required bool allowWorkoutHistory,
    String? workoutHistorySummary,
    required bool allowStatistics,
    String? statisticsSummary,
    required bool allowMeasurements,
    String? measurementsSummary,
  }) {
    if (!enableAiAssistant) {
      return "AI Assistant is deactivated.";
    }

    final buffer = StringBuffer();
    buffer.writeln("USER CONTEXT & PREFERENCES (Only approved data included):");

    if (enablePreferences && userPreferences.trim().isNotEmpty) {
      buffer.writeln("- User Preferences & Medical/Training notes: $userPreferences");
    }

    if (allowWorkoutHistory && workoutHistorySummary != null && workoutHistorySummary.isNotEmpty) {
      buffer.writeln("- Workout History: $workoutHistorySummary");
    }

    if (allowMealHistory && mealHistorySummary != null && mealHistorySummary.isNotEmpty) {
      buffer.writeln("- Meal History / Nutrition: $mealHistorySummary");
    }

    if (allowStatistics && statisticsSummary != null && statisticsSummary.isNotEmpty) {
      buffer.writeln("- User Statistics & Progress: $statisticsSummary");
    }

    if (allowMeasurements && measurementsSummary != null && measurementsSummary.isNotEmpty) {
      buffer.writeln("- Recent Measurements: $measurementsSummary");
    }

    return buffer.toString();
  }

  /// Helper to assemble payload respecting all privacy flags
  static String assembleWorkoutAiPrompt({
    required bool aiWorkoutGenerationEnabled,
    required bool aiAllowUserPreferences,
    required String userPreferences,
    required bool aiAllowMealHistory,
    String? mealHistorySummary,
    required bool aiAllowWorkoutHistory,
    String? workoutHistorySummary,
    required bool aiAllowUserStats,
    String? statisticsSummary,
    required bool aiAllowMeasurements,
    String? measurementsSummary,
  }) {
    return buildUserContextPrompt(
      enableAiAssistant: aiWorkoutGenerationEnabled,
      enablePreferences: aiAllowUserPreferences,
      userPreferences: userPreferences,
      allowMealHistory: aiAllowMealHistory,
      mealHistorySummary: mealHistorySummary,
      allowWorkoutHistory: aiAllowWorkoutHistory,
      workoutHistorySummary: workoutHistorySummary,
      allowStatistics: aiAllowUserStats,
      statisticsSummary: statisticsSummary,
      allowMeasurements: aiAllowMeasurements,
      measurementsSummary: measurementsSummary,
    );
  }

  /// AI Exercise Replacement by Muscle Group Similarity
  /// Reorders or suggests exercises that match primary/secondary muscle targets.
  static Future<List<String>> getReplacementSuggestions({
    required String provider,
    required String apiKey,
    required String model,
    required String targetExerciseName,
    required List<String> targetMuscles,
    required List<Map<String, dynamic>> availableExercises,
  }) async {
    // Local similarity algorithm as fast & reliable offline-first fallback
    final sortedByMuscleMatch = List<Map<String, dynamic>>.from(availableExercises);

    sortedByMuscleMatch.sort((a, b) {
      final scoreA = (a['commonMuscles'] as num?)?.toInt() ?? 0;
      final scoreB = (b['commonMuscles'] as num?)?.toInt() ?? 0;
      return scoreB.compareTo(scoreA);
    });

    final localFallbackIds = sortedByMuscleMatch
        .where((e) => e['name'] != targetExerciseName)
        .take(5)
        .map((e) => e['id'] as String)
        .toList();

    if (apiKey.isEmpty) {
      return localFallbackIds;
    }

    final prompt = "Given target exercise '$targetExerciseName' which trains: ${targetMuscles.join(', ')}. "
        "Select up to 5 best replacement exercise IDs from the following list of candidate exercises based on biomechanical similarity and muscle group targets: "
        "${jsonEncode(availableExercises.take(40).toList())}. Return a JSON array of strings containing just the exercise IDs in best order.";

    try {
      if (provider == 'gemini') {
        final defaultModel = model.isEmpty ? 'gemini-2.5-flash' : model;
        final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$defaultModel:generateContent?key=$apiKey');
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "contents": [
              {"parts": [{"text": prompt}]}
            ],
            "generationConfig": {
              "responseMimeType": "application/json",
            }
          }),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
          final List<dynamic> ids = jsonDecode(text);
          return ids.map((e) => e.toString()).toList();
        }
      } else {
        // OpenRouter
        final defaultModel = model.isEmpty ? 'google/gemini-2.5-flash' : model;
        final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiKey",
          },
          body: jsonEncode({
            "model": defaultModel,
            "messages": [
              {"role": "user", "content": prompt}
            ],
            "response_format": {
              "type": "json_object",
            }
          }),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['choices'][0]['message']['content'] as String;
          final parsed = jsonDecode(text);
          if (parsed is List) {
            return parsed.map((e) => e.toString()).toList();
          } else if (parsed is Map && parsed.values.first is List) {
            return (parsed.values.first as List).map((e) => e.toString()).toList();
          }
        }
      }
    } catch (_) {}

    return localFallbackIds;
  }

  /// AI Workout Reordering: "Machine Busy"
  /// Given the current workout exercises and the busy exercise index,
  /// reorders the list to push the busy exercise to a later appropriate slot.
  static List<int> reorderMachineBusy({
    required int busyIndex,
    required int totalExercises,
  }) {
    if (totalExercises <= 1 || busyIndex < 0 || busyIndex >= totalExercises) {
      return List.generate(totalExercises, (i) => i);
    }
    final order = List.generate(totalExercises, (i) => i);
    final removed = order.removeAt(busyIndex);
    // Push towards the end or next available slot
    order.add(removed);
    return order;
  }

  /// AI Custom Exercise Creator
  static Future<Map<String, dynamic>?> generateCustomExercise({
    required String provider,
    required String apiKey,
    required String model,
    required String exerciseDescription,
  }) async {
    const prompt = "Create a detailed exercise definition based on this description. "
        "Return JSON with: name (string), category (one of: STRENGTH, CARDIO, STRETCHING, POWERLIFTING, OLYMPIC_WEIGHTLIFTING, PLYOMETRICS), "
        "level (BEGINNER, INTERMEDIATE, EXPERT), force (PUSH, PULL, STATIC), mechanic (COMPOUND, ISOLATION), "
        "equipment (BARBELL, DUMBBELL, MACHINE, CABLE, BODY_ONLY, BANDS, KETTLEBELLS, OTHER), "
        "primaryMuscles (array of strings from: CHEST, SHOULDERS, TRICEPS, BICEPS, LATS, MIDDLE_BACK, LOWER_BACK, QUADRICEPS, HAMSTRINGS, GLUTES, CALVES, ABDOMINALS), "
        "instructions (array of steps as strings).";

    if (apiKey.isEmpty) {
      return {
        "name": exerciseDescription,
        "category": "STRENGTH",
        "level": "BEGINNER",
        "force": "PUSH",
        "mechanic": "COMPOUND",
        "equipment": "MACHINE",
        "primaryMuscles": ["CHEST"],
        "instructions": ["Set up the machine", "Execute with controlled form", "Return slowly"],
      };
    }

    try {
      if (provider == 'gemini') {
        final defaultModel = model.isEmpty ? 'gemini-2.5-flash' : model;
        final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$defaultModel:generateContent?key=$apiKey');
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "contents": [
              {"parts": [{"text": "$prompt\nDescription: $exerciseDescription"}]}
            ],
            "generationConfig": {
              "responseMimeType": "application/json",
            }
          }),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
          return jsonDecode(text) as Map<String, dynamic>;
        }
      }
    } catch (_) {}

    return {
      "name": exerciseDescription,
      "category": "STRENGTH",
      "level": "BEGINNER",
      "force": "PUSH",
      "mechanic": "COMPOUND",
      "equipment": "MACHINE",
      "primaryMuscles": ["CHEST"],
      "instructions": ["Perform repetitions safely with correct posture"],
    };
  }

  /// Interactive Workout Chat Creator
  static Future<String> chatWithWorkoutAssistant({
    required String provider,
    required String apiKey,
    required String model,
    required String userContext,
    required List<Map<String, String>> conversationHistory,
    required String userMessage,
  }) async {
    if (apiKey.isEmpty) {
      return "AI Workout Assistant: I have received your request ('$userMessage'). Please configure your AI API key in Settings to receive personalized real-time workout recommendations based on your preferences.";
    }

    final systemPrompt = "You are an expert fitness coach and workout planner in the Nexc fitness app. "
        "Your task is to answer user training questions and design tailored workout routines. "
        "Use any allowed user context provided below:\n$userContext\n"
        "Keep responses structured, encouraging, concise and practical.\n\n"
        "When proposing or designing a workout routine, please format it clearly in markdown with:\n"
        "- A routine title on its own line (e.g. '### Routine: Upper Body Hypertrophy' or 'Routine: Leg Day Power')\n"
        "- For each exercise, specify the exercise name, number of sets, and target reps (or duration) (e.g. '• Barbell Bench Press: 3 sets x 8-12 reps')\n"
        "- You may also include a JSON code block with tag ```json containing:\n"
        "{\n"
        "  \"title\": \"Routine Title\",\n"
        "  \"notes\": \"Short description\",\n"
        "  \"exercises\": [\n"
        "    {\"name\": \"Exercise Name\", \"sets\": 3, \"reps\": 10, \"load\": 50.0, \"restTime\": 90}\n"
        "  ]\n"
        "}``` so the app can provide an instant 1-tap 'Save as Routine' button.";

    try {
      if (provider == 'gemini') {
        final defaultModel = model.isEmpty ? 'gemini-2.5-flash' : model;
        final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$defaultModel:generateContent?key=$apiKey');
        final contents = [
          {
            "parts": [{"text": systemPrompt}]
          },
          ...conversationHistory.map((m) => {
            "role": m['role'] == 'user' ? 'user' : 'model',
            "parts": [{"text": m['content'] ?? ''}],
          }),
          {
            "role": "user",
            "parts": [{"text": userMessage}]
          }
        ];

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"contents": contents}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['candidates'][0]['content']['parts'][0]['text'] as String;
        } else {
          return "Gemini API error: ${response.statusCode} - ${response.body}";
        }
      } else {
        // OpenRouter
        final defaultModel = model.isEmpty ? 'google/gemini-2.5-flash' : model;
        final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
        final messages = [
          {"role": "system", "content": systemPrompt},
          ...conversationHistory.map((m) => {
            "role": m['role'] == 'user' ? 'user' : 'assistant',
            "content": m['content'] ?? '',
          }),
          {"role": "user", "content": userMessage},
        ];

        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $apiKey",
          },
          body: jsonEncode({
            "model": defaultModel,
            "messages": messages,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'] as String;
        } else {
          return "OpenRouter API error: ${response.statusCode} - ${response.body}";
        }
      }
    } catch (e) {
      return "Error contacting AI service: $e";
    }
  }
}

