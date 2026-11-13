/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/db/app_database.dart';
import '../../core/db/stock_repository.dart';
import '../../core/db/meal_repository.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/integrations/ai_service.dart';
import '../../core/components/clearable_search_field.dart';
import '../../core/components/nexc_scaffold.dart';
import '../meals/product_selector_screen.dart';
import '../meals/edit_product_screen.dart';
import 'package:image_picker/image_picker.dart';

// Providers for Stock Screen State
final activeHouseIdProvider = StateProvider<int?>((ref) => null);

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";
  final TextEditingController _stockSearchController = TextEditingController();
  bool _isImporting = false;

  final Set<int> _shoppingChecked = {};
  final Set<int> _shoppingListInitialized = {};
  final Map<int, double> _shoppingQuantities = {};
  final Map<int, String> _shoppingUnits = {};

  String _formatDouble(double val) {
    final str = val.toStringAsFixed(2);
    if (str.endsWith('.00')) {
      return str.substring(0, str.length - 3);
    }
    if (str.endsWith('0')) {
      return str.substring(0, str.length - 1);
    }
    return str;
  }

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
    _stockSearchController.dispose();
    super.dispose();
  }

  void _showAddHouseDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.addHouse),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: context.l10n.houseName),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
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
            child: Text(context.l10n.save),
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
        title: Text(context.l10n.renameHouse),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: context.l10n.houseName),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
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
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteHouseDialog(House house) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteHouse),
        content: Text(context.l10n.deleteHouseConfirm(house.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(stockRepositoryProvider);
              await repo.deleteHouse(house);
              final remaining = await repo.getHouses();
              ref.read(activeHouseIdProvider.notifier).state =
                  remaining.isNotEmpty ? remaining.first.id : null;
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductToStockDialog(int houseId, List<Product> products) async {
    final selectedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductSelectorScreen(title: context.l10n.addProductToStockTitle),
      ),
    );

    if (selectedProduct != null) {
      final repo = ref.read(stockRepositoryProvider);
      await repo.saveStock(
        productId: selectedProduct.id,
        houseId: houseId,
        quantity: 0.0,
        minTriggerQuantity: null,
      );
    }
  }

  void _showReplaceProductDialog(
    BuildContext context,
    _ReceiptConfirmItem item,
    List<Product> products,
    void Function(void Function()) setDialogState,
  ) async {
    final selectedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSelectorScreen(
          title: context.l10n.mapToTitle(item.receiptName),
          initialQuery: item.receiptName,
        ),
      ),
    );

    if (selectedProduct != null) {
      final stockRepo = ref.read(stockRepositoryProvider);
      await stockRepo.saveReceiptMapping(
        receiptName: item.receiptName,
        productId: selectedProduct.id,
      );
      setDialogState(() {
        item.matchedProduct = selectedProduct;
        item.matchState = 0; // mapped
      });
    }
  }

  void _showManageHousesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final repo = ref.read(stockRepositoryProvider);
        return AlertDialog(
          title: Text(context.l10n.manageHouses),
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
                          ? Center(child: Text(context.l10n.noHousesDefined))
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
                                        onPressed: () =>
                                            _showRenameHouseDialog(h),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _showDeleteHouseDialog(h),
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
                      label: Text(context.l10n.addHouse),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
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
            Text(context.l10n.operationError),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    error,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(context.l10n.copyError),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: error));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(context.l10n.errorCopied)));
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReceiptImport(int houseId, List<Product> products) async {
    final l10n = context.l10n;
    final settings = ref.read(settingsProvider);
    if (settings.aiToken.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.aiTokenNotConfigured)));
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(ctx.l10n.takePhotoCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(ctx.l10n.chooseFromGallery),
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
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final extension = pickedFile.name.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

      final parsedItems = await AIService.parseReceipt(
        provider: settings.aiProvider,
        apiKey: settings.aiToken,
        model: settings.aiModel,
        imageBase64: base64Image,
        mimeType: mimeType,
      );

      if (parsedItems.isEmpty) {
        throw Exception(l10n.noItemsParsed);
      }

      final repo = ref.read(stockRepositoryProvider);
      final mappings = await repo.getReceiptMappings();

      // Multi-stage matching: identify unmapped items and collect close candidate products
      final usageCounts = ref.read(productUsageCountsProvider).value;
      final inStockProductIds = ref.read(inStockProductIdsProvider).value;

      final itemsWithCandidates = <Map<String, dynamic>>[];
      for (final parsed in parsedItems) {
        final hasExactMapping = mappings.any(
          (m) =>
              m.receiptName.toLowerCase() == parsed.name.toLowerCase().trim(),
        );
        if (!hasExactMapping) {
          final candidates = products
              .searchAndSort(
                parsed.name,
                usageCounts: usageCounts,
                inStockProductIds: inStockProductIds,
              )
              .take(5)
              .map((p) => {"id": p.id, "name": p.name})
              .toList();

          if (candidates.isNotEmpty) {
            itemsWithCandidates.add({
              "receiptName": parsed.name,
              "candidates": candidates,
            });
          }
        }
      }

      Map<String, int?> aiDisambiguated = {};
      if (itemsWithCandidates.isNotEmpty &&
          settings.aiToken.trim().isNotEmpty) {
        try {
          aiDisambiguated = await AIService.disambiguateReceiptItems(
            provider: settings.aiProvider,
            apiKey: settings.aiToken,
            model: settings.aiModel,
            itemsWithCandidates: itemsWithCandidates,
          );
        } catch (_) {}
      }

      if (mounted) {
        _showConfirmationDialog(
          houseId,
          parsedItems,
          products,
          mappings,
          aiDisambiguated,
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        _showCopyableErrorDialog(l10n.receiptImportError, "$e\n\n$stackTrace");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  void _showConfirmationDialog(
    int houseId,
    List<AIReceiptItem> parsedItems,
    List<Product> products,
    List<ReceiptMapping> mappings,
    Map<String, int?> aiDisambiguated,
  ) {
    final l10n = context.l10n;
    final usageCounts = ref.read(productUsageCountsProvider).value;
    final inStockProductIds = ref.read(inStockProductIdsProvider).value;
    final resolvedList = parsedItems.map((parsed) {
      Product? matchedProduct;
      int matchState = 2; // Default: 🔴 Not Found

      final mapping = mappings.firstWhereOrNull(
        (m) => m.receiptName.toLowerCase() == parsed.name.toLowerCase().trim(),
      );
      if (mapping != null) {
        matchedProduct = products.firstWhereOrNull(
          (p) => p.id == mapping.productId,
        );
        if (matchedProduct != null) {
          matchState = 0; // 🟢 Perfect Match
        }
      }

      if (matchedProduct == null && aiDisambiguated.isNotEmpty) {
        final disambiguatedId =
            aiDisambiguated[parsed.name.toLowerCase().trim()];
        if (disambiguatedId != null) {
          final found = products.firstWhereOrNull(
            (p) => p.id == disambiguatedId,
          );
          if (found != null) {
            matchedProduct = found;
            matchState = 0; // 🟢 AI Disambiguated Match
          }
        }
      }

      if (matchedProduct == null) {
        final matches = products.searchAndSort(
          parsed.name,
          usageCounts: usageCounts,
          inStockProductIds: inStockProductIds,
        );
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
                title: Text(context.l10n.aiLogConfirmation),
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
                        String matchText = context.l10n.notFound;
                        IconData icon = Icons.cancel;

                        if (item.matchState == 0) {
                          stateColor = Colors.green;
                          matchText = context.l10n.perfectMatch;
                          icon = Icons.check_circle;
                        } else if (item.matchState == 1) {
                          stateColor = Colors.orange;
                          matchText = context.l10n.fuzzyMatch;
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.receiptName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                icon,
                                                color: stateColor,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                matchText,
                                                style: TextStyle(
                                                  color: stateColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (item.matchedProduct !=
                                                  null) ...[
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    "→ ${item.matchedProduct!.name}",
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: TextFormField(
                                              initialValue:
                                                  item.inputQuantity % 1 == 0
                                                  ? item.inputQuantity
                                                        .toInt()
                                                        .toString()
                                                  : item.inputQuantity
                                                        .toString(),
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              decoration: InputDecoration(
                                                labelText:
                                                    context.l10n.quantityLabel,
                                                isDense: true,
                                                border: OutlineInputBorder(),
                                              ),
                                              onChanged: (val) {
                                                item.inputQuantity =
                                                    double.tryParse(val) ?? 0.0;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Builder(
                                            builder: (context) {
                                              final p = item.matchedProduct;
                                              final availableUnits = p != null
                                                  ? p.availableStringUnits
                                                  : <String>[
                                                      'g',
                                                      'kg',
                                                      'ml',
                                                      'l',
                                                      'units',
                                                    ];

                                              String selectedUnit = item
                                                  .parsedUnit
                                                  .toLowerCase();
                                              if (!availableUnits.contains(
                                                selectedUnit,
                                              )) {
                                                selectedUnit =
                                                    availableUnits.first;
                                                item.parsedUnit = selectedUnit;
                                              }

                                              return SizedBox(
                                                width: 100,
                                                child:
                                                    DropdownButtonFormField<
                                                      String
                                                    >(
                                                      initialValue:
                                                          selectedUnit,
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            l10n.unitLabel,
                                                        isDense: true,
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                      items: availableUnits
                                                          .map(
                                                            (u) =>
                                                                DropdownMenuItem(
                                                                  value: u,
                                                                  child: Text(
                                                                    u,
                                                                  ),
                                                                ),
                                                          )
                                                          .toList(),
                                                      onChanged: (val) {
                                                        if (val != null) {
                                                          setDialogState(() {
                                                            item.parsedUnit =
                                                                val;
                                                          });
                                                        }
                                                      },
                                                    ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (item.matchedProduct != null) ...[
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 16,
                                            ),
                                            tooltip: context.l10n.editProduct,
                                            onPressed: () async {
                                              final updatedProd = await Navigator.push<Product>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (ctx) => EditProductScreen(
                                                    product:
                                                        item.matchedProduct!,
                                                    onConfirm: (prod) async {
                                                      try {
                                                        final repo = ref.read(
                                                          mealRepositoryProvider,
                                                        );
                                                        await repo.saveProduct(
                                                          prod,
                                                        );
                                                      } catch (e, st) {
                                                        _showCopyableErrorDialog(
                                                          l10n.productEditError,
                                                          "$e\n\n$st",
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              );
                                              if (updatedProd != null) {
                                                setDialogState(() {
                                                  item.matchedProduct =
                                                      updatedProd;
                                                });
                                              }
                                            },
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          const SizedBox(width: 2),
                                        ],
                                        TextButton.icon(
                                          icon: const Icon(
                                            Icons.swap_horiz,
                                            size: 14,
                                          ),
                                          label: Text(
                                            context.l10n.replaceAction,
                                          ),
                                          onPressed: () {
                                            _showReplaceProductDialog(
                                              context,
                                              item,
                                              products,
                                              setDialogState,
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                        if (item.matchedProduct == null) ...[
                                          const SizedBox(width: 4),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              Product? createdProd;
                                              final newProd = await Navigator.push<Product>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (ctx) => EditProductScreen(
                                                    product: Product(
                                                      id: 0,
                                                      name: item.receiptName,
                                                      defaultUnits:
                                                          item.parsedUnit
                                                                      .toLowerCase() ==
                                                                  'l' ||
                                                              item.parsedUnit
                                                                      .toLowerCase() ==
                                                                  'ml'
                                                          ? 'ml'
                                                          : 'g',
                                                      edibleQtyPerUnit: 1.0,
                                                      proteins: 0.0,
                                                      carbsAvailable: null,
                                                      fats: 0.0,
                                                      isSupplement: false,
                                                      isPortable: true,
                                                      isStockRaw: false,
                                                    ),
                                                    onConfirm: (prod) async {
                                                      try {
                                                        final repo = ref.read(
                                                          mealRepositoryProvider,
                                                        );
                                                        final newId = await repo
                                                            .saveProduct(prod);
                                                        final freshProducts =
                                                            ref
                                                                .read(
                                                                  allProductsProvider,
                                                                )
                                                                .value ??
                                                            [];
                                                        createdProd =
                                                            freshProducts
                                                                .firstWhereOrNull(
                                                                  (p) =>
                                                                      p.id ==
                                                                      newId,
                                                                ) ??
                                                            prod.copyWith(
                                                              id: newId,
                                                            );
                                                        if (createdProd !=
                                                            null) {
                                                          final stockRepo = ref
                                                              .read(
                                                                stockRepositoryProvider,
                                                              );
                                                          await stockRepo
                                                              .saveReceiptMapping(
                                                                receiptName: item
                                                                    .receiptName,
                                                                productId:
                                                                    createdProd!
                                                                        .id,
                                                              );
                                                        }
                                                      } catch (e, st) {
                                                        _showCopyableErrorDialog(
                                                          l10n.productCreationError,
                                                          "$e\n\n$st",
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              );
                                              final finalProduct =
                                                  createdProd ?? newProd;
                                              if (finalProduct != null) {
                                                setDialogState(() {
                                                  item.matchedProduct =
                                                      finalProduct;
                                                  item.matchState = 0;
                                                });
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.add,
                                              size: 14,
                                            ),
                                            label: Text(
                                              context.l10n.createAction,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
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
                          child: Text(context.l10n.cancel),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final repo = ref.read(stockRepositoryProvider);
                              final currentStocks = await repo
                                  .getStocksWithProductForHouse(houseId);

                              for (final item in resolvedList) {
                                if (item.isSelected &&
                                    item.matchedProduct != null &&
                                    item.inputQuantity > 0.0) {
                                  double qty = item.inputQuantity;
                                  if (item.parsedUnit.toLowerCase() == 'kg' ||
                                      item.parsedUnit.toLowerCase() == 'l') {
                                    qty *= 1000;
                                  }
                                  final existing = currentStocks
                                      .firstWhereOrNull(
                                        (s) =>
                                            s.product.id ==
                                            item.matchedProduct!.id,
                                      );
                                  final double finalQty =
                                      (existing?.stock.quantity ?? 0.0) + qty;
                                  await repo.saveStock(
                                    productId: item.matchedProduct!.id,
                                    houseId: houseId,
                                    quantity: finalQty,
                                    minTriggerQuantity:
                                        existing?.stock.minTriggerQuantity,
                                  );
                                }
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.loggedReceiptItems),
                                  ),
                                );
                              }
                            } catch (e, st) {
                              _showCopyableErrorDialog(
                                l10n.stockLoggingError,
                                "$e\n\n$st",
                              );
                            }
                          },
                          child: Text(context.l10n.confirmAction),
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
          title: Text(context.l10n.stockTitle),
          navigateBack: () => Navigator.pop(context),
          actions: const [],
          actionsIcons: const [],
          fabAction: activeHouseId != null
              ? () async {
                  if (_tabController.index == 0) {
                    _showAddProductToStockDialog(activeHouseId, products);
                  } else {
                    final needed =
                        (await repo.getStocksWithProductForHouse(activeHouseId))
                            .where(
                              (s) =>
                                  s.stock.minTriggerQuantity != null &&
                                  s.stock.quantity <
                                      s.stock.minTriggerQuantity!,
                            )
                            .toList();
                    int restockedCount = 0;
                    for (final s in needed) {
                      if (_shoppingChecked.contains(s.product.id)) {
                        final addedQty =
                            _shoppingQuantities[s.product.id] ?? 0.0;
                        if (addedQty > 0.0) {
                          final chosenUnit =
                              _shoppingUnits[s.product.id] ?? s.product.units;
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
                    final updatedStocks = await repo
                        .getStocksWithProductForHouse(activeHouseId);
                    final fulfilledIds = <int>{};
                    for (final us in updatedStocks) {
                      if (us.stock.minTriggerQuantity != null &&
                          us.stock.quantity > us.stock.minTriggerQuantity!) {
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
                        SnackBar(
                          content: Text(
                            context.l10n.restockedItems(restockedCount),
                          ),
                        ),
                      );
                    }
                  }
                }
              : null,
          fabIcon: _tabController.index == 0
              ? const Icon(Icons.add)
              : const Icon(Icons.check),
          fabText: _tabController.index == 0
              ? context.l10n.addStock
              : context.l10n.restockItems,
          content: (context, padding) {
            if (houses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // House Selection Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        context.l10n.housePrefix,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: activeHouseId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            ...houses.map((h) {
                              return DropdownMenuItem(
                                value: h.id,
                                child: Text(h.name),
                              );
                            }),
                            DropdownMenuItem<int>(
                              value: -999,
                              child: Text(context.l10n.manageHouses),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == -999) {
                              setState(() {});
                              _showManageHousesDialog();
                            } else if (val != null) {
                              ref.read(activeHouseIdProvider.notifier).state =
                                  val;
                            }
                          },
                        ),
                      ),
                      if (settings.enableAiStockLogging &&
                          activeHouseId != null) ...[
                        const SizedBox(width: 8),
                        _isImporting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : IconButton.filledTonal(
                                icon: const Icon(Icons.receipt_long_outlined),
                                tooltip: context.l10n.aiImportReceipt,
                                onPressed: () => _handleReceiptImport(
                                  activeHouseId,
                                  products,
                                ),
                              ),
                      ],
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: context.l10n.currentStockTab),
                    Tab(text: context.l10n.shoppingListTab),
                  ],
                ),
                Expanded(
                  child: activeHouseId == null
                      ? Center(child: Text(context.l10n.selectOrAddHouse))
                      : StreamBuilder<List<StockWithProduct>>(
                          stream: repo.watchStocksWithProductForHouse(
                            activeHouseId,
                          ),
                          builder: (context, stockSnap) {
                            final stocks = stockSnap.data ?? [];

                            return TabBarView(
                              controller: _tabController,
                              children: [
                                // Tab 1: Current Stock
                                _buildCurrentStockTab(
                                  context,
                                  activeHouseId,
                                  stocks,
                                ),
                                // Tab 2: Shopping List
                                _buildShoppingListTab(
                                  context,
                                  activeHouseId,
                                  stocks,
                                ),
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

  Widget _buildCurrentStockTab(
    BuildContext context,
    int houseId,
    List<StockWithProduct> stocks,
  ) {
    final l10n = context.l10n;
    final filtered = _searchQuery.isEmpty
        ? stocks
        : stocks
              .where(
                (s) => s.product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClearableSearchField(
            controller: _stockSearchController,
            labelText: context.l10n.searchStock,
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(l10n.noProductsInStock))
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 80.0,
                  ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () => _showProductOptionsDialog(
                                          context,
                                          s,
                                          houseId,
                                        ),
                                        child: Text(
                                          s.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (s.product.isStockRaw &&
                                          s.product.edibleQtyPerUnit != null &&
                                          s.product.edibleQtyPerUnit! < 1.0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Text(
                                            l10n.edibleEquivalentValue(
                                              _formatDouble(
                                                s.stock.quantity *
                                                    s.product.edibleQtyPerUnit!,
                                              ),
                                              s.product.units,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          Text(l10n.unitPrefix),
                                          Builder(
                                            builder: (context) {
                                              final currentUnit =
                                                  (s.product.units)
                                                      .toLowerCase();
                                              String normalizedUnit =
                                                  (currentUnit == 'unit' ||
                                                      currentUnit == 'units')
                                                  ? 'units'
                                                  : currentUnit;
                                              final showMl =
                                                  s.product.canMeasureInMl;
                                              final showUnits =
                                                  s.product.canMeasureInUnits;
                                              if (normalizedUnit == 'ml' &&
                                                  !showMl) {
                                                normalizedUnit = 'g';
                                              }
                                              if (normalizedUnit == 'units' &&
                                                  !showUnits) {
                                                normalizedUnit = 'g';
                                              }

                                              return DropdownButton<String>(
                                                value: normalizedUnit,
                                                isDense: true,
                                                underline: const SizedBox(),
                                                items: [
                                                  const DropdownMenuItem(
                                                    value: 'g',
                                                    child: Text('g'),
                                                  ),
                                                  if (showMl)
                                                    const DropdownMenuItem(
                                                      value: 'ml',
                                                      child: Text('ml'),
                                                    ),
                                                  if (showUnits)
                                                    const DropdownMenuItem(
                                                      value: 'units',
                                                      child: Text('units'),
                                                    ),
                                                ],
                                                onChanged: (newVal) async {
                                                  if (newVal != null) {
                                                    final mealRepo = ref.read(
                                                      mealRepositoryProvider,
                                                    );
                                                    await mealRepo.saveProduct(
                                                      s.product.copyWith(
                                                        defaultUnits: Value(
                                                          newVal,
                                                        ),
                                                      ),
                                                    );
                                                    double targetQty =
                                                        s.stock.quantity;
                                                    if (newVal == 'g') {
                                                      targetQty =
                                                          s.stock.quantityGrams;
                                                    } else if (newVal == 'ml') {
                                                      targetQty =
                                                          s.stock.quantityMl;
                                                    } else if (newVal ==
                                                        'units') {
                                                      targetQty =
                                                          s.stock.quantityUnits;
                                                    }
                                                    await repo.saveStock(
                                                      productId: s.product.id,
                                                      houseId: houseId,
                                                      quantity: targetQty,
                                                      minTriggerQuantity: s
                                                          .stock
                                                          .minTriggerQuantity,
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
                                      minTriggerQuantity:
                                          s.stock.minTriggerQuantity,
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
                                      ? l10n.noMinimum
                                      : l10n.minimumWithValue(
                                          _formatDouble(
                                            s.stock.minTriggerQuantity!,
                                          ),
                                          s.product.units,
                                        ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () {
                                    final controller = TextEditingController(
                                      text: s.stock.minTriggerQuantity != null
                                          ? _formatDouble(
                                              s.stock.minTriggerQuantity!,
                                            )
                                          : "",
                                    );
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          l10n.setTriggerFor(s.product.name),
                                        ),
                                        content: TextField(
                                          controller: controller,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: InputDecoration(
                                            labelText: l10n
                                                .minimumThresholdWithUnit(
                                                  s.product.units,
                                                ),
                                            helperText:
                                                l10n.leaveEmptyToDisableTrigger,
                                          ),
                                          autofocus: true,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(context.l10n.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              String raw = controller.text
                                                  .trim()
                                                  .replaceAll(',', '.');
                                              raw = raw
                                                  .replaceAll(
                                                    RegExp(r'[a-zA-Z]+$'),
                                                    '',
                                                  )
                                                  .trim();
                                              final val = double.tryParse(raw);
                                              await repo.saveStock(
                                                productId: s.product.id,
                                                houseId: houseId,
                                                quantity: s.stock.quantity,
                                                minTriggerQuantity: val,
                                                inputUnit: s.product.units,
                                              );
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text(context.l10n.save),
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

  Widget _buildShoppingListTab(
    BuildContext context,
    int houseId,
    List<StockWithProduct> stocks,
  ) {
    final l10n = context.l10n;
    final needed = stocks
        .where(
          (s) =>
              s.stock.minTriggerQuantity != null &&
              s.stock.quantity < s.stock.minTriggerQuantity!,
        )
        .toList();

    if (needed.isEmpty) {
      return Center(child: Text(l10n.noItemsNeedRestocking));
    }

    // Self-initialize helper states for shopping list
    for (final s in needed) {
      if (!_shoppingListInitialized.contains(s.product.id)) {
        _shoppingListInitialized.add(s.product.id);
        // Don't check by default — user must opt-in
        final double gap = s.stock.minTriggerQuantity! - s.stock.quantity;
        _shoppingQuantities[s.product.id] = double.parse(
          (gap < 0.0 ? 0.0 : gap).toStringAsFixed(2),
        );
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
          color: Theme.of(
            context,
          ).colorScheme.errorContainer.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
            ),
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
              l10n.stockWithValue(_formatDouble(s.stock.quantity)) +
                  (s.product.isStockRaw &&
                          s.product.edibleQtyPerUnit != null &&
                          s.product.edibleQtyPerUnit! < 1.0
                      ? l10n.stockEdibleSuffix(
                          _formatDouble(
                            s.stock.quantity * s.product.edibleQtyPerUnit!,
                          ),
                        )
                      : '') +
                  (s.stock.minTriggerQuantity == null
                      ? ''
                      : l10n.minimumSuffix(
                          _formatDouble(s.stock.minTriggerQuantity!),
                          s.product.units,
                        )),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    initialValue:
                        _shoppingQuantities[s.product.id]?.toString() ?? "",
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                    final currentUnit =
                        _shoppingUnits[s.product.id] ?? s.product.units;
                    final showMl = s.product.canMeasureInMl;
                    final showUnits = s.product.canMeasureInUnits;

                    return DropdownButton<String>(
                      value: currentUnit,
                      isDense: true,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(value: 'g', child: Text('g')),
                        if (showMl)
                          const DropdownMenuItem(
                            value: 'ml',
                            child: Text('ml'),
                          ),
                        if (showUnits)
                          const DropdownMenuItem(
                            value: 'units',
                            child: Text('units'),
                          ),
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

  void _showProductOptionsDialog(
    BuildContext context,
    StockWithProduct s,
    int houseId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.optionsForItem(s.product.name)),
        content: Text(context.l10n.whatToDoWithItem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showReplaceProductSelector(s, houseId);
            },
            child: Text(context.l10n.replaceAction),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(stockRepositoryProvider);
              await repo.deleteStock(s.stock);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReplaceProductSelector(
    StockWithProduct oldStock,
    int houseId,
  ) async {
    final selectedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductSelectorScreen(title: context.l10n.replaceWith),
      ),
    );

    if (selectedProduct == null || !mounted) return;

    final repo = ref.read(stockRepositoryProvider);
    // Delete old stock
    await repo.deleteStock(oldStock.stock);
    // Save new stock preserving quantity and trigger
    await repo.saveStock(
      productId: selectedProduct.id,
      houseId: houseId,
      quantity: oldStock.stock.quantity,
      minTriggerQuantity: oldStock.stock.minTriggerQuantity,
      inputUnit: oldStock.product.units,
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
            final double current =
                double.tryParse(_controller.text) ?? widget.quantity;
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
            final double current =
                double.tryParse(_controller.text) ?? widget.quantity;
            final double next = current + _stepSize;
            _controller.text = _formatQuantity(next);
            widget.onSave(next);
          },
        ),
      ],
    );
  }
}
