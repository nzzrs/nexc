# Meal Plan Import JSON Format

Meal plans in Nexc can be imported and exported using a self-contained JSON schema. This transfers plans — including all referenced products and recipes — between devices.

## Schema Details

A meal plan import file is a JSON array of **Meal Plan Objects**.

---

### 1. Meal Plan Object

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | String | ✅ | Name of the plan. |
| `notes` | String | | Description or goals. |
| `state` | String | | `"TEMPLATE"` for reusable plans. See states below. |
| `created` | String | | ISO LocalDateTime (e.g. `"2026-05-26T08:00:00"`). |
| `completed` | String | | ISO LocalDateTime. |
| `meals` | Array | | Scheduled meal slots. |

**`state` values:** `TEMPLATE`, `RUNNING`, `COMPLETED`

---

### 2. Meal Object

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | String | ✅ | Name of the meal slot (e.g. `"Breakfast"`). |
| `time` | String | ✅ | Scheduled time as `"HH:mm:ss"` (e.g. `"08:30:00"`). |
| `notes` | String | | Special instructions. |
| `position` | Int | | Chronological ordering (0-indexed). |
| `atHome` | Boolean | | Whether the meal is eaten at home. Default: `true`. |
| `items` | Array | ✅ | Foods/supplements in this meal. |

---

### 3. Meal Item Object

| Field | Type | Required | Description |
|---|---|---|---|
| `type` | String | ✅ | `"PRODUCT"` or `"RECIPE"`. |
| `amount` | Double | ✅ | Quantity in the unit specified by `amountUnit`. |
| `amountUnit` | String | | Unit for `amount`. Default: `"GRAMS"`. See units below. |
| `consumed` | Boolean | | Check-off status. Default: `false`. |
| `position` | Int | | Ordering within the meal. |
| `product` | Object | | Required if `type` is `"PRODUCT"`. |
| `recipe` | Object | | Required if `type` is `"RECIPE"`. |

**`amountUnit` values:** `GRAMS`, `ML`, `UNITS`

---

### 4. Product Object

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | String | ✅ | Name of the food/supplement. |
| `proteins` | Double | ✅ | Proteins per 100 g. |
| `fats` | Double | ✅ | Fats per 100 g. |
| `isSupplement` | Boolean | ✅ | `true` for supplements (e.g. creatine, whey). |
| `carbsAvailable` | Double | | Available (net) carbs per 100 g. |
| `carbsByDifference` | Double | | Carbs by difference per 100 g (includes fiber). |
| `dietaryFiber` | Double | | Dietary fiber per 100 g. |
| `kcal` | Double | | Kilocalories per 100 g (optional, can be computed). |
| `mlToGFactor` | Int | | ml-to-g conversion factor (e.g. `103` for whole milk). If `0` or omitted, ml unit is hidden for this product. |
| `unitWeight` | Int | | Weight of one unit in grams (e.g. `120` for a banana). If `0` or omitted, units are hidden for this product. |
| `edibleQtyPerUnit` | Double | | Edible grams per unit (e.g. `78` for a banana with peel). Used with `isStockRaw`. |
| `defaultUnits` | String | | Default unit for stock display: `"g"`, `"ml"`, or `"units"`. |
| `isPortable` | Boolean | | Whether the product can be eaten on-the-go. Default: `true`. |
| `isStockRaw` | Boolean | | `true` if the stock includes non-edible parts (e.g. banana with peel, egg with shell). When `true`, the app uses `edibleQtyPerUnit` to compute actual consumed grams and deducts stock accordingly. Default: `false`. |

> **Note on carbs:** Use either `carbsAvailable` or `carbsByDifference`. If both are provided, `carbsAvailable` is used for nutritional display. `carbsByDifference` is stored separately for reference.

---

### 5. Recipe Object

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | String | ✅ | Name of the dish. |
| `instructions` | String | | Preparation steps. |
| `isPortable` | Boolean | | Suitable to eat on-the-go. Default: `true`. |
| `ingredients` | Array | | List of ingredient objects. |

**Recipe Ingredient Object:**

| Field | Type | Required | Description |
|---|---|---|---|
| `amount` | Double | ✅ | Amount in grams. |
| `product` | Object | ✅ | A Product Object (see above). |

---

## Example Import File

```json
[
  {
    "title": "Daily High-Protein Plan",
    "notes": "Focused day with natural food and supplements.",
    "state": "TEMPLATE",
    "meals": [
      {
        "name": "Breakfast & Supplementation",
        "time": "08:00:00",
        "notes": "Take immediately upon waking with plenty of water.",
        "position": 0,
        "atHome": true,
        "items": [
          {
            "type": "PRODUCT",
            "amount": 250.0,
            "amountUnit": "ML",
            "consumed": false,
            "position": 0,
            "product": {
              "name": "Whole Milk",
              "proteins": 3.3,
              "fats": 3.6,
              "carbsAvailable": 4.7,
              "kcal": 65.0,
              "mlToGFactor": 103,
              "defaultUnits": "ml",
              "isSupplement": false,
              "isPortable": true,
              "isStockRaw": false
            }
          },
          {
            "type": "PRODUCT",
            "amount": 5.0,
            "amountUnit": "GRAMS",
            "consumed": false,
            "position": 1,
            "product": {
              "name": "Creatine Monohydrate",
              "proteins": 0.0,
              "fats": 0.0,
              "carbsAvailable": 0.0,
              "defaultUnits": "g",
              "isSupplement": true,
              "isPortable": true,
              "isStockRaw": false
            }
          }
        ]
      },
      {
        "name": "Lunch",
        "time": "13:30:00",
        "notes": "Main meal of the day.",
        "position": 1,
        "atHome": true,
        "items": [
          {
            "type": "PRODUCT",
            "amount": 100.0,
            "amountUnit": "GRAMS",
            "consumed": false,
            "position": 0,
            "product": {
              "name": "Chicken Breast",
              "proteins": 31.0,
              "fats": 3.6,
              "carbsAvailable": 0.0,
              "defaultUnits": "g",
              "isSupplement": false,
              "isPortable": false,
              "isStockRaw": false
            }
          }
        ]
      },
      {
        "name": "Pre-Workout Snack",
        "time": "17:00:00",
        "notes": "1 hour before training.",
        "position": 2,
        "atHome": false,
        "items": [
          {
            "type": "PRODUCT",
            "amount": 2.0,
            "amountUnit": "UNITS",
            "consumed": false,
            "position": 0,
            "product": {
              "name": "Banana",
              "proteins": 1.1,
              "fats": 0.3,
              "carbsAvailable": 22.8,
              "dietaryFiber": 2.6,
              "unitWeight": 120,
              "edibleQtyPerUnit": 78,
              "defaultUnits": "units",
              "isSupplement": false,
              "isPortable": true,
              "isStockRaw": true
            }
          }
        ]
      },
      {
        "name": "Dinner",
        "time": "21:00:00",
        "notes": "Light meal before sleeping.",
        "position": 3,
        "atHome": true,
        "items": [
          {
            "type": "RECIPE",
            "amount": 1.0,
            "amountUnit": "GRAMS",
            "consumed": false,
            "position": 0,
            "recipe": {
              "name": "Scrambled Eggs with Spinach",
              "instructions": "Heat pan with a drop of oil. Pour 2 beaten eggs and clean spinach. Cook 3 minutes.",
              "isPortable": false,
              "ingredients": [
                {
                  "amount": 120.0,
                  "product": {
                    "name": "Egg",
                    "proteins": 13.0,
                    "fats": 11.0,
                    "carbsAvailable": 1.1,
                    "unitWeight": 60,
                    "edibleQtyPerUnit": 53,
                    "defaultUnits": "units",
                    "isSupplement": false,
                    "isPortable": true,
                    "isStockRaw": true
                  }
                },
                {
                  "amount": 50.0,
                  "product": {
                    "name": "Fresh Spinach",
                    "proteins": 2.9,
                    "fats": 0.4,
                    "carbsAvailable": 3.6,
                    "defaultUnits": "g",
                    "isSupplement": false,
                    "isPortable": false,
                    "isStockRaw": false
                  }
                }
              ]
            }
          }
        ]
      }
    ]
  }
]
```

---

## Notes on Stock Integration

Products imported via meal plans are matched by name to existing products in the database. If a product with the same name already exists, its nutritional data is **not** overwritten — only the meal item reference is created.

Stock tracking fields (`isStockRaw`, `unitWeight`, `edibleQtyPerUnit`, `mlToGFactor`) affect how the app deducts stock when meals are logged:

- **`isStockRaw = true`**: Stock is in raw/unpeeled form. The app uses `edibleQtyPerUnit` to compute the true consumed grams and deducts proportionally.
- **`mlToGFactor`**: Converts between ml and g for liquids. If `0`, the ml option is hidden.
- **`unitWeight`**: Enables the "units" amount option. If `0`, units are hidden.
