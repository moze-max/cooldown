// // lib/screens/results_page.dart

// import 'package:flutter/material.dart';

// class ResultsPage extends StatelessWidget {
//   const ResultsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 嵌套 DefaultTabController 用于内部导航
//     return DefaultTabController(
//       length: 2, // 两个子选项卡：已购买 和 已放弃
//       child: Column(
//         children: <Widget>[
//           // 内部的 TabBar (可以设置不同的颜色区分)
//           const ColoredBox(
//             color: Colors.white,
//             child: TabBar(
//               indicatorColor: Colors.deepPurple,
//               labelColor: Colors.deepPurple,
//               unselectedLabelColor: Colors.grey,
//               tabs: [
//                 Tab(text: '已购买'),
//                 Tab(text: '已取消/放弃'),
//               ],
//             ),
//           ),
//           // TabBarView 必须使用 Expanded 包裹
//           const Expanded(
//             child: TabBarView(
//               children: [
//                 // 占位符页面：已购买清单
//                 Center(child: Text('已购买物品列表')),

//                 // 占位符页面：已取消/放弃清单
//                 Center(child: Text('成功避免冲动消费的物品列表')),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/results_page.dart

import 'package:flutter/material.dart';
import '../models/purchase_item.dart';
import '../services/isar_service.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 嵌套 DefaultTabController 用于内部导航
    return const DefaultTabController(
      length: 2, // 两个子选项卡：已购买 和 已放弃
      child: Column(
        children: <Widget>[
          // 内部的 TabBar
          ColoredBox(
            color: Colors.white,
            child: TabBar(
              indicatorColor: Colors.deepPurple,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: '已购买'),
                Tab(text: '已取消/放弃'),
              ],
            ),
          ),
          // TabBarView 必须使用 Expanded 包裹
          Expanded(
            child: TabBarView(
              children: [
                ItemResultList(status: 'bought'), // 第一个子页：已购买清单
                ItemResultList(status: 'cancelled'), // 第二个子页：已放弃清单
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 列表组件：根据状态显示不同的数据 ---

class ItemResultList extends StatelessWidget {
  final String status; // 'bought' 或 'cancelled'
  const ItemResultList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final IsarService isarService = IsarService();

    // 根据传入的状态选择要订阅的 Stream
    final Stream<List<PurchaseItem>> stream = (status == 'bought')
        ? isarService.listenToBoughtItems()
        : isarService.listenToCancelledItems();

    return StreamBuilder<List<PurchaseItem>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('加载错误: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          final message = (status == 'bought')
              ? '还没有标记购买的物品。'
              : '恭喜！您还没有成功避免冲动消费的记录。';
          return Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        // 构建列表视图
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final title = (status == 'bought')
                ? '最终购买: ${item.name}'
                : '成功避免: ${item.name}';

            final icon = (status == 'bought')
                ? Icons.shopping_bag
                : Icons.thumb_up_alt;

            final color = (status == 'bought')
                ? Colors.red.shade400
                : Colors.green.shade400;

            return ListTile(
              leading: Icon(icon, color: color),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '记录日期: ${item.entryDate.toLocal().toString().substring(0, 10)}',
              ),
              trailing: item.price != null
                  ? Text(
                      '¥${item.price!.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
