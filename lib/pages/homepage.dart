// lib/screens/homepage.dart

import 'package:flutter/material.dart';
import 'add_item_screen.dart';
import 'calendar_screen.dart';
import 'results_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 DefaultTabController 来管理 TabBar 和 TabBarView
    return const DefaultTabController(
      length: 3, // 三个主选项卡：输入、日历、结果
      child: Scaffold(
        appBar: TabBarAppBar(), // 顶部的 TabBar 导航栏
        body: TabBarView(
          children: <Widget>[
            AddItemScreen(), // 对应第一个 Tab：输入页
            CalendarScreen(), // 对应第二个 Tab：日历/待办页
            ResultsPage(), // 对应第三个 Tab：结果页 (包含子 Tab)
          ],
        ),
      ),
    );
  }
}

// 独立的 AppBar 组件，包含 TabBar
class TabBarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TabBarAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48.0); // AppBar高度 + TabBar高度

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('冷静期'),
      bottom: const TabBar(
        tabs: <Widget>[
          Tab(text: '输入'),
          Tab(text: '日历'),
          Tab(text: '结果'),
        ],
      ),
    );
  }
}
