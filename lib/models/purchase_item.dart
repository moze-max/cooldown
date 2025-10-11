// lib/models/purchase_item.dart
import 'package:isar/isar.dart';

// 必须添加 @collection 注解
part 'purchase_item.g.dart'; // 声明生成的代码文件

@collection
class PurchaseItem {
  // Isar 的 ID 字段
  Id id = Isar.autoIncrement;

  final String name;
  final double? price;
  final String? url;
  final DateTime entryDate;
  final DateTime notifyDate;
  final int delayDays;
  String status; // 'pending', 'bought', 'cancelled'

  PurchaseItem({
    required this.name,
    this.price,
    this.url,
    required this.entryDate,
    required this.notifyDate,
    this.status = 'pending',
    required this.delayDays,
  });
}

// 运行命令生成代码：
// flutter pub run build_runner build
