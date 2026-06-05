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
        final defaultModel = model.isEmpty ? 'gemini-1.5-flash' : model;
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
      final defaultModel = model.isEmpty ? 'gemini-1.5-flash' : model;
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
}
