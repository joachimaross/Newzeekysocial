import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zeeky_social/services/story_service.dart';
import 'package:zeeky_social/services/auth_service.dart';
import 'package:zeeky_social/models/story_model.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  StoriesScreenState createState() => StoriesScreenState();
}

class StoriesScreenState extends State<StoriesScreen> with SingleTickerProviderStateMixin {
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
        title: const Text('Stories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Following'),
            Tab(text: 'Discover'),
            Tab(text: 'My Stories'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _createStory,
            tooltip: 'Create Story',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowingStories(),
          _buildDiscoverStories(),
          _buildMyStories(),
        ],
      ),
    );
  }

  Widget _buildFollowingStories() {
    final storyService = Provider.of<StoryService>(context, listen: false);
    
    return StreamBuilder<List<Story>>(
      stream: storyService.getFollowingStories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final stories = snapshot.data ?? [];
        
        if (stories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No stories yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Follow friends to see their stories here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return _buildStoryGrid(stories);
      },
    );
  }

  Widget _buildDiscoverStories() {
    final storyService = Provider.of<StoryService>(context, listen: false);
    
    return StreamBuilder<List<Story>>(
      stream: storyService.getPublicStories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stories = snapshot.data ?? [];
        
        if (stories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No public stories',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return _buildStoryGrid(stories);
      },
    );
  }

  Widget _buildMyStories() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final storyService = Provider.of<StoryService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      return const Center(child: Text('Please sign in to view your stories'));
    }

    return StreamBuilder<List<Story>>(
      stream: storyService.getUserStories(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stories = snapshot.data ?? [];
        
        if (stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No stories yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share your first story!',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _createStory,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Story'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Add highlights section
            if (stories.any((s) => s.isHighlight))
              _buildHighlightsSection(stories.where((s) => s.isHighlight).toList()),
            
            // Regular stories
            Expanded(
              child: _buildStoryGrid(stories.where((s) => !s.isHighlight).toList()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHighlightsSection(List<Story> highlights) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Highlights',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: highlights.length,
              itemBuilder: (context, index) {
                final story = highlights[index];
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _viewStory(story),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: story.mediaUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    story.mediaUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimeAgo(story.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryGrid(List<Story> stories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return _buildStoryCard(story);
      },
    );
  }

  Widget _buildStoryCard(Story story) {
    return GestureDetector(
      onTap: () => _viewStory(story),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: story.backgroundColor != null
                ? [Color(int.parse(story.backgroundColor!)), Colors.black54]
                : [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Background image or content
            if (story.type == StoryType.image && story.mediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  story.mediaUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            
            // Overlay gradient for text readability
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatTimeAgo(story.createdAt),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Story content
                  if (story.content.isNotEmpty)
                    Text(
                      story.content,
                      style: TextStyle(
                        color: story.textColor != null
                            ? Color(int.parse(story.textColor!))
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Story stats
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.visibility, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${story.viewedBy.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${story.reactions.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (story.isHighlight)
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createStory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Create Story',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text Story'),
                onTap: () {
                  Navigator.pop(context);
                  _createTextStory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Photo Story'),
                onTap: () {
                  Navigator.pop(context);
                  _createPhotoStory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video Story'),
                onTap: () {
                  Navigator.pop(context);
                  _createVideoStory();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _createTextStory() {
    // TODO: Implement text story creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text story creation coming soon!')),
    );
  }

  void _createPhotoStory() {
    // TODO: Implement photo story creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo story creation coming soon!')),
    );
  }

  void _createVideoStory() {
    // TODO: Implement video story creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video story creation coming soon!')),
    );
  }

  void _viewStory(Story story) {
    // TODO: Implement story viewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing story: ${story.content}')),
    );
    
    // Mark as viewed
    final storyService = Provider.of<StoryService>(context, listen: false);
    storyService.viewStory(story.id);
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}