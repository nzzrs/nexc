# Nexc Import Formats Specification

This document details the JSON schema specifications used for importing data into Nexc.

---

## 1. Workout Plans (Routines)

Workout plans are imported as a JSON array of workout objects.

### Fields Description

| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | `String` | Title of the workout plan/routine. |
| `notes` | `String` | Description or instructions for the routine. |
| `timeElapsed` | `Int` | Default elapsed time in seconds. |
| `created` | `String` | ISO 8601 Date string. |
| `completed` | `String` | ISO 8601 Date string. |
| `isTemporal` | `Bool?` | Optional. If `true`, auto-deletes upon completion. |
| `exercises` | `Array` | List of exercise items in the plan. |

### Exercise Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `exerciseId` | `String` | Unique ID of the exercise. |
| `name` | `String` | Name of the exercise (used if not found in local database). |
| `notes` | `String` | Exercise-specific notes. |
| `setMode` | `String` | `LOAD`, `BODYWEIGHT`, `BODYWEIGHT_WITH_LOAD`, `TIME`, `TIME_WITH_LOAD`. |
| `restTime` | `Int` | Rest time in seconds between sets. |
| `supersetGroupId` | `String?` | Optional identifier to group supersets. |
| `sets` | `Array` | Sets list. |

### Set Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `load` | `Double` | Weight load (kg/lbs). |
| `reps` | `Int` | Target repetitions count. |
| `elapsedTime` | `Int` | Target set duration in seconds (optional). |
| `rpe` | `String?` | Rated Perceived Exertion (1-10). |
| `rir` | `Int?` | Reps in Reserve. |
| `completed` | `Bool` | Set to `false` for imported templates. |

### Example

```json
[
  {
    "title": "Hypertrophy Push A",
    "notes": "Focus on controlled eccentrics",
    "timeElapsed": 0,
    "created": "2026-06-03T12:00:00Z",
    "completed": "2026-06-03T13:00:00Z",
    "isTemporal": true,
    "exercises": [
      {
        "exerciseId": "db_bench_press",
        "name": "Dumbbell Bench Press",
        "notes": "Keep shoulder blades retracted",
        "setMode": "LOAD",
        "restTime": 90,
        "sets": [
          {
            "load": 32.5,
            "reps": 10,
            "elapsedTime": 0,
            "rpe": null,
            "rir": null,
            "completed": false
          }
        ]
      }
    ]
  }
]
```

---

## 2. Exercises

Exercises are imported as a JSON array of custom exercises.

### Fields Description

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique identifier (e.g. `my_custom_exercise`). |
| `name` | `String` | Name of the exercise. |
| `level` | `String` | `BEGINNER`, `INTERMEDIATE`, `ADVANCED`. |
| `category` | `String` | `STRENGTH`, `STRETCHING`, `PLYOMETRICS`, `STRONGMAN`, `POWERLIFTING`, `CARDIO`, `OLYMPIC_WEIGHTLIFTING`. |
| `equipment` | `String?` | `BARBELL`, `DUMBBELL`, `CABLE`, `MACHINE`, `KETTLEBELLS`, `BANDS`, `MEDICINE_BALL`, `BODY_ONLY`, `FOAM_ROLL`, `EXERCISE_BALL`, `E_Z_CURL_BAR`, `OTHER`. |
| `force` | `String?` | `PUSH`, `PULL`, `STATIC`. |
| `mechanic` | `String?` | `COMPOUND`, `ISOLATION`. |
| `primaryMuscles` | `Array` | Muscle names (e.g. `chest`, `triceps`). |
| `secondaryMuscles` | `Array` | Muscle names. |
| `instructions` | `Array` | List of instruction text paragraphs. |
| `images` | `Array` | List of image asset URLs/filenames. |

---

## 3. Meal Plans

Meal plans are imported as a JSON array of templates.

### Meal Plan Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `title` | `String` | Title of the meal plan. |
| `notes` | `String` | Overall plan description. |
| `isTemporal` | `Bool?` | If `true`, auto-deletes when completed. |
| `meals` | `Array` | List of meals within the plan. |

### Meal Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | `String` | Meal name (e.g. Breakfast). |
| `time` | `String` | Time as HH:mm:ss (e.g. 08:00:00). |
| `notes` | `String` | Meal description. |
| `position` | `Int` | Ordering index of the meal. |
| `atHome` | `Bool` | Whether the meal is eaten at home. Default: true. |
| `items` | `Array` | List of meal items. |

### Meal Item Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `type` | `String` | PRODUCT or RECIPE. |
| `amount` | `Double` | Portion quantity in the specified unit. |
| `amountUnit` | `String` | GRAMS, ML, or UNITS. Default: GRAMS. |
| `consumed` | `Bool` | Whether it is marked consumed. Default: false. |
| `position` | `Int` | Ordering index of the item. |
| `product` | `Object` | Embedded product (for type=PRODUCT). |
| `recipe` | `Object` | Embedded recipe (for type=RECIPE). |

> Each item must have either a targetId (DB reference) or an embedded product/recipe object.

---

## 4. Products

Products are imported as a JSON array.

### Fields Description

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | `String` | Yes | Product name. |
| `proteins` | `Double` | No | Protein per 100 g. |
| `fats` | `Double` | No | Fat per 100 g. |
| `carbsAvailable` | `Double` | No | Available (net) carbs per 100 g. |
| `carbsByDifference` | `Double` | No | Carbs by difference per 100 g. |
| `dietaryFiber` | `Double` | No | Dietary fiber per 100 g. |
| `kcal` | `Double` | No | Kilocalories per 100 g. |
| `mlToGFactor` | `Int` | No | ml-to-g conversion factor (e.g. 103 for whole milk). If 0, ml unit is hidden. |
| `unitWeight` | `Int` | No | Weight of one unit in grams (e.g. 120 for a banana). If 0, units are hidden. |
| `edibleQtyPerUnit` | `Double` | No | Edible grams per unit. Used with isStockRaw. |
| `defaultUnits` | `String` | No | Default stock unit: g, ml, or units. |
| `isSupplement` | `Bool` | No | true for supplements. Default: false. |
| `isPortable` | `Bool` | No | Whether portable. Default: true. |
| `isStockRaw` | `Bool` | No | true if stock includes non-edible parts (peel, shell, etc.). App uses edibleQtyPerUnit to compute actual consumed grams. Default: false. |

---

## 5. Recipes

Recipes are imported as a JSON array.

### Fields Description

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `name` | `String` | Yes | Recipe name. |
| `instructions` | `String` | No | Preparation instructions. |
| `isPortable` | `Bool` | No | Whether portable. Default: true. |
| `ingredients` | `Array` | No | Ingredient list. |

### Ingredient Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `amount` | `Double` | Quantity in grams. |
| `product` | `Object` | A full Product object (see section 4). |

> All ingredient products must either exist in the database (matched by name) or be provided as embedded objects.
