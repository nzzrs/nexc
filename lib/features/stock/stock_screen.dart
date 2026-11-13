/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The LibreFit Contributors
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/components/clearable_search_field.dart';
import '../../core/components/nexc_async_view.dart';
import '../../core/components/nexc_choice_sheet.dart';
import '../../core/components/nexc_empty_state.dart';
import '../../core/components/nexc_page.dart';
import '../../core/components/nexc_section.dart';
import '../../core/components/nexc_snack.dart';
import '../../core/components/nexc_stepper_field.dart';
import '../../core/components/nexc_tile.dart';
import '../../core/db/app_database.dart';
import '../../core/db/stock_repository.dart';
import '../../core/integrations/ai_service.dart';
import '../../core/l10n/l10n.dart';
import '../../core/providers/meals_providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/iconography.dart';
import '../../core/theme/spacing.dart';
import '../../core/util/format.dart';
import '../meals/product_selector_screen.dart';
import 'receipt_review_screen.dart';
import 'stock_dialogs.dart';

/// Currently selected house across the stock screen.
final activeHouseIdProvider = StateProvider<int?>((ref) => null);

/// Canonical spelling for stock units (`unit` and `units` are the same unit).
String normalizeStockUnit(String? raw) {
  final String value = raw?.trim().toLowerCase() ?? 'g';
  if (value == 'unit') return 'units';
  if (value == 'ml' || value == 'units') return value;
  return 'g';
}

/// Units a stock row may be displayed in.
List<String> stockDisplayUnits(Product product) {
  return <String>[
    'g',
    if (product.canMeasureInMl) 'ml',
    if (product.canMeasureInUnits) 'units',
  ];
}

/// Whether the stock is below its configured trigger.
bool isLowStock(StockWithProduct item) {
  final double? trigger = item.stock.minTriggerQuantity;
  return trigger != null && item.stock.quantity < trigger;
}

/// Quantity converted to [unit] for display or editing.
double stockQuantityInUnit(StockWithProduct item, String unit) {
  final String normalized = normalizeStockUnit(unit);
  if (normalized == normalizeStockUnit(item.product.units)) {
    return item.stock.quantity;
  }
  switch (normalized) {
    case 'ml':
      return item.stock.quantityMl;
    case 'units':
      return item.stock.quantityUnits;
    default:
      return item.stock.quantityGrams;
  }
}

/// Step size for the quantity stepper, by unit.
double stockStepForUnit(String unit) {
  switch (normalizeStockUnit(unit)) {
    case 'ml':
      return 200.0;
    case 'units':
      return 5.0;
    default:
      return 250.0;
  }
}

/// Low stock first (most urgent first), then everything else by name.
List<StockWithProduct> sortStocksLowStockFirst(
  Iterable<StockWithProduct> stocks,
) {
  final List<StockWithProduct> list = stocks.toList();
  list.sort((StockWithProduct a, StockWithProduct b) {
    final bool aLow = isLowStock(a);
    final bool bLow = isLowStock(b);
    if (aLow != bLow) return aLow ? -1 : 1;
    if (aLow && bLow) {
      final double aRatio = a.stock.quantity / a.stock.minTriggerQuantity!;
      final double bRatio = b.stock.quantity / b.stock.minTriggerQuantity!;
      final int ratioOrder = aRatio.compareTo(bRatio);
      if (ratioOrder != 0) return ratioOrder;
    }
    return a.product.name.toLowerCase().compareTo(b.product.name.toLowerCase());
  });
  return list;
}

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _stockSearchController = TextEditingController();
  String _searchQuery = '';
  bool _isImporting = false;

  /// Per-product display unit; it never writes `product.defaultUnits`.
  final Map<int, String> _displayUnits = <int, String>{};
  final Set<int> _shoppingChecked = <int>{};
  final Map<int, double> _shoppingQuantities = <int, double>{};
  final Map<int, String> _shoppingUnits = <int, String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final StockRepository repo = ref.read(stockRepositoryProvider);
      await repo.ensureDefaultHouse();
      final List<House> houses = await repo.getHouses();
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

  Future<void> _addHouse() async {
    final l10n = context.l10n;
    final String? name = await showHouseNameSheet(
      context,
      title: l10n.addHouse,
    );
    if (name == null) return;
    final StockRepository repo = ref.read(stockRepositoryProvider);
    final int id = await repo.saveHouse(House(id: 0, name: name.trim()));
    if (mounted) ref.read(activeHouseIdProvider.notifier).state = id;
  }

  Future<void> _renameHouse(House house) async {
    final l10n = context.l10n;
    final String? name = await showHouseNameSheet(
      context,
      title: l10n.renameHouse,
      initialValue: house.name,
    );
    if (name == null) return;
    await ref
        .read(stockRepositoryProvider)
        .saveHouse(house.copyWith(name: name.trim()));
  }

  Future<void> _deleteHouse(House house) async {
    if (!await confirmDeleteHouse(context, house)) return;
    if (!mounted) return;
    final StockRepository repo = ref.read(stockRepositoryProvider);
    await repo.deleteHouse(house);
    final List<House> remaining = await repo.getHouses();
    if (mounted) {
      ref.read(activeHouseIdProvider.notifier).state = remaining.isNotEmpty
          ? remaining.first.id
          : null;
    }
  }

  Future<void> _addProductToStock(int houseId) async {
    final Product? selected = await Navigator.push<Product>(
      context,
      NexcPage.route(
        title: context.l10n.addProductToStockTitle,
        builder: (BuildContext context) =>
            ProductSelectorScreen(title: context.l10n.addProductToStockTitle),
      ),
    );
    if (selected == null) return;
    await ref
        .read(stockRepositoryProvider)
        .saveStock(
          productId: selected.id,
          houseId: houseId,
          quantity: 0.0,
          minTriggerQuantity: null,
        );
  }

  Future<void> _replaceStockItem(StockWithProduct item, int houseId) async {
    final Product? selected = await Navigator.push<Product>(
      context,
      NexcPage.route(
        title: context.l10n.replaceWith,
        builder: (BuildContext context) =>
            ProductSelectorScreen(title: context.l10n.replaceWith),
      ),
    );
    if (selected == null) return;
    final StockRepository repo = ref.read(stockRepositoryProvider);
    await repo.deleteStock(item.stock);
    await repo.saveStock(
      productId: selected.id,
      houseId: houseId,
      quantity: item.stock.quantity,
      minTriggerQuantity: item.stock.minTriggerQuantity,
      inputUnit: normalizeStockUnit(item.product.units),
    );
  }

  Future<void> _showItemOptions(StockWithProduct item, int houseId) async {
    final StockItemAction? action = await showStockItemOptionsSheet(
      context,
      item,
    );
    if (!mounted || action == null) return;
    switch (action) {
      case StockItemAction.replace:
        await _replaceStockItem(item, houseId);
      case StockItemAction.delete:
        if (!await confirmDeleteStock(context, item)) return;
        if (!mounted) return;
        await ref.read(stockRepositoryProvider).deleteStock(item.stock);
    }
  }

  Future<void> _editTrigger(StockWithProduct item, int houseId) async {
    final TriggerThresholdResult? result = await showTriggerThresholdSheet(
      context,
      item: item,
    );
    if (result == null || !result.saved || !mounted) return;
    await ref
        .read(stockRepositoryProvider)
        .saveStock(
          productId: item.product.id,
          houseId: houseId,
          quantity: item.stock.quantity,
          minTriggerQuantity: result.value,
          inputUnit: normalizeStockUnit(item.product.units),
        );
  }

  Future<void> _saveQuantity(
    StockWithProduct item,
    int houseId,
    String unit,
    double quantity,
  ) {
    return ref
        .read(stockRepositoryProvider)
        .saveStock(
          productId: item.product.id,
          houseId: houseId,
          quantity: quantity,
          minTriggerQuantity: item.stock.minTriggerQuantity,
          inputUnit: unit,
        );
  }

  Future<void> _restock(int houseId) async {
    final l10n = context.l10n;
    final StockRepository repo = ref.read(stockRepositoryProvider);
    final List<StockWithProduct> stocks = await repo
        .getStocksWithProductForHouse(houseId);
    final List<StockWithProduct> needed = stocks.where(isLowStock).toList();

    int restockedCount = 0;
    for (final StockWithProduct item in needed) {
      if (!_shoppingChecked.contains(item.product.id)) continue;
      final String unit =
          _shoppingUnits[item.product.id] ??
          normalizeStockUnit(item.product.units);
      final double gap = item.stock.minTriggerQuantity! - item.stock.quantity;
      final double addedQuantity =
          _shoppingQuantities[item.product.id] ?? (gap > 0 ? gap : 0.0);
      if (addedQuantity <= 0.0) continue;
      await repo.saveStock(
        productId: item.product.id,
        houseId: houseId,
        quantity: stockQuantityInUnit(item, unit) + addedQuantity,
        minTriggerQuantity: item.stock.minTriggerQuantity,
        inputUnit: unit,
      );
      restockedCount++;
    }

    if (!mounted) return;
    setState(() {
      _shoppingChecked.clear();
      _shoppingQuantities.clear();
      _shoppingUnits.clear();
    });
    if (restockedCount > 0) {
      NexcSnack.show(context, l10n.restockedItems(restockedCount));
    }
  }

  Future<void> _handleReceiptImport(int houseId) async {
    final l10n = context.l10n;
    final SettingsState settings = ref.read(settingsProvider);
    if (settings.aiToken.trim().isEmpty) {
      NexcSnack.show(context, l10n.aiTokenNotConfigured);
      return;
    }

    final ImageSource? source = await NexcChoiceSheet.show<ImageSource>(
      context: context,
      title: l10n.aiImportReceipt,
      options: <NexcChoiceOption<ImageSource>>[
        NexcChoiceOption(
          value: ImageSource.camera,
          label: l10n.takePhotoCamera,
          icon: NexcIcons.add,
        ),
        NexcChoiceOption(
          value: ImageSource.gallery,
          label: l10n.chooseFromGallery,
          icon: NexcIcons.images,
        ),
      ],
    );
    if (source == null || !mounted) return;

    final XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null || !mounted) return;
    setState(() => _isImporting = true);

    try {
      final List<Product> products = ref.read(allProductsProvider).value ?? [];
      final List<int> bytes = await pickedFile.readAsBytes();
      final String base64Image = base64Encode(bytes);
      final String extension = pickedFile.name.split('.').last.toLowerCase();
      final String mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

      final List<AIReceiptItem> parsedItems = await AIService.parseReceipt(
        provider: settings.aiProvider,
        apiKey: settings.aiToken,
        model: settings.aiModel,
        imageBase64: base64Image,
        mimeType: mimeType,
      );
      if (parsedItems.isEmpty) throw Exception(l10n.noItemsParsed);

      final StockRepository repo = ref.read(stockRepositoryProvider);
      final List<ReceiptMapping> mappings = await repo.getReceiptMappings();
      final Map<int, int>? usageCounts = ref
          .read(productUsageCountsProvider)
          .value;
      final Set<int>? inStockProductIds = ref
          .read(inStockProductIdsProvider)
          .value;

      final List<Map<String, dynamic>> itemsWithCandidates =
          <Map<String, dynamic>>[];
      for (final AIReceiptItem parsed in parsedItems) {
        final bool hasExactMapping = mappings.any(
          (ReceiptMapping mapping) =>
              mapping.receiptName.toLowerCase() ==
              parsed.name.toLowerCase().trim(),
        );
        if (hasExactMapping) continue;
        final List<Map<String, Object>> candidates = products
            .searchAndSort(
              parsed.name,
              usageCounts: usageCounts,
              inStockProductIds: inStockProductIds,
            )
            .take(5)
            .map(
              (Product product) => <String, Object>{
                'id': product.id,
                'name': product.name,
              },
            )
            .toList();
        if (candidates.isNotEmpty) {
          itemsWithCandidates.add(<String, dynamic>{
            'receiptName': parsed.name,
            'candidates': candidates,
          });
        }
      }

      Map<String, int?> aiDisambiguated = <String, int?>{};
      if (itemsWithCandidates.isNotEmpty &&
          settings.aiToken.trim().isNotEmpty) {
        try {
          aiDisambiguated = await AIService.disambiguateReceiptItems(
            provider: settings.aiProvider,
            apiKey: settings.aiToken,
            model: settings.aiModel,
            itemsWithCandidates: itemsWithCandidates,
          );
        } catch (_) {
          // Disambiguation is best-effort; the fuzzy matcher still runs.
        }
      }

      final List<ReceiptReviewItem> resolved = _resolveReceiptItems(
        parsedItems,
        products,
        mappings,
        aiDisambiguated,
        usageCounts,
        inStockProductIds,
      );
      if (mounted) {
        await Navigator.push<void>(
          context,
          NexcPage.route(
            title: l10n.aiLogConfirmation,
            builder: (BuildContext context) =>
                ReceiptReviewScreen(houseId: houseId, items: resolved),
          ),
        );
      }
    } catch (error, stackTrace) {
      if (mounted) {
        await showCopyableErrorDialog(
          context,
          l10n.receiptImportError,
          '$error\n\n$stackTrace',
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  List<ReceiptReviewItem> _resolveReceiptItems(
    List<AIReceiptItem> parsedItems,
    List<Product> products,
    List<ReceiptMapping> mappings,
    Map<String, int?> aiDisambiguated,
    Map<int, int>? usageCounts,
    Set<int>? inStockProductIds,
  ) {
    return parsedItems.map((AIReceiptItem parsed) {
      Product? matchedProduct;
      ReceiptMatchState matchState = ReceiptMatchState.missing;

      final ReceiptMapping? mapping = mappings.firstWhereOrNull(
        (ReceiptMapping entry) =>
            entry.receiptName.toLowerCase() == parsed.name.toLowerCase().trim(),
      );
      if (mapping != null) {
        matchedProduct = products.firstWhereOrNull(
          (Product product) => product.id == mapping.productId,
        );
        if (matchedProduct != null) matchState = ReceiptMatchState.perfect;
      }

      if (matchedProduct == null && aiDisambiguated.isNotEmpty) {
        final int? disambiguatedId =
            aiDisambiguated[parsed.name.toLowerCase().trim()];
        if (disambiguatedId != null) {
          final Product? found = products.firstWhereOrNull(
            (Product product) => product.id == disambiguatedId,
          );
          if (found != null) {
            matchedProduct = found;
            matchState = ReceiptMatchState.perfect;
          }
        }
      }

      if (matchedProduct == null) {
        final List<Product> matches = products.searchAndSort(
          parsed.name,
          usageCounts: usageCounts,
          inStockProductIds: inStockProductIds,
        );
        if (matches.isNotEmpty) {
          matchedProduct = matches.first;
          matchState =
              matchedProduct.name.toLowerCase() == parsed.name.toLowerCase()
              ? ReceiptMatchState.perfect
              : ReceiptMatchState.fuzzy;
        }
      }

      return ReceiptReviewItem(
        receiptName: parsed.name,
        inputQuantity: parsed.quantity,
        parsedUnit: parsed.unit,
        matchedProduct: matchedProduct,
        matchState: matchState,
        isSelected: true,
      );
    }).toList();
  }

  Widget? _floatingAction(int? activeHouseId) {
    final l10n = context.l10n;
    switch (_tabController.index) {
      case 0:
        return activeHouseId == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _addProductToStock(activeHouseId),
                icon: const Icon(NexcIcons.add),
                label: Text(l10n.addStock),
              );
      case 1:
        return activeHouseId == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _restock(activeHouseId),
                icon: const Icon(NexcIcons.check),
                label: Text(l10n.restockItems),
              );
      default:
        return FloatingActionButton.extended(
          onPressed: _addHouse,
          icon: const Icon(NexcIcons.add),
          label: Text(l10n.addHouse),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final int? activeHouseId = ref.watch(activeHouseIdProvider);
    final StockRepository repo = ref.watch(stockRepositoryProvider);
    final SettingsState settings = ref.watch(settingsProvider);

    return StreamBuilder<List<House>>(
      stream: repo.watchHouses(),
      builder: (BuildContext context, AsyncSnapshot<List<House>> snapshot) {
        if (snapshot.hasError) {
          return NexcPage(
            title: l10n.stockTitle,
            body: NexcErrorView(
              title: l10n.stockTitle,
              message: l10n.errorWithMessage('${snapshot.error}'),
              onRetry: () => setState(() {}),
            ),
          );
        }
        if (!snapshot.hasData) {
          return NexcPage(
            title: l10n.stockTitle,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final List<House> houses = snapshot.data!;
        final bool validActiveHouse = houses.any(
          (House house) => house.id == activeHouseId,
        );

        return NexcPage(
          title: l10n.stockTitle,
          actions: <Widget>[
            if (settings.enableAiStockLogging &&
                validActiveHouse &&
                activeHouseId != null)
              _isImporting
                  ? const Padding(
                      padding: EdgeInsets.all(NexcSpacing.md),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(NexcIcons.aiReceipt),
                      tooltip: l10n.aiImportReceipt,
                      onPressed: () => _handleReceiptImport(activeHouseId),
                    ),
          ],
          floatingActionButton: _floatingAction(
            validActiveHouse ? activeHouseId : null,
          ),
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NexcSpacing.lg,
                  NexcSpacing.md,
                  NexcSpacing.lg,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    Text(
                      l10n.housePrefix,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(width: NexcSpacing.sm),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: validActiveHouse ? activeHouseId : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: NexcSpacing.md,
                            vertical: NexcSpacing.sm,
                          ),
                        ),
                        hint: Text(l10n.selectOrAddHouse),
                        items: houses
                            .map(
                              (House house) => DropdownMenuItem<int>(
                                value: house.id,
                                child: Text(
                                  house.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (int? value) {
                          if (value != null) {
                            ref.read(activeHouseIdProvider.notifier).state =
                                value;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: NexcSpacing.md),
                  child: TextButton.icon(
                    onPressed: () => _tabController.animateTo(2),
                    icon: const Icon(NexcIcons.stock),
                    label: Text(l10n.manageHouses),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: <Widget>[
                  Tab(text: l10n.currentStockTab),
                  Tab(text: l10n.shoppingListTab),
                  Tab(text: l10n.manageHouses),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _buildCurrentTab(
                      context,
                      validActiveHouse ? activeHouseId : null,
                    ),
                    _buildShoppingTab(
                      context,
                      validActiveHouse ? activeHouseId : null,
                    ),
                    _buildHousesTab(context, houses),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentTab(BuildContext context, int? houseId) {
    final l10n = context.l10n;
    if (houseId == null) {
      return NexcEmptyState(
        icon: NexcIcons.stock,
        title: l10n.selectOrAddHouse,
        actionLabel: l10n.manageHouses,
        onAction: () => _tabController.animateTo(2),
      );
    }
    final StockRepository repo = ref.read(stockRepositoryProvider);

    return StreamBuilder<List<StockWithProduct>>(
      stream: repo.watchStocksWithProductForHouse(houseId),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<StockWithProduct>> snapshot,
          ) {
            if (snapshot.hasError) {
              return NexcErrorView(
                title: l10n.noProductsInStock,
                message: l10n.errorWithMessage('${snapshot.error}'),
                onRetry: () => setState(() {}),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final String query = _searchQuery.trim().toLowerCase();
            final List<StockWithProduct> filtered = sortStocksLowStockFirst(
              snapshot.data!.where(
                (StockWithProduct item) =>
                    query.isEmpty ||
                    item.product.name.toLowerCase().contains(query),
              ),
            );

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(NexcSpacing.lg),
                  child: ClearableSearchField(
                    controller: _stockSearchController,
                    labelText: l10n.searchStock,
                    onChanged: (String value) =>
                        setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? NexcEmptyState(
                          icon: NexcIcons.stock,
                          title: l10n.noProductsInStock,
                          actionLabel: l10n.addStock,
                          onAction: () => _addProductToStock(houseId),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            NexcSpacing.lg,
                            0,
                            NexcSpacing.lg,
                            NexcSpacing.section,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: NexcSpacing.sm),
                          itemBuilder: (BuildContext context, int index) {
                            final StockWithProduct item = filtered[index];
                            final String displayUnit =
                                _displayUnits[item.product.id] ??
                                normalizeStockUnit(item.product.units);
                            return _StockItemCard(
                              key: ValueKey<int>(item.product.id),
                              item: item,
                              displayUnit: displayUnit,
                              onOptions: () => _showItemOptions(item, houseId),
                              onUnitChanged: (String unit) => setState(
                                () => _displayUnits[item.product.id] = unit,
                              ),
                              onQuantitySaved: (double quantity) =>
                                  _saveQuantity(
                                    item,
                                    houseId,
                                    displayUnit,
                                    quantity,
                                  ),
                              onEditTrigger: () => _editTrigger(item, houseId),
                            );
                          },
                        ),
                ),
              ],
            );
          },
    );
  }

  Widget _buildShoppingTab(BuildContext context, int? houseId) {
    final l10n = context.l10n;
    if (houseId == null) {
      return NexcEmptyState(
        icon: NexcIcons.stock,
        title: l10n.selectOrAddHouse,
        actionLabel: l10n.manageHouses,
        onAction: () => _tabController.animateTo(2),
      );
    }
    final StockRepository repo = ref.read(stockRepositoryProvider);

    return StreamBuilder<List<StockWithProduct>>(
      stream: repo.watchStocksWithProductForHouse(houseId),
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<StockWithProduct>> snapshot,
          ) {
            if (snapshot.hasError) {
              return NexcErrorView(
                title: l10n.shoppingListTab,
                message: l10n.errorWithMessage('${snapshot.error}'),
                onRetry: () => setState(() {}),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<StockWithProduct> needed = sortStocksLowStockFirst(
              snapshot.data!.where(isLowStock),
            );
            if (needed.isEmpty) {
              return NexcEmptyState(
                icon: NexcIcons.check,
                title: l10n.noItemsNeedRestocking,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                NexcSpacing.lg,
                NexcSpacing.lg,
                NexcSpacing.lg,
                NexcSpacing.section,
              ),
              itemCount: needed.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: NexcSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final StockWithProduct item = needed[index];
                return _ShoppingRow(
                  key: ValueKey<int>(item.product.id),
                  item: item,
                  checked: _shoppingChecked.contains(item.product.id),
                  initialUnit:
                      _shoppingUnits[item.product.id] ??
                      normalizeStockUnit(item.product.units),
                  onChecked: (bool value) {
                    setState(() {
                      if (value) {
                        _shoppingChecked.add(item.product.id);
                      } else {
                        _shoppingChecked.remove(item.product.id);
                      }
                    });
                  },
                  onQuantityChanged: (double value) {
                    _shoppingQuantities[item.product.id] = value;
                  },
                  onUnitChanged: (String unit) {
                    _shoppingUnits[item.product.id] = unit;
                  },
                );
              },
            );
          },
    );
  }

  Widget _buildHousesTab(BuildContext context, List<House> houses) {
    final l10n = context.l10n;
    final int? activeHouseId = ref.watch(activeHouseIdProvider);
    if (houses.isEmpty) {
      return NexcEmptyState(
        icon: NexcIcons.stock,
        title: l10n.noHousesDefined,
        actionLabel: l10n.addHouse,
        onAction: _addHouse,
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: NexcSpacing.md),
      children: <Widget>[
        NexcSection(
          children: <Widget>[
            for (final House house in houses)
              NexcTile(
                icon: NexcIcons.stock,
                title: house.name,
                selected: house.id == activeHouseId,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(NexcIcons.edit),
                      tooltip: l10n.renameHouse,
                      onPressed: () => _renameHouse(house),
                    ),
                    IconButton(
                      icon: Icon(
                        NexcIcons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      tooltip: l10n.deleteHouse,
                      onPressed: () => _deleteHouse(house),
                    ),
                  ],
                ),
                onTap: () =>
                    ref.read(activeHouseIdProvider.notifier).state = house.id,
              ),
          ],
        ),
      ],
    );
  }
}

class _StockItemCard extends StatelessWidget {
  final StockWithProduct item;
  final String displayUnit;
  final VoidCallback onOptions;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<double> onQuantitySaved;
  final VoidCallback onEditTrigger;

  const _StockItemCard({
    super.key,
    required this.item,
    required this.displayUnit,
    required this.onOptions,
    required this.onUnitChanged,
    required this.onQuantitySaved,
    required this.onEditTrigger,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final double edibleQtyPerUnit = item.product.edibleQtyPerUnit ?? 1.0;

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: const BorderRadius.all(Radius.circular(NexcSpacing.md)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: onOptions,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: NexcSpacing.xs,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              const Icon(NexcIcons.more, size: 18),
                            ],
                          ),
                        ),
                      ),
                      if (item.product.isStockRaw &&
                          item.product.edibleQtyPerUnit != null &&
                          edibleQtyPerUnit < 1.0)
                        Text(
                          l10n.edibleEquivalentValue(
                            formatDecimal(
                              item.stock.quantity * edibleQtyPerUnit,
                            ),
                            item.product.units,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: NexcSpacing.sm),
            Wrap(
              spacing: NexcSpacing.md,
              runSpacing: NexcSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      l10n.unitPrefix,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    DropdownButton<String>(
                      value: displayUnit,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: stockDisplayUnits(item.product)
                          .map(
                            (String unit) => DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                      onChanged: (String? unit) {
                        if (unit != null) onUnitChanged(unit);
                      },
                    ),
                  ],
                ),
                NexcQuantityField(
                  value: stockQuantityInUnit(item, displayUnit),
                  unit: displayUnit,
                  step: stockStepForUnit(displayUnit),
                  compact: true,
                  min: 0,
                  onChanged: onQuantitySaved,
                ),
              ],
            ),
            const Divider(height: NexcSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.stock.minTriggerQuantity == null
                        ? l10n.noMinimum
                        : l10n.minimumWithValue(
                            formatDecimal(item.stock.minTriggerQuantity!),
                            item.product.units,
                          ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(NexcIcons.edit, size: 18),
                  tooltip: l10n.setTriggerFor(item.product.name),
                  onPressed: onEditTrigger,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingRow extends StatefulWidget {
  final StockWithProduct item;
  final bool checked;
  final String initialUnit;
  final ValueChanged<bool> onChecked;
  final ValueChanged<double> onQuantityChanged;
  final ValueChanged<String> onUnitChanged;

  const _ShoppingRow({
    super.key,
    required this.item,
    required this.checked,
    required this.initialUnit,
    required this.onChecked,
    required this.onQuantityChanged,
    required this.onUnitChanged,
  });

  @override
  State<_ShoppingRow> createState() => _ShoppingRowState();
}

class _ShoppingRowState extends State<_ShoppingRow> {
  late final TextEditingController _quantityController;
  late String _unit;

  @override
  void initState() {
    super.initState();
    final double gap =
        widget.item.stock.minTriggerQuantity! - widget.item.stock.quantity;
    _quantityController = TextEditingController(
      text: formatDecimal(gap > 0 ? gap : 0),
    );
    _unit = widget.initialUnit;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    final StockWithProduct item = widget.item;
    final double edibleQtyPerUnit = item.product.edibleQtyPerUnit ?? 1.0;

    return Material(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      borderRadius: const BorderRadius.all(Radius.circular(NexcSpacing.md)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(NexcSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              value: widget.checked,
              onChanged: (bool? value) => widget.onChecked(value ?? false),
            ),
            const SizedBox(width: NexcSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: NexcSpacing.xs),
                  Text(
                    l10n.stockWithValue(formatDecimal(item.stock.quantity)) +
                        (item.product.isStockRaw &&
                                item.product.edibleQtyPerUnit != null &&
                                edibleQtyPerUnit < 1.0
                            ? l10n.stockEdibleSuffix(
                                formatDecimal(
                                  item.stock.quantity * edibleQtyPerUnit,
                                ),
                              )
                            : '') +
                        (item.stock.minTriggerQuantity == null
                            ? ''
                            : l10n.minimumSuffix(
                                formatDecimal(item.stock.minTriggerQuantity!),
                                item.product.units,
                              )),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: NexcSpacing.sm),
            SizedBox(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: NexcSpacing.sm,
                        vertical: NexcSpacing.sm,
                      ),
                    ),
                    onChanged: (String value) {
                      final double? parsed = double.tryParse(
                        value.trim().replaceAll(',', '.'),
                      );
                      if (parsed != null) widget.onQuantityChanged(parsed);
                    },
                  ),
                  const SizedBox(height: NexcSpacing.xs),
                  DropdownButton<String>(
                    value: _unit,
                    isDense: true,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: stockDisplayUnits(item.product)
                        .map(
                          (String unit) => DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          ),
                        )
                        .toList(),
                    onChanged: (String? unit) {
                      if (unit == null) return;
                      setState(() => _unit = unit);
                      widget.onUnitChanged(unit);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
