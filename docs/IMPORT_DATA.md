# Import Data Documentation

This document specifies the JSON formats and terminology for importing exercises and workout plans into the application.

## 🏋️ Importing Exercises

You can import custom exercises by providing a JSON array of Exercise objects.

### JSON Format
```json
[
  {
    "id": "exercise-unique-id",
    "name": "Exercise Name",
    "force": "push",
    "level": "beginner",
    "mechanic": "compound",
    "equipment": "dumbbell",
    "primaryMuscles": ["chest", "shoulders"],
    "secondaryMuscles": ["triceps"],
    "instructions": [
      "Step 1 description",
      "Step 2 description"
    ],
    "category": "strength"
  }
]
```

### Terminology (Concrete Words)

- **force**: `push`, `pull`, `static`, `null`
- **level**: `beginner`, `intermediate`, `expert`
- **mechanic**: `isolation`, `compound`, `null`
- **equipment**: `medicine ball`, `dumbbell`, `body only`, `bands`, `kettlebells`, `foam roll`, `cable`, `machine`, `barbell`, `exercise ball`, `e-z curl bar`, `other`, `null`
- **category**: `powerlifting`, `strength`, `stretching`, `cardio`, `olympic weightlifting`, `strongman`, `plyometrics`
- **muscles** (primary/secondary): `abdominals`, `abductors`, `adductors`, `biceps`, `calves`, `chest`, `forearms`, `glutes`, `hamstrings`, `lats`, `lower back`, `middle back`, `neck`, `quadriceps`, `shoulders`, `traps`, `triceps`

---

## 📅 Importing Workout Plans

Workout plans (routines) are imported as a JSON array of Workout objects.

### JSON Format
```json
[
  {
    "title": "My Routine",
    "notes": "Optional notes",
    "state": "ROUTINE",
    "exercises": [
      {
        "exerciseId": "bench-press",
        "name": "Bench Press",
        "notes": "Exercise specific notes",
        "setMode": "LOAD",
        "restTime": 60,
        "supersetGroupId": "optional-id-for-link",
        "sets": [
          {
            "load": 60.0,
            "reps": 10,
            "intensityScale": 0,
            "rpe": "8"
          }
        ]
      }
    ]
  }
]
```

### Syntax & Terminology

- **state**: `ROUTINE` (for importable templates), `COMPLETED`, `RUNNING`.
- **setMode**: `LOAD`, `BODYWEIGHT`, `BODYWEIGHT_WITH_LOAD`, `DURATION`.
- **supersetGroupId**: Use the same string identifier for exercises that belong to the same superset. The app will automatically group them as "Superset A", "Superset B", etc.
- **intensityScale**: `0` (RPE), `1` (RIR), `2` (BOTH).
- **rpe**: A string representing the RPE or RIR value (e.g., `"9"`, `"1"`).
- **Fields removed**: `bpe` and `rid` are no longer supported.
