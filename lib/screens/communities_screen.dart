import 'package:flutter/material.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  CommunitiesScreenState createState() => CommunitiesScreenState();
}

class CommunitiesScreenState extends State<CommunitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Communities'),
            Tab(text: 'Discover'),
            Tab(text: 'Popular'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createCommunity,
            tooltip: 'Create Community',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyCommunities(),
          _buildDiscoverCommunities(),
          _buildPopularCommunities(),
        ],
      ),
    );
  }

  Widget _buildMyCommunities() {
    // TODO: Implement with actual community service
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No communities yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Join or create a community',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCommunities() {
    // TODO: Implement with actual community service
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Discover communities',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCommunities() {
    // TODO: Implement with actual community service
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Popular communities',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _createCommunity() {
    // TODO: Implement community creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Community creation coming soon!')),
    );
  }
}