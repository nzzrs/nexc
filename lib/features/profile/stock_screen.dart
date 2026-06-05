/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/db/app_database.dart';
import '../../core/db/stock_repository.dart';
import '../../core/db/meal_repository.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/integrations/ai_service.dart';
import '../../core/components/nexc_scaffold.dart';
import '../meals/products_library_screen.dart';
import 'package:image_picker/image_picker.dart';

// Providers for Stock Screen State
final activeHouseIdProvider = StateProvider<int?>((ref) => null);

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";
  bool _isImporting = false;

  final Set<int> _shoppingChecked = {};
  final Set<int> _shoppingListInitialized = {};
  final Map<int, double> _shoppingQuantities = {};
  final Map<int, String> _shoppingUnits = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    // Ensure default house exists on launch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(stockRepositoryProvider);
      await repo.ensureDefaultHouse();
      final houses = await repo.getHouses();
      if (houses.isNotEmpty && ref.read(activeHouseIdProvider) == null) {
        ref.read(activeHouseIdProvider.notifier).state = houses.first.id;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddHouseDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add House"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "House Name"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final repo = ref.read(stockRepositoryProvider);
                final newId = await repo.saveHouse(House(id: 0, name: name));
                ref.read(activeHouseIdProvider.notifier).state = newId;
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showRenameHouseDialog(House house) {
    final controller = TextEditingController(text: house.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename House"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "House Name"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final repo = ref.read(stockRepositoryProvider);
                await repo.saveHouse(house.copyWith(name: name));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteHouseDialog(House house) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete House"),
        content: Text("Are you sure you want to delete '${house.name}'? This deletes all associated stock records."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(stockRepositoryProvider);
              await repo.deleteHouse(house);
              final remaining = await repo.getHouses();
              ref.read(activeHouseIdProvider.notifier).state = remaining.isNotEmpty ? remaining.first.id : null;
              if (context.mounted) Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showAddProductToStockDialog(int houseId, List<Product> products) {
    String query = "";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filtered = query.isEmpty ? products : products.searchAndSort(query);
          return AlertDialog(
            title: const Text("Add Product to Stock"),
            content: SizedBox(
              width: 400,
              height: 350,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: "Search database...",
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (val) {
                            setDialogState(() {
                              query = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AddEditProductDialog(
                              product: Product(
                                id: 0,
                                name: query.trim(),
                                defaultUnits: "g",
                                edibleQtyPerUnit: 1.0,
                                proteins: 0.0,
                                carbsAvailable: null,
                                fats: 0.0,
                                isSupplement: false,
                                isPortable: true,
                                isStockRaw: false,
                              ),
                              onDismiss: () => Navigator.pop(ctx),
                              onConfirm: (newProd) async {
                                final repo = ref.read(stockRepositoryProvider);
                                final mealRepo = ref.read(mealRepositoryProvider);
                                final newId = await mealRepo.saveProduct(newProd);
                                await repo.saveStock(
                                  productId: newId,
                                  houseId: houseId,
                                  quantity: 0.0,
                                  minTriggerQuantity: null,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text("Unit: ${p.units}"),
                          onTap: () async {
                            final repo = ref.read(stockRepositoryProvider);
                            await repo.saveStock(
                              productId: p.id,
                              houseId: houseId,
                              quantity: 0.0,
                              minTriggerQuantity: null,
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReplaceProductDialog(
    BuildContext context,
    _ReceiptConfirmItem item,
    List<Product> products,
    void Function(void Function()) setDialogState,
  ) {
    String search = "";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSubState) {
          final filtered = search.isEmpty ? products : products.searchAndSort(search);
          return AlertDialog(
            title: Text("Map '${item.receiptName}' to..."),
            content: SizedBox(
              width: 400,
              height: 350,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: "Search database...",
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (val) {
                            setSubState(() {
                              search = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AddEditProductDialog(
                              product: Product(
                                id: 0,
                                name: item.receiptName,
                                defaultUnits: item.parsedUnit.toLowerCase() == 'l' || item.parsedUnit.toLowerCase() == 'ml' ? 'ml' : 'g',
                                edibleQtyPerUnit: 1.0,
                                kcal: 0.0,
                                proteins: 0.0,
                                carbsAvailable: 0.0,
                                fats: 0.0,
                                isSupplement: false,
                                isPortable: true,
                                isStockRaw: false,
                              ),
                              onDismiss: () => Navigator.pop(ctx),
                              onConfirm: (newProd) async {
                                final repo = ref.read(mealRepositoryProvider);
                                final newId = await repo.saveProduct(newProd);
                                final freshProducts = ref.read(allProductsProvider).value ?? [];
                                final created = freshProducts.firstWhereOrNull((p) => p.id == newId);
                                if (created != null) {
                                  // Save relationship mapping
                                  final stockRepo = ref.read(stockRepositoryProvider);
                                  await stockRepo.saveReceiptMapping(receiptName: item.receiptName, productId: created.id);
                                  setDialogState(() {
                                    item.matchedProduct = created;
                                    item.matchState = 0; // mapped
                                  });
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text("Unit: ${p.units}"),
                          onTap: () async {
                            final stockRepo = ref.read(stockRepositoryProvider);
                            await stockRepo.saveReceiptMapping(
                              receiptName: item.receiptName,
                              productId: p.id,
                            );
                            setDialogState(() {
                              item.matchedProduct = p;
                              item.matchState = 0; // mapped
                            });
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManageHousesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final repo = ref.read(stockRepositoryProvider);
        return AlertDialog(
          title: const Text("Manage Houses"),
          content: SizedBox(
            width: 350,
            height: 300,
            child: StreamBuilder<List<House>>(
              stream: repo.watchHouses(),
              builder: (context, snapshot) {
                final list = snapshot.data ?? [];
                return Column(
                  children: [
                    Expanded(
                      child: list.isEmpty
                          ? const Center(child: Text("No houses defined"))
                          : ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final h = list[index];
                                return ListTile(
                                  title: Text(h.name),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => _showRenameHouseDialog(h),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _showDeleteHouseDialog(h),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddHouseDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text("Add House"),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showCopyableErrorDialog(String title, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("An error occurred during operation:"),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    error,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text("Copy Error"),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: error));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error copied to clipboard")),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReceiptImport(int houseId, List<Product> products) async {
    final settings = ref.read(settingsProvider);
    if (settings.aiToken.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("AI API Token not configured. Set it in Settings.")),
      );
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo (Camera)"),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final extension = pickedFile.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

      final parsedItems = await AIService.parseReceipt(
        provider: settings.aiProvider,
        apiKey: settings.aiToken,
        model: settings.aiModel,
        imageBase64: base64Image,
        mimeType: mimeType,
      );

      if (parsedItems.isEmpty) {
        throw Exception("No items parsed from receipt.");
      }

      final repo = ref.read(stockRepositoryProvider);
      final mappings = await repo.getReceiptMappings();

      if (mounted) {
        _showConfirmationDialog(houseId, parsedItems, products, mappings);
      }
    } catch (e, stackTrace) {
      if (mounted) {
        _showCopyableErrorDialog("Receipt Import Error", "$e\n\n$stackTrace");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  void _showConfirmationDialog(int houseId, List<AIReceiptItem> parsedItems, List<Product> products, List<ReceiptMapping> mappings) {
    final resolvedList = parsedItems.map((parsed) {
      Product? matchedProduct;
      int matchState = 2; // Default: 🔴 Not Found

      final mapping = mappings.firstWhereOrNull((m) => m.receiptName.toLowerCase() == parsed.name.toLowerCase().trim());
      if (mapping != null) {
        matchedProduct = products.firstWhereOrNull((p) => p.id == mapping.productId);
        if (matchedProduct != null) {
          matchState = 0; // 🟢 Perfect Match
        }
      }

      if (matchedProduct == null) {
        final matches = products.searchAndSort(parsed.name);
        if (matches.isNotEmpty) {
          final firstMatch = matches.first;
          if (firstMatch.name.toLowerCase() == parsed.name.toLowerCase()) {
            matchedProduct = firstMatch;
            matchState = 0; // 🟢 Perfect Match
          } else {
            matchedProduct = firstMatch;
            matchState = 1; // 🟡 Fuzzy Match
          }
        }
      }

      return _ReceiptConfirmItem(
        receiptName: parsed.name,
        inputQuantity: parsed.quantity,
        parsedUnit: parsed.unit,
        matchedProduct: matchedProduct,
        matchState: matchState,
        isSelected: true,
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);

            return Scaffold(
              appBar: AppBar(
                title: const Text("AI Log Confirmation"),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: resolvedList.length,
                      itemBuilder: (context, index) {
                        final item = resolvedList[index];
                        Color stateColor = Colors.red;
                        String matchText = "Not found";
                        IconData icon = Icons.cancel;

                        if (item.matchState == 0) {
                          stateColor = Colors.green;
                          matchText = "Perfect Match";
                          icon = Icons.check_circle;
                        } else if (item.matchState == 1) {
                          stateColor = Colors.orange;
                          matchText = "Fuzzy Match";
                          icon = Icons.warning_amber;
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: item.isSelected,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          item.isSelected = val ?? false;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.receiptName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(icon, color: stateColor, size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                matchText,
                                                style: TextStyle(color: stateColor, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                              if (item.matchedProduct != null) ...[
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    "→ ${item.matchedProduct!.name}",
                                                    style: theme.textTheme.bodySmall,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: TextFormField(
                                              initialValue: item.inputQuantity % 1 == 0 ? item.inputQuantity.toInt().toString() : item.inputQuantity.toString(),
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              decoration: const InputDecoration(
                                                labelText: "Quantity",
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (val) {
                                                item.inputQuantity = double.tryParse(val) ?? 0.0;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 100,
                                            child: DropdownButtonFormField<String>(
                                              value: ['g', 'kg', 'ml', 'l', 'units'].contains(item.parsedUnit.toLowerCase()) ? item.parsedUnit.toLowerCase() : 'g',
                                              decoration: const InputDecoration(
                                                labelText: "Unit",
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(value: 'g', child: Text('g')),
                                                DropdownMenuItem(value: 'kg', child: Text('kg')),
                                                DropdownMenuItem(value: 'ml', child: Text('ml')),
                                                DropdownMenuItem(value: 'l', child: Text('l')),
                                                DropdownMenuItem(value: 'units', child: Text('units')),
                                              ],
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setDialogState(() {
                                                    item.parsedUnit = val;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(Icons.swap_horiz, size: 14),
                                          label: const Text("Replace"),
                                          onPressed: () {
                                            _showReplaceProductDialog(context, item, products, setDialogState);
                                          },
                                          style: TextButton.styleFrom(
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        ),
                                        if (item.matchedProduct == null) ...[
                                          const SizedBox(width: 4),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AddEditProductDialog(
                                                  product: Product(
                                                    id: 0,
                                                    name: item.receiptName,
                                                    defaultUnits: item.parsedUnit.toLowerCase() == 'l' || item.parsedUnit.toLowerCase() == 'ml' ? 'ml' : 'g',
                                                    edibleQtyPerUnit: 1.0,
                                                    proteins: 0.0,
                                                    carbsAvailable: null,
                                                    fats: 0.0,
                                                    isSupplement: false,
                                                    isPortable: true,
                                                    isStockRaw: false,
                                                  ),
                                                  onDismiss: () => Navigator.pop(ctx),
                                                  onConfirm: (newProd) async {
                                                    try {
                                                      final repo = ref.read(mealRepositoryProvider);
                                                      final newId = await repo.saveProduct(newProd);
                                                      final freshProducts = ref.read(allProductsProvider).value ?? [];
                                                      final created = freshProducts.firstWhereOrNull((p) => p.id == newId);
                                                      if (created != null) {
                                                        final stockRepo = ref.read(stockRepositoryProvider);
                                                        await stockRepo.saveReceiptMapping(receiptName: item.receiptName, productId: created.id);
                                                        setDialogState(() {
                                                          item.matchedProduct = created;
                                                          item.matchState = 0;
                                                        });
                                                      }
                                                    } catch (e, st) {
                                                      _showCopyableErrorDialog("Product Creation Error", "$e\n\n$st");
                                                    }
                                                    if (ctx.mounted) Navigator.pop(ctx);
                                                  },
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.add, size: 14),
                                            label: const Text("Create"),
                                            style: ElevatedButton.styleFrom(
                                              visualDensity: VisualDensity.compact,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final repo = ref.read(stockRepositoryProvider);
                              final currentStocks = await repo.getStocksWithProductForHouse(houseId);

                              for (final item in resolvedList) {
                                if (item.isSelected && item.matchedProduct != null && item.inputQuantity > 0.0) {
                                  double qty = item.inputQuantity;
                                  if (item.parsedUnit.toLowerCase() == 'kg' || item.parsedUnit.toLowerCase() == 'l') {
                                    qty *= 1000;
                                  }
                                  final existing = currentStocks.firstWhereOrNull((s) => s.product.id == item.matchedProduct!.id);
                                  final double finalQty = (existing?.stock.quantity ?? 0.0) + qty;
                                  await repo.saveStock(
                                    productId: item.matchedProduct!.id,
                                    houseId: houseId,
                                    quantity: finalQty,
                                    minTriggerQuantity: existing?.stock.minTriggerQuantity,
                                  );
                                }
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Logged receipt items to stock!")),
                                );
                              }
                            } catch (e, st) {
                              _showCopyableErrorDialog("Stock Logging Error", "$e\n\n$st");
                            }
                          },
                          child: const Text("Confirm"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeHouseId = ref.watch(activeHouseIdProvider);
    final repo = ref.watch(stockRepositoryProvider);
    final products = ref.watch(allProductsProvider).value ?? [];
    final settings = ref.watch(settingsProvider);

    return StreamBuilder<List<House>>(
      stream: repo.watchHouses(),
      builder: (context, snapshot) {
        final houses = snapshot.data ?? [];

        return NexcScaffold(
          title: const Text("Stock Management"),
          navigateBack: () => Navigator.pop(context),
          actions: const [],
          actionsIcons: const [],
          fabAction: activeHouseId != null
              ? () async {
                  if (_tabController.index == 0) {
                    _showAddProductToStockDialog(activeHouseId, products);
                  } else {
                    final needed = (await repo.getStocksWithProductForHouse(activeHouseId))
                        .where((s) => s.stock.minTriggerQuantity != null && s.stock.quantity < s.stock.minTriggerQuantity!)
                        .toList();
                    int restockedCount = 0;
                    for (final s in needed) {
                      if (_shoppingChecked.contains(s.product.id)) {
                        final addedQty = _shoppingQuantities[s.product.id] ?? 0.0;
                        if (addedQty > 0.0) {
                          final chosenUnit = _shoppingUnits[s.product.id] ?? s.product.units;
                          double currentQtyInChosenUnit = s.stock.quantity;
                          final stock = s.stock;
                          if (chosenUnit == 'g') {
                            currentQtyInChosenUnit = stock.quantityGrams;
                          } else if (chosenUnit == 'ml') {
                            currentQtyInChosenUnit = stock.quantityMl;
                          } else if (chosenUnit == 'units') {
                            currentQtyInChosenUnit = stock.quantityUnits;
                          }

                          final nextQty = currentQtyInChosenUnit + addedQty;

                          await repo.saveStock(
                            productId: s.product.id,
                            houseId: activeHouseId,
                            quantity: nextQty,
                            minTriggerQuantity: s.stock.minTriggerQuantity,
                            inputUnit: chosenUnit,
                          );
                          restockedCount++;
                        }
                      }
                    }
                    // Remove items that now have enough stock from shopping state
                    final updatedStocks = await repo.getStocksWithProductForHouse(activeHouseId);
                    final fulfilledIds = <int>{};
                    for (final us in updatedStocks) {
                      if (us.stock.minTriggerQuantity != null && us.stock.quantity > us.stock.minTriggerQuantity!) {
                        fulfilledIds.add(us.product.id);
                      }
                    }
                    setState(() {
                      // Clear checked/quantity state for restocked items
                      for (final id in fulfilledIds) {
                        _shoppingChecked.remove(id);
                        _shoppingListInitialized.remove(id);
                        _shoppingQuantities.remove(id);
                        _shoppingUnits.remove(id);
                      }
                      // Also clear checked state for non-fulfilled restocked items
                      _shoppingChecked.clear();
                      _shoppingListInitialized.clear();
                      _shoppingQuantities.clear();
                      _shoppingUnits.clear();
                    });
                    if (context.mounted && restockedCount > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Restocked $restockedCount items successfully!")),
                      );
                    }
                  }
                }
              : null,
          fabIcon: _tabController.index == 0 ? const Icon(Icons.add) : const Icon(Icons.check),
          fabText: _tabController.index == 0 ? "Add Stock" : "Restock Items",
          content: (context, padding) {
            if (houses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // House Selection Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        "House: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: activeHouseId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            ...houses.map((h) {
                              return DropdownMenuItem(
                                value: h.id,
                                child: Text(h.name),
                              );
                            }),
                            const DropdownMenuItem<int>(
                              value: -999,
                              child: Text("Manage Houses"),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == -999) {
                              setState(() {});
                              _showManageHousesDialog();
                            } else if (val != null) {
                              ref.read(activeHouseIdProvider.notifier).state = val;
                            }
                          },
                        ),
                      ),
                      if (settings.enableAiStockLogging && activeHouseId != null) ...[
                        const SizedBox(width: 8),
                        _isImporting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton.filledTonal(
                                icon: const Icon(Icons.receipt_long_outlined),
                                tooltip: "AI Import Receipt",
                                onPressed: () => _handleReceiptImport(activeHouseId, products),
                              ),
                      ],
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Current Stock"),
                    Tab(text: "Shopping List"),
                  ],
                ),
                Expanded(
                  child: activeHouseId == null
                      ? const Center(child: Text("Select or add a house"))
                      : StreamBuilder<List<StockWithProduct>>(
                          stream: repo.watchStocksWithProductForHouse(activeHouseId),
                          builder: (context, stockSnap) {
                            final stocks = stockSnap.data ?? [];

                            return TabBarView(
                              controller: _tabController,
                              children: [
                                // Tab 1: Current Stock
                                _buildCurrentStockTab(activeHouseId, stocks),
                                // Tab 2: Shopping List
                                _buildShoppingListTab(activeHouseId, stocks),
                              ],
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentStockTab(int houseId, List<StockWithProduct> stocks) {
    final filtered = _searchQuery.isEmpty
        ? stocks
        : stocks.where((s) => s.product.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: "Search stock...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text("No products in stock"))
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 80.0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final s = filtered[index];
                    final repo = ref.read(stockRepositoryProvider);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () => _showProductOptionsDialog(context, s, houseId),
                                        child: Text(
                                          s.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (s.product.isStockRaw && s.product.edibleQtyPerUnit != null && s.product.edibleQtyPerUnit! < 1.0)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            "≈ ${(s.stock.quantity * s.product.edibleQtyPerUnit!).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '').replaceAll(RegExp(r'([0-9])0$'), r'\1')} ${s.product.units} edible equivalent",
                                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          const Text("Unit: "),
                                          Builder(
                                              builder: (context) {
                                                final currentUnit = (s.product.units).toLowerCase();
                                                String normalizedUnit = (currentUnit == 'unit' || currentUnit == 'units') ? 'units' : currentUnit;
                                                final showMl = s.product.mlToGFactor != null && s.product.mlToGFactor! > 0;
                                                final showUnits = s.product.unitWeight != null && s.product.unitWeight! > 0;
                                                if (normalizedUnit == 'ml' && !showMl) normalizedUnit = 'g';
                                                if (normalizedUnit == 'units' && !showUnits) normalizedUnit = 'g';
 
                                                return DropdownButton<String>(
                                                  value: normalizedUnit,
                                                  isDense: true,
                                                  underline: const SizedBox(),
                                                  items: [
                                                    const DropdownMenuItem(value: 'g', child: Text('g')),
                                                    if (showMl)
                                                      const DropdownMenuItem(value: 'ml', child: Text('ml')),
                                                    if (showUnits)
                                                      const DropdownMenuItem(value: 'units', child: Text('units')),
                                                  ],
                                                  onChanged: (newVal) async {
                                                    if (newVal != null) {
                                                      final mealRepo = ref.read(mealRepositoryProvider);
                                                      await mealRepo.saveProduct(s.product.copyWith(defaultUnits: Value(newVal)));
                                                      double targetQty = s.stock.quantity;
                                                      if (newVal == 'g') {
                                                        targetQty = s.stock.quantityGrams;
                                                      } else if (newVal == 'ml') {
                                                        targetQty = s.stock.quantityMl;
                                                      } else if (newVal == 'units') {
                                                        targetQty = s.stock.quantityUnits;
                                                      }
                                                      await repo.saveStock(
                                                        productId: s.product.id,
                                                        houseId: houseId,
                                                        quantity: targetQty,
                                                        minTriggerQuantity: s.stock.minTriggerQuantity,
                                                        inputUnit: newVal,
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                StockQuantityEditor(
                                  quantity: s.stock.quantity,
                                  unit: s.product.units,
                                  onSave: (next) {
                                    repo.saveStock(
                                      productId: s.product.id,
                                      houseId: houseId,
                                      quantity: next,
                                      minTriggerQuantity: s.stock.minTriggerQuantity,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  s.stock.minTriggerQuantity == null
                                      ? "No minimum"
                                      : "Minimum: ${s.stock.minTriggerQuantity!.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '').replaceAll(RegExp(r'([0-9])0$'), r'\1')} ${s.product.units}",
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () {
                                    final controller = TextEditingController(text: s.stock.minTriggerQuantity?.toString() ?? "");
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Set Trigger for ${s.product.name}"),
                                        content: TextField(
                                          controller: controller,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          decoration: InputDecoration(
                                            labelText: "Minimum Threshold (${s.product.units})",
                                            helperText: "Leave empty to disable trigger",
                                          ),
                                          autofocus: true,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final val = double.tryParse(controller.text.trim());
                                              await repo.saveStock(
                                                productId: s.product.id,
                                                houseId: houseId,
                                                quantity: s.stock.quantity,
                                                minTriggerQuantity: val,
                                              );
                                              if (context.mounted) Navigator.pop(context);
                                            },
                                            child: const Text("Save"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShoppingListTab(int houseId, List<StockWithProduct> stocks) {
    final needed = stocks.where((s) => s.stock.minTriggerQuantity != null && s.stock.quantity < s.stock.minTriggerQuantity!).toList();

    if (needed.isEmpty) {
      return const Center(child: Text("No items need restocking"));
    }

    // Self-initialize helper states for shopping list
    for (final s in needed) {
      if (!_shoppingListInitialized.contains(s.product.id)) {
        _shoppingListInitialized.add(s.product.id);
        // Don't check by default — user must opt-in
        final double gap = s.stock.minTriggerQuantity! - s.stock.quantity;
        _shoppingQuantities[s.product.id] = double.parse((gap < 0.0 ? 0.0 : gap).toStringAsFixed(2));
        _shoppingUnits[s.product.id] = s.product.units;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: needed.length,
      itemBuilder: (context, index) {
        final s = needed[index];
        final checked = _shoppingChecked.contains(s.product.id);

        return Card(
          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.2)),
          ),
          child: ListTile(
            leading: Checkbox(
              value: checked,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _shoppingChecked.add(s.product.id);
                  } else {
                    _shoppingChecked.remove(s.product.id);
                  }
                });
              },
            ),
            title: Text(
              s.product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Stock: ${s.stock.quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '').replaceAll(RegExp(r'([0-9])0$'), r'\1')}"
              "${s.product.isStockRaw && s.product.edibleQtyPerUnit != null && s.product.edibleQtyPerUnit! < 1.0 ? ' (≈ ${(s.stock.quantity * s.product.edibleQtyPerUnit!).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '').replaceAll(RegExp(r'([0-9])0$'), r'\1')} edible)' : ''}"
              " / Minimum: ${s.stock.minTriggerQuantity!.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '').replaceAll(RegExp(r'([0-9])0$'), r'\1')} ${s.product.units}",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    initialValue: _shoppingQuantities[s.product.id]?.toString() ?? "",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0.0;
                      _shoppingQuantities[s.product.id] = parsed;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Builder(
                  builder: (context) {
                    final currentUnit = _shoppingUnits[s.product.id] ?? s.product.units;
                    final showMl = s.product.mlToGFactor != null && s.product.mlToGFactor! > 0;
                    final showUnits = s.product.unitWeight != null && s.product.unitWeight! > 0;
                    
                    return DropdownButton<String>(
                      value: currentUnit,
                      isDense: true,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(value: 'g', child: Text('g')),
                        if (showMl)
                          const DropdownMenuItem(value: 'ml', child: Text('ml')),
                        if (showUnits)
                          const DropdownMenuItem(value: 'units', child: Text('units')),
                      ],
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setState(() {
                            _shoppingUnits[s.product.id] = newVal;
                          });
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductOptionsDialog(BuildContext context, StockWithProduct s, int houseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Options for ${s.product.name}"),
        content: const Text("What would you like to do with this stock item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showReplaceProductSelector(s, houseId);
            },
            child: const Text("Replace"),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(stockRepositoryProvider);
              await repo.deleteStock(s.stock);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showReplaceProductSelector(StockWithProduct oldStock, int houseId) {
    final products = ref.read(allProductsProvider).value ?? [];
    String query = "";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filtered = query.isEmpty ? products : products.searchAndSort(query);
          return AlertDialog(
            title: const Text("Replace with..."),
            content: SizedBox(
              width: 400,
              height: 350,
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Search database...",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      setDialogState(() {
                        query = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text("Unit: ${p.units}"),
                          onTap: () async {
                            final repo = ref.read(stockRepositoryProvider);
                            // Delete old stock
                            await repo.deleteStock(oldStock.stock);
                            // Save new stock preserving quantity and trigger
                            await repo.saveStock(
                              productId: p.id,
                              houseId: houseId,
                              quantity: oldStock.stock.quantity,
                              minTriggerQuantity: oldStock.stock.minTriggerQuantity,
                              inputUnit: oldStock.product.units,
                            );
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReceiptConfirmItem {
  final String receiptName;
  double inputQuantity;
  String parsedUnit;
  Product? matchedProduct;
  int matchState; // 0 = Perfect, 1 = Fuzzy, 2 = Not Found
  bool isSelected;

  _ReceiptConfirmItem({
    required this.receiptName,
    required this.inputQuantity,
    required this.parsedUnit,
    this.matchedProduct,
    required this.matchState,
    required this.isSelected,
  });
}

class StockQuantityEditor extends StatefulWidget {
  final double quantity;
  final String unit;
  final void Function(double) onSave;

  const StockQuantityEditor({
    super.key,
    required this.quantity,
    required this.unit,
    required this.onSave,
  });

  @override
  State<StockQuantityEditor> createState() => _StockQuantityEditorState();
}

class _StockQuantityEditorState extends State<StockQuantityEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatQuantity(widget.quantity));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant StockQuantityEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity && !_focusNode.hasFocus) {
      _controller.text = _formatQuantity(widget.quantity);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  double get _stepSize {
    final u = widget.unit.toLowerCase();
    if (u == 'g' || u == 'kg') {
      return 250.0;
    } else if (u == 'ml' || u == 'l') {
      return 200.0;
    } else {
      return 5.0; // units
    }
  }

  String _formatQuantity(double val) {
    if (val == val.toInt().toDouble()) {
      return val.toInt().toString();
    }
    return val.toString();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _saveValue();
    }
  }

  void _saveValue() {
    final text = _controller.text.trim();
    final double? parsed = double.tryParse(text);
    if (parsed != null && parsed >= 0.0) {
      widget.onSave(parsed);
    } else {
      _controller.text = _formatQuantity(widget.quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            final double current = double.tryParse(_controller.text) ?? widget.quantity;
            final double next = (current - _stepSize).clamp(0, double.infinity);
            _controller.text = _formatQuantity(next);
            widget.onSave(next);
          },
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 60,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (_) => _saveValue(),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.add, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            final double current = double.tryParse(_controller.text) ?? widget.quantity;
            final double next = current + _stepSize;
            _controller.text = _formatQuantity(next);
            widget.onSave(next);
          },
        ),
      ],
    );
  }
}
