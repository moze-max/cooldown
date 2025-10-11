// lib/screens/add_item_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import '../models/purchase_item.dart';
import '../services/isar_service.dart';
import '../services/local_notification_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _urlController = TextEditingController();
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '3'); // 默认 3 分钟
  final _secondsController = TextEditingController(text: '0');
  final IsarService _isarService = IsarService(); // 实例化服务
  final LocalNotificationService _notificationService =
      LocalNotificationService(); // 实例化
  final int _defaultDelayDays = 3;
  final bool _isMobilePlatform = Platform.isAndroid || Platform.isIOS;

  void _saveItem() async {
    // if (_formKey.currentState!.validate()) {
    //   _formKey.currentState!.save();

    //   final now = DateTime.now();
    //   final notifyTime = now.add(Duration(days: _defaultDelayDays));

    //   final newItem = PurchaseItem(
    //     name: _nameController.text,
    //     price: double.tryParse(_priceController.text),
    //     url: _urlController.text.isEmpty ? null : _urlController.text,
    //     entryDate: now,
    //     notifyDate: notifyTime,
    //     status: 'pending',
    //     delayDays: totalDaysForStorage,
    //   );

    //   // **使用 Isar Service 存储**
    //   await _isarService.saveItem(newItem);
    //   await _notificationService.scheduleNotification(item: newItem);
    //   if (mounted) {
    //     String message = '已添加 ${newItem.name}，冷静期开始！';
    //     // ... (根据 calendarSuccess 调整消息)
    //     message += ' (提醒已设置)';

    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(SnackBar(content: Text(message)));
    //     // 存储成功后，反馈用户并清空表单（因为这是 Tab 内容）
    //     // if (mounted) {
    //     //   ScaffoldMessenger.of(context).showSnackBar(
    //     //     SnackBar(
    //     //       content: Text('已添加 ${newItem.name}，冷静期开始！'),
    //     //       duration: const Duration(seconds: 2),
    //     //     ),
    //     //   );

    //     // 清空表单
    //     _nameController.clear();
    //     _priceController.clear();
    //     _urlController.clear();

    //     FocusScope.of(context).unfocus(); // 关闭键盘
    //   }
    // }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    final now = DateTime.now();
    DateTime notifyTime = now;
    int totalDaysForStorage = 0; // 初始化

    if (_isMobilePlatform) {
      // 1. 从控制器获取并解析时间
      final hours = int.tryParse(_hoursController.text) ?? 0;
      final minutes = int.tryParse(_minutesController.text) ?? 0;
      final seconds = int.tryParse(_secondsController.text) ?? 0;

      // 检查是否有任何时间输入
      if (hours == 0 && minutes == 0 && seconds == 0) {
        // 可以在这里显示一个错误提示，要求输入至少一个时间单位
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('冷静期时间至少需要一秒。')));
        }
        return;
      }

      // ✅ 构造秒级精度的 Duration
      final delayDuration = Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );

      // ✅ 使用 Duration 来计算通知时间
      notifyTime = now.add(delayDuration);

      // 计算总天数（用于存储到 delayDays 字段，尽管它现在可能是分数）
      totalDaysForStorage = delayDuration.inDays;
    } else {
      // 非移动端，默认行为：3天后提醒
      notifyTime = now.add(const Duration(days: 3));
      totalDaysForStorage = 3;
    }

    // 2. 创建物品对象
    final newItem = PurchaseItem(
      name: _nameController.text,
      price: double.tryParse(_priceController.text),
      url: _urlController.text.isEmpty ? null : _urlController.text,
      entryDate: now,
      notifyDate: notifyTime,
      status: 'pending',
      delayDays: totalDaysForStorage, // 存储天数（或你可以创建一个新的 `delaySeconds` 字段）
    );

    // 3. 存储、排程通知和日历 (保持不变)
    await _isarService.saveItem(newItem);
    if (Platform.isAndroid || Platform.isIOS) {
      await _isarService.addCalendarEvent(newItem);
      await _notificationService.scheduleNotification(item: newItem);
    }

    if (mounted) {
      String message = '已添加 ${newItem.name}，冷静期开始！';
      // ... (根据 calendarSuccess 调整消息)
      message += ' (提醒已设置)';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      // 存储成功后，反馈用户并清空表单（因为这是 Tab 内容）
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('已添加 ${newItem.name}，冷静期开始！'),
      //       duration: const Duration(seconds: 2),
      //     ),
      //   );

      // 清空表单
      _nameController.clear();
      _priceController.clear();
      _urlController.clear();

      FocusScope.of(context).unfocus(); // 关闭键盘
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // ... (TextFormFields 保持不变)
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '物品名称（必填）',
              icon: Icon(Icons.shopping_bag_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入物品名称';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '预估价格（可选）',
              icon: Icon(Icons.attach_money),
            ),
          ),
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: '购买链接/备注（可选）',
              icon: Icon(Icons.link),
            ),
          ),
          // const SizedBox(height: 20),
          // Text(
          //   '冷静期：$_defaultDelayDays 天后提醒您是否购买',
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: Theme.of(context).colorScheme.primary,
          //   ),
          // ),
          // const SizedBox(height: 30),
          // ElevatedButton(onPressed: _saveItem, child: const Text('保存并开始冷静期')),
          // const SizedBox(height: 10),
          // const Text(
          //   '设置冷静期时间',
          //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 10),

          // // ✅ 新增：用于小时、分钟、秒的输入框
          // Row(
          //   children: [
          //     _buildTimeInput(controller: _hoursController, label: '小时'),
          //     const Text(' : ', style: TextStyle(fontSize: 20)),
          //     _buildTimeInput(controller: _minutesController, label: '分钟'),
          //     const Text(' : ', style: TextStyle(fontSize: 20)),
          //     _buildTimeInput(controller: _secondsController, label: '秒'),
          //   ],
          // ),
          if (_isMobilePlatform) ...[
            const SizedBox(height: 10),
            const Text(
              '设置冷静期时间',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTimeInput(controller: _hoursController, label: '小时'),
                const Text(' : ', style: TextStyle(fontSize: 20)),
                _buildTimeInput(controller: _minutesController, label: '分钟'),
                const Text(' : ', style: TextStyle(fontSize: 20)),
                _buildTimeInput(controller: _secondsController, label: '秒'),
              ],
            ),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 20),

          // 移除旧的提示文本，因为实时计算会复杂，保持简洁或在保存时显示。
          ElevatedButton(onPressed: _saveItem, child: const Text('保存并开始冷静期')),
        ],
      ),
    );
  }

  Widget _buildTimeInput({
    required TextEditingController controller,
    required String label,
  }) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 8,
          ),
        ),
        textAlign: TextAlign.center,
        validator: (value) {
          final val = int.tryParse(value ?? '0');
          if (val == null || val < 0) {
            return '无效';
          }
          // 在 _saveItem 中集中检查总时长是否为零
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _urlController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }
}
