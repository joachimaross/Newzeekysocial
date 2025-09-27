import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zeeky_social/services/search_service.dart';
import 'package:zeeky_social/services/ai_service.dart';
import 'package:zeeky_social/models/post_model.dart';
import 'package:zeeky_social/models/user_model.dart';
import 'package:zeeky_social/models/community_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  List<SearchResult> _allResults = [];
  List<SearchResult> _userResults = [];
  List<SearchResult> _postResults = [];
  List<SearchResult> _communityResults = [];
  List<TrendingItem> _trendingHashtags = [];
  List<Post> _trendingPosts = [];
  
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTrendingContent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrendingContent() async {
    final searchService = Provider.of<SearchService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final trending = await Future.wait([
        searchService.getTrendingHashtags(),
        searchService.getTrendingPosts(),
      ]);

      setState(() {
        _trendingHashtags = trending[0] as List<TrendingItem>;
        _trendingPosts = trending[1] as List<Post>;
      });
    } catch (e) {
      print('Error loading trending content: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final searchService = Provider.of<SearchService>(context, listen: false);

    try {
      final results = await Future.wait([
        searchService.universalSearch(query),
        searchService.searchUsers(query),
        searchService.searchPosts(query),
        searchService.searchCommunities(query),
      ]);

      setState(() {
        _allResults = results[0] as List<SearchResult>;
        _userResults = results[1] as List<SearchResult>;
        _postResults = results[2] as List<SearchResult>;
        _communityResults = results[3] as List<SearchResult>;
      });
    } catch (e) {
      print('Error performing search: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search users, posts, communities...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _hasSearched = false;
                        _allResults = [];
                        _userResults = [];
                        _postResults = [];
                        _communityResults = [];
                      });
                    },
                  ),
              ],
              onSubmitted: _performSearch,
            ),
          ),
        ),
      ),
      body: _hasSearched ? _buildSearchResults() : _buildTrendingContent(),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All (${_allResults.length})'),
            Tab(text: 'Users (${_userResults.length})'),
            Tab(text: 'Posts (${_postResults.length})'),
            Tab(text: 'Communities (${_communityResults.length})'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildResultsList(_allResults),
              _buildResultsList(_userResults),
              _buildResultsList(_postResults),
              _buildResultsList(_communityResults),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildResultItem(SearchResult result) {
    return ListTile(
      leading: result.imageUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(result.imageUrl!),
            )
          : CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(_getIconForType(result.type)),
            ),
      title: Text(
        result.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        result.subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Chip(
        label: Text(result.type.toString().split('.').last),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      onTap: () => _handleResultTap(result),
    );
  }

  Widget _buildTrendingContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendingHashtags(),
          const SizedBox(height: 24),
          _buildTrendingPosts(),
          const SizedBox(height: 24),
          _buildSearchSuggestions(),
        ],
      ),
    );
  }

  Widget _buildTrendingHashtags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Trending Hashtags',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_trendingHashtags.isEmpty)
          const Text('No trending hashtags right now')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingHashtags.take(10).map((hashtag) {
              return ActionChip(
                label: Text(hashtag.content),
                onPressed: () {
                  _searchController.text = hashtag.content;
                  _performSearch(hashtag.content);
                },
                avatar: Text(hashtag.count.toString()),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTrendingPosts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.whatshot, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Trending Posts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_trendingPosts.isEmpty)
          const Text('No trending posts right now')
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _trendingPosts.length,
              itemBuilder: (context, index) {
                final post = _trendingPosts[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.favorite, size: 16),
                              const SizedBox(width: 4),
                              Text('${post.totalReactions}'),
                              const SizedBox(width: 16),
                              Icon(Icons.comment, size: 16),
                              const SizedBox(width: 4),
                              Text('${post.commentsCount}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      'Popular users',
      'Recent posts',
      'Active communities',
      'Local events',
      'AI art',
      'Technology',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Search Suggestions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              onPressed: () {
                _searchController.text = suggestion;
                _performSearch(suggestion);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconForType(SearchType type) {
    switch (type) {
      case SearchType.users:
        return Icons.person;
      case SearchType.posts:
        return Icons.article;
      case SearchType.communities:
        return Icons.groups;
      case SearchType.hashtags:
        return Icons.tag;
      case SearchType.all:
        return Icons.search;
    }
  }

  void _handleResultTap(SearchResult result) {
    // TODO: Navigate to appropriate detail screen based on result type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped ${result.type.toString().split('.').last}: ${result.title}'),
      ),
    );
  }
}