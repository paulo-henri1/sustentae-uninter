import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../screens/add_post_screen.dart';
import '../utils/global_variables.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({super.key});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = <Tab>[
    const Tab(icon: Icon(Icons.people_outline), child: Text('Comunidade')),
    const Tab(
      icon: Icon(Icons.notifications_outlined),
      child: Text('Novidades'),
    ),
    const Tab(icon: Icon(Icons.person_outline), child: Text('Perfil')),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: homeScreenItems.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget? _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0:
      case 1:
      case 2:
        return FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddPostScreen()),
            );
          },
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sustentaê'),
        bottom: TabBar(controller: _tabController, tabs: _tabs),
      ),
      body: TabBarView(controller: _tabController, children: homeScreenItems),
      floatingActionButton:
          _buildFloatingActionButton() != null
              ? Padding(
                padding: const EdgeInsets.all(0),
                child: _buildFloatingActionButton(),
              )
              : null,
    );
  }
}
