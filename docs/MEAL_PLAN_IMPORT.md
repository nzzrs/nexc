# Meal Plan Import JSON Format

Meal plans in Nexc can be imported and exported using a simple, self-contained JSON schema. This allows you to transfer plans, including all their referenced products and recipes, between devices.

## Schema Details

A meal plan backup file is a JSON array of **Meal Plan Objects**.

### 1. Meal Plan Object
- **`title`** (String, required): Name of the plan.
- **`notes`** (String, optional): Description or goals.
- **`state`** (String, optional): Usually `"TEMPLATE"` for reusable plans.
- **`created`** (String, optional): ISO LocalDateTime (e.g., `"2026-05-26T08:00:00"`).
- **`completed`** (String, optional): ISO LocalDateTime.
- **`meals`** (Array of Meals, optional): The scheduled meal slots.

### 2. Meal Object
- **`name`** (String, required): Name of the meal slot (e.g., "Desayuno", "Almuerzo").
- **`time`** (String, required): Scheduled time in ISO LocalTime format (e.g., `"08:30:00"`).
- **`notes`** (String, optional): Special instructions ("cómo comer").
- **`position`** (Int, optional): Chronological ordering.
- **`items`** (Array of Meal Items, required): Foods/supplements in this meal.

### 3. Meal Item Object
- **`type`** (String, required): Either `"PRODUCT"` or `"RECIPE"`.
- **`amount`** (Double, required): Quantity in grams or units (e.g., `100.0` for 100g, or `5.0` for 5g/scoops).
- **`consumed`** (Boolean, optional): Check-off status. Default is `false`.
- **`position`** (Int, optional): Ordering.
- **`product`** (Product Object, optional): Required if type is `"PRODUCT"`.
- **`recipe`** (Recipe Object, optional): Required if type is `"RECIPE"`.

### 4. Product Object
- **`name`** (String, required): Name of the food/supplement.
- **`weight`** (Double): Packaging weight (g/ml).
- **`cost`** (Double): Price per unit weight.
- **`quantity`** (Int): Current stock quantity.
- **`units`** (String): Units of weight (e.g., `"g"`, `"ml"`, `"scoop"`).
- **`ediblePercent`** (Double): Est. edible percentage (e.g., `1.0` = 100%).
- **`edibleQtyPerUnit`** (Double): Est. edible quantity per packaging unit.
- **`proteins`** (Double): Proteins per 100g.
- **`carbs`** (Double): Carbohydrates per 100g.
- **`fats`** (Double): Fats per 100g.
- **`isSupplement`** (Boolean): Differentiates natural food from supplements (e.g., creatine).

### 5. Recipe Object
- **`name`** (String, required): Name of the prepared dish.
- **`instructions`** (String): Process/steps.
- **`isPortable`** (Boolean): Suitability to eat on-the-go (e.g., `true` or `false`).
- **`ingredients`** (Array of Recipe Ingredients):
  - **`amount`** (Double): Amount of this ingredient (g).
  - **`product`** (Product Object): Details of the ingredient product.

---

## Example Import JSON File

Here is an example plan covering a day, including 4 structured meals with foods, recipes, and supplements (like milk, cookies, and creatine for breakfast; chicken and rice for lunch):

```json
[
  {
    "title": "Daily High-Protein & Supplement Plan",
    "notes": "Focused day including natural food and pre/post training supplements.",
    "state": "TEMPLATE",
    "meals": [
      {
        "name": "Desayuno & Suplementación",
        "time": "08:00:00",
        "notes": "Tomar inmediatamente al despertar con abundante agua.",
        "position": 0,
        "items": [
          {
            "type": "PRODUCT",
            "amount": 250.0,
            "consumed": false,
            "position": 0,
            "product": {
              "name": "Leche Entera",
              "weight": 1000.0,
              "cost": 1.20,
              "quantity": 2,
              "units": "ml",
              "ediblePercent": 1.0,
              "edibleQtyPerUnit": 0.0,
              "proteins": 3.3,
              "carbs": 4.7,
              "fats": 3.6,
              "isSupplement": false
            }
          },
          {
            "type": "PRODUCT",
            "amount": 50.0,
            "consumed": false,
            "position": 1,
            "product": {
              "name": "Galletas de Avena",
              "weight": 200.0,
              "cost": 1.50,
              "quantity": 5,
              "units": "g",
              "ediblePercent": 1.0,
              "edibleQtyPerUnit": 0.0,
              "proteins": 6.5,
              "carbs": 65.0,
              "fats": 15.0,
              "isSupplement": false
            }
          },
          {
            "type": "PRODUCT",
            "amount": 5.0,
            "consumed": false,
            "position": 2,
            "product": {
              "name": "Creatina Monohidratada",
              "weight": 300.0,
              "cost": 18.00,
              "quantity": 1,
              "units": "g",
              "ediblePercent": 1.0,
              "edibleQtyPerUnit": 0.0,
              "proteins": 0.0,
              "carbs": 0.0,
              "fats": 0.0,
              "isSupplement": true
            }
          }
        ]
      },
      {
        "name": "Almuerzo",
        "time": "13:30:00",
        "notes": "Comida principal del día.",
        "position": 1,
        "items": [
          {
            "type": "PRODUCT",
            "amount": 100.0,
            "consumed": false,
            "position": 0,
            "product": {
              "name": "Pollo (Pechuga)",
              "weight": 1000.0,
              "cost": 7.50,
              "quantity": 1,
              "units": "g",
              "ediblePercent": 1.0,
              "edibleQtyPerUnit": 0.0,
              "proteins": 31.0,
              "carbs": 0.0,
              "fats": 3.6,
              "isSupplement": false
            }
          },
          {
            "type": "PRODUCT",
            "amount": 100.0,
            "consumed": false,
            "position": 1,
            "product": {
              "name": "Arroz Cocido",
              "weight": 1000.0,
              "cost": 1.50,
              "quantity": 3,
              "units": "g",
              "ediblePercent": 1.0,
              "edibleQtyPerUnit": 0.0,
              "proteins": 2.7,
              "carbs": 28.0,
              "fats": 0.3,
              "isSupplement": false
            }
          }
        ]
      },
      {
        "name": "Merienda Pre-Entreno",
        "time": "17:00:00",
        "notes": "1 hora antes de entrenar.",
        "position": 2,
        "items": [
          {
            "type": "PRODUCT",
            "amount": 100.0,
            "consumed": false,
            "position": 0,
            "product": {
              "name": "Plátano",
              "weight": 150.0,
              "cost": 0.30,
              "quantity": 6,
              "units": "g",
              "ediblePercent": 0.65,
              "edibleQtyPerUnit": 97.5,
              "proteins": 1.1,
              "carbs": 22.8,
              "fats": 0.3,
              "isSupplement": false
            }
          }
        ]
      },
      {
        "name": "Cena",
        "time": "21:00:00",
        "notes": "Comida ligera antes de dormir.",
        "position": 3,
        "items": [
          {
            "type": "RECIPE",
            "amount": 1.0,
            "consumed": false,
            "position": 0,
            "recipe": {
              "name": "Huevos Revueltos con Espinaca",
              "instructions": "Calentar sartén con una gota de aceite. Verter 2 huevos batidos y espinacas limpias. Cocinar 3 minutos.",
              "isPortable": true,
              "ingredients": [
                {
                  "amount": 120.0,
                  "product": {
                    "name": "Huevo Duro/Fresco",
                    "weight": 60.0,
                    "cost": 0.15,
                    "quantity": 30,
                    "units": "unit",
                    "ediblePercent": 0.88,
                    "edibleQtyPerUnit": 52.8,
                    "proteins": 13.0,
                    "carbs": 1.1,
                    "fats": 11.0,
                    "isSupplement": false
                  }
                },
                {
                  "amount": 50.0,
                  "product": {
                    "name": "Espinaca Fresca",
                    "weight": 250.0,
                    "cost": 1.20,
                    "quantity": 1,
                    "units": "g",
                    "ediblePercent": 0.95,
                    "edibleQtyPerUnit": 0.0,
                    "proteins": 2.9,
                    "carbs": 3.6,
                    "fats": 0.4,
                    "isSupplement": false
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
