// lib/services/isar_service.dart

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
  }

  // 3. 获取所有物品 (Stream 监听变化)
  Stream<List<PurchaseItem>> listenToItems() async* {
    final isar = await db;

    // 1. **手动**获取并发送初始数据
    final initialList = await isar.purchaseItems
        .where()
        .sortByNotifyDate()
        .findAll();
    yield initialList;

    // 2. 启动 Query Watcher 监听后续的变化，不再需要 initialData/initialReturn
    //    注意：这里我们使用 .watch()，它的作用是每当数据变化时，它就会再次推送
    yield* isar.purchaseItems.where().sortByNotifyDate().watch();
  }
}
