// lib/screens/calendar_screen.dart

import 'package:flutter/material.dart';
import '../models/purchase_item.dart';
import '../services/isar_service.dart';

class CalendarScreen extends StatelessWidget {
  CalendarScreen({super.key});

  final IsarService _isarService = IsarService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PurchaseItem>>(
      stream: _isarService.listenToItems(),
      builder: (context, snapshot) {
        // 1. 错误处理
        if (snapshot.hasError) {
          return Center(child: Text('加载错误: ${snapshot.error}'));
        }

        // 2. 加载状态
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 如果 Stream 尚未推送初始数据，显示加载动画
          return const Center(child: CircularProgressIndicator());
        }

        // 3. 数据为空
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(
            child: Text(
              '当前没有等待中的物品。\n去“输入”页添加一个吧！',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // 4. 构建列表
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            // 确保 ID 不为空，Isar Item 应该总有 ID
            final itemId = item.id;

            // 使用 Dismissible 实现滑动操作
            return Dismissible(
              key: ValueKey(itemId), // 必须提供 Key
              direction: DismissDirection.horizontal,

              // **********************************************
              // 底部背景 (滑动时显示)
              background: _buildDismissBackground(
                Icons.cancel,
                Colors.red,
                Alignment.centerLeft,
              ), // 左滑放弃
              secondaryBackground: _buildDismissBackground(
                Icons.check_circle,
                Colors.green,
                Alignment.centerRight,
              ), // 右滑购买
              // **********************************************

              // 滑动完成后的回调
              onDismissed: (direction) async {
                final newStatus = (direction == DismissDirection.endToStart)
                    ? 'bought' // 右滑 (向左) 标记购买
                    : 'cancelled'; // 左滑 (向右) 标记放弃

                // 更新数据库中的状态
                await _isarService.updateItemStatus(itemId, newStatus);

                // 给出反馈
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${item.name} 已标记为 ${newStatus == 'bought' ? '已购买' : '已放弃'}',
                    ),
                  ),
                );
              },

              // 列表项显示
              child: ListTile(
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '提醒日期: ${item.notifyDate.toLocal().toString().substring(0, 10)}',
                ),
                trailing: item.price != null
                    ? Text('¥${item.price!.toStringAsFixed(2)}')
                    : null,
                leading: const Icon(Icons.timer, color: Colors.blueGrey),
              ),
            );
          },
        );
      },
    );
  }

  // 辅助方法：构建滑动时的背景UI
  Widget _buildDismissBackground(
    IconData icon,
    Color color,
    Alignment alignment,
  ) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}
