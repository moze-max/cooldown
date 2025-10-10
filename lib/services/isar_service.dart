// lib/services/isar_service.dart

import 'dart:developer' as developer;

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/purchase_item.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openIsar();
  }

  // 1. 初始化并打开 Isar 实例
  Future<Isar> openIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    // 确保 Isar 只打开一次
    if (Isar.instanceNames.isEmpty) {
      return Isar.open(
        [PurchaseItemSchema], // 传入生成的 Schema
        directory: dir.path,
        inspector: true, // 开启 Isar Inspector (调试工具)
      );
    }
    return Future.value(Isar.getInstance());
  }

  // 2. 插入新物品
  Future<void> saveItem(PurchaseItem item) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.purchaseItems.put(item); // 直接保存对象
    });
    // await printAllItems();
  }

  // 3. 获取所有物品 (Stream 监听变化)
  Stream<List<PurchaseItem>> listenToItems() async* {
    final isar = await db;
    yield* isar.purchaseItems
        .filter()
        .statusEqualTo('pending') // 👈 仅筛选 'pending' 状态
        .sortByNotifyDate()
        .watch(fireImmediately: true);
  }

  Future<void> updateItemStatus(int id, String newStatus) async {
    final isar = await db;

    // 1. 获取要更新的对象
    PurchaseItem? item = await isar.purchaseItems.get(id);

    if (item != null) {
      // 2. 更新状态
      item.status = newStatus;

      // 3. 将修改后的对象存回数据库 (Isar 会根据 ID 自动覆盖旧数据)
      await isar.writeTxn(() async {
        await isar.purchaseItems.put(item);
      });
      developer.log('✅ Item ${item.name} status updated to $newStatus');
    }
  }

  Stream<List<PurchaseItem>> listenToBoughtItems() async* {
    final isar = await db;

    // 筛选出 status 等于 'bought' 的物品
    yield* isar.purchaseItems
        .filter()
        .statusEqualTo('bought') // 👈 筛选 'bought' 状态
        .sortByNotifyDateDesc() // 按日期倒序排列，最新购买的在最上面
        .watch(fireImmediately: true);
  }

  Stream<List<PurchaseItem>> listenToCancelledItems() async* {
    final isar = await db;

    // 筛选出 status 等于 'cancelled' 的物品
    yield* isar.purchaseItems
        .filter()
        .statusEqualTo('cancelled') // 👈 筛选 'cancelled' 状态
        .sortByNotifyDateDesc() // 按日期倒序排列
        .watch(fireImmediately: true);
  }

  Future<void> printAllItems() async {
    final isar = await db;
    // 查询所有物品
    final items = await isar.purchaseItems.where().findAll();

    developer.log('--- Isar Database Snapshot ---');
    if (items.isEmpty) {
      developer.log('No items found.');
    } else {
      for (var item in items) {
        developer.log(
          'ID: ${item.id}, Name: ${item.name}, Status: ${item.status}, Notify: ${item.notifyDate}',
        );
      }
    }
    developer.log('----------------------------');
  }
}
