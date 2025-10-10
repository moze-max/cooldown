// lib/screens/results_page.dart

import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 嵌套 DefaultTabController 用于内部导航
    return DefaultTabController(
      length: 2, // 两个子选项卡：已购买 和 已放弃
      child: Column(
        children: <Widget>[
          // 内部的 TabBar (可以设置不同的颜色区分)
          const ColoredBox(
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
          const Expanded(
            child: TabBarView(
              children: [
                // 占位符页面：已购买清单
                Center(child: Text('已购买物品列表')),

                // 占位符页面：已取消/放弃清单
                Center(child: Text('成功避免冲动消费的物品列表')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
