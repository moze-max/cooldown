// lib/screens/add_item_screen.dart

import 'package:flutter/material.dart';
import '../models/purchase_item.dart';
import '../services/isar_service.dart'; // 更改为 Isar Service

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
  final IsarService _isarService = IsarService(); // 实例化服务

  final int _defaultDelayDays = 3;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();
      final notifyTime = now.add(Duration(days: _defaultDelayDays));

      final newItem = PurchaseItem(
        name: _nameController.text,
        price: double.tryParse(_priceController.text),
        url: _urlController.text.isEmpty ? null : _urlController.text,
        entryDate: now,
        notifyDate: notifyTime,
        status: 'pending',
      );

      // **使用 Isar Service 存储**
      await _isarService.saveItem(newItem);

      // 存储成功后，反馈用户并清空表单（因为这是 Tab 内容）
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已添加 ${newItem.name}，冷静期开始！'),
            duration: const Duration(seconds: 2),
          ),
        );

        // 清空表单
        _nameController.clear();
        _priceController.clear();
        _urlController.clear();
        FocusScope.of(context).unfocus(); // 关闭键盘
      }
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
          const SizedBox(height: 20),
          Text(
            '冷静期：$_defaultDelayDays 天后提醒您是否购买',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: _saveItem, child: const Text('保存并开始冷静期')),
        ],
      ),
    );
  }
}
