/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:flutter/material.dart';

/// Semantic icon map.
///
/// One concept keeps one icon across the app. Outlined variants are used for
/// idle states and filled variants for selected/active states.
abstract final class NexcIcons {
  // Primary navigation
  static const IconData workout = Icons.fitness_center;
  static const IconData workoutIdle = Icons.fitness_center_outlined;
  static const IconData meals = Icons.restaurant;
  static const IconData mealsIdle = Icons.restaurant_outlined;
  static const IconData profile = Icons.person;
  static const IconData profileIdle = Icons.person_outline;

  // Profile sections
  static const IconData statistics = Icons.insights;
  static const IconData calendar = Icons.calendar_month;
  static const IconData workoutHistory = Icons.history;
  static const IconData mealHistory = Icons.receipt_long;
  static const IconData measurements = Icons.monitor_weight;
  static const IconData personalInfo = Icons.badge;
  static const IconData exercises = Icons.sports_gymnastics;
  static const IconData products = Icons.inventory_2;
  static const IconData recipes = Icons.menu_book;
  static const IconData stock = Icons.storefront;
  static const IconData settings = Icons.settings;
  static const IconData about = Icons.info;
  static const IconData overview = Icons.insights;

  // Settings
  static const IconData theme = Icons.palette;
  static const IconData dynamicColor = Icons.wallpaper;
  static const IconData images = Icons.image;
  static const IconData language = Icons.translate;
  static const IconData units = Icons.straighten;
  static const IconData scrollInput = Icons.swipe_vertical;
  static const IconData keepScreenOn = Icons.screen_lock_portrait;
  static const IconData restAlerts = Icons.timer;
  static const IconData sound = Icons.volume_up;
  static const IconData vibration = Icons.vibration;
  static const IconData intensity = Icons.speed;
  static const IconData routineUpdate = Icons.sync;
  static const IconData stickyHeader = Icons.push_pin;
  static const IconData mealTracking = Icons.restaurant;
  static const IconData dayStart = Icons.schedule;
  static const IconData macros = Icons.donut_large;
  static const IconData ai = Icons.smart_toy;
  static const IconData aiReceipt = Icons.document_scanner;
  static const IconData aiProduct = Icons.add_box;
  static const IconData apiKey = Icons.key;
  static const IconData backup = Icons.cloud_sync;
  static const IconData privacy = Icons.shield;
  static const IconData license = Icons.article;
  static const IconData attribution = Icons.volunteer_activism;

  // Domain
  static const IconData play = Icons.play_arrow;
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete;
  static const IconData more = Icons.more_vert;
  static const IconData drag = Icons.drag_handle;
  static const IconData expand = Icons.expand_more;
  static const IconData chevron = Icons.chevron_right;
  static const IconData check = Icons.check;
  static const IconData close = Icons.close;
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData timer = Icons.timer;
  static const IconData streak = Icons.local_fire_department;
  static const IconData notes = Icons.notes;
  static const IconData warning = Icons.error_outline;
  static const IconData empty = Icons.inbox;
}
