import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zeeky_social/services/content_studio_service.dart';
import 'package:zeeky_social/services/auth_service.dart';

class ContentStudioScreen extends StatefulWidget {
  const ContentStudioScreen({super.key});

  @override
  State<ContentStudioScreen> createState() => _ContentStudioScreenState();
}

class _ContentStudioScreenState extends State<ContentStudioScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ContentStudioService _contentStudio = ContentStudioService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('AI Content Studio'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.create), text: 'Create'),
            Tab(icon: Icon(Icons.emoji_emotions), text: 'Memes'),
            Tab(icon: Icon(Icons.sports_esports), text: 'Challenges'),
            Tab(icon: Icon(Icons.tune), text: 'Remix'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ContentCreatorTab(contentStudio: _contentStudio),
          _MemeGeneratorTab(contentStudio: _contentStudio),
          _ChallengeGeneratorTab(contentStudio: _contentStudio),
          _ContentRemixTab(contentStudio: _contentStudio),
        ],
      ),
    );
  }
}

class _ContentCreatorTab extends StatefulWidget {
  final ContentStudioService contentStudio;
  
  const _ContentCreatorTab({required this.contentStudio});

  @override
  State<_ContentCreatorTab> createState() => _ContentCreatorTabState();
}

class _ContentCreatorTabState extends State<_ContentCreatorTab> {
  final _promptController = TextEditingController();
  ContentType _selectedType = ContentType.post;
  ContentStyle _selectedStyle = ContentStyle.casual;
  Language _selectedLanguage = Language.english;
  bool _includeImages = false;
  bool _isGenerating = false;
  ContentStudioResult? _result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content Generation',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        labelText: 'What do you want to create content about?',
                        hintText: 'Enter your topic or idea...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ContentType>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Content Type',
                              border: OutlineInputBorder(),
                            ),
                            items: ContentType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(_getContentTypeName(type)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<ContentStyle>(
                            value: _selectedStyle,
                            decoration: const InputDecoration(
                              labelText: 'Style',
                              border: OutlineInputBorder(),
                            ),
                            items: ContentStyle.values.map((style) {
                              return DropdownMenuItem(
                                value: style,
                                child: Text(_getContentStyleName(style)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStyle = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Language>(
                            value: _selectedLanguage,
                            decoration: const InputDecoration(
                              labelText: 'Language',
                              border: OutlineInputBorder(),
                            ),
                            items: Language.values.map((lang) {
                              return DropdownMenuItem(
                                value: lang,
                                child: Text(_getLanguageName(lang)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLanguage = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Generate Images'),
                            value: _includeImages,
                            onChanged: (value) {
                              setState(() {
                                _includeImages = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateContent,
                        child: _isGenerating
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Generating...'),
                                ],
                              )
                            : const Text('Generate Content'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_result != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Generated Content',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score: ${(_result!.engagementScore * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _result!.content,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (_result!.hashtags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Hashtags',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _result!.hashtags.map((hashtag) {
                  return Chip(
                    label: Text('#$hashtag'),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
            if (_result!.captions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Caption Variations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...(_result!.captions.take(3).map((caption) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(caption),
                );
              })),
            ],
            if (_result!.generatedImages?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              Text(
                'Generated Images',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _result!.generatedImages!.length,
                  itemBuilder: (context, index) {
                    final imageData = _result!.generatedImages![index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          imageData.bytes,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.withOpacity(0.3),
                              child: const Center(
                                child: Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _copyToClipboard,
                    child: const Text('Copy Content'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _shareContent,
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateContent() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final result = await widget.contentStudio.generateContent(
        prompt: _promptController.text.trim(),
        type: _selectedType,
        style: _selectedStyle,
        language: _selectedLanguage,
        includeImages: _includeImages,
        includeHashtags: true,
        includeCaptions: true,
        maxVariations: 3,
      );

      setState(() {
        _result = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate content: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_result != null) {
      // Copy to clipboard implementation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content copied to clipboard')),
      );
    }
  }

  void _shareContent() {
    if (_result != null) {
      // Navigate to post creation with pre-filled content
      Navigator.pushNamed(context, '/create-post', arguments: _result);
    }
  }

  String _getContentTypeName(ContentType type) {
    switch (type) {
      case ContentType.post: return 'Social Post';
      case ContentType.story: return 'Story';
      case ContentType.reel: return 'Reel/Video';
      case ContentType.meme: return 'Meme';
      case ContentType.challenge: return 'Challenge';
    }
  }

  String _getContentStyleName(ContentStyle style) {
    switch (style) {
      case ContentStyle.casual: return 'Casual';
      case ContentStyle.professional: return 'Professional';
      case ContentStyle.humorous: return 'Humorous';
      case ContentStyle.inspirational: return 'Inspirational';
      case ContentStyle.trendy: return 'Trendy';
      case ContentStyle.educational: return 'Educational';
    }
  }

  String _getLanguageName(Language lang) {
    switch (lang) {
      case Language.english: return 'English';
      case Language.spanish: return 'Spanish';
      case Language.french: return 'French';
      case Language.german: return 'German';
      case Language.italian: return 'Italian';
      case Language.portuguese: return 'Portuguese';
      case Language.japanese: return 'Japanese';
      case Language.chinese: return 'Chinese';
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}

class _MemeGeneratorTab extends StatefulWidget {
  final ContentStudioService contentStudio;
  
  const _MemeGeneratorTab({required this.contentStudio});

  @override
  State<_MemeGeneratorTab> createState() => _MemeGeneratorTabState();
}

class _MemeGeneratorTabState extends State<_MemeGeneratorTab> {
  final _topicController = TextEditingController();
  String? _selectedTemplate;
  bool _isGenerating = false;
  ContentStudioResult? _result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meme Generator',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Meme topic',
                        hintText: 'What do you want to meme about?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTemplate,
                      decoration: const InputDecoration(
                        labelText: 'Template (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Auto-select template'),
                      items: const [
                        DropdownMenuItem(value: 'drake_pointing', child: Text('Drake Pointing')),
                        DropdownMenuItem(value: 'distracted_boyfriend', child: Text('Distracted Boyfriend')),
                        DropdownMenuItem(value: 'woman_yelling_cat', child: Text('Woman Yelling at Cat')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTemplate = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateMeme,
                        child: _isGenerating
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Generating Meme...'),
                                ],
                              )
                            : const Text('Generate Meme'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_result != null) _buildMemeResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemeResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generated Meme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_result!.memeData != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      _result!.memeData!.topText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Meme Image\n(Generated with AI)'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _result!.memeData!.bottomText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_result!.hashtags.isNotEmpty) ...[
              Text(
                'Hashtags',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _result!.hashtags.map((hashtag) {
                  return Chip(
                    label: Text('#$hashtag'),
                    backgroundColor: Colors.orange.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Copy meme text
                    },
                    child: const Text('Copy Text'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Share meme
                    },
                    child: const Text('Share Meme'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateMeme() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final result = await widget.contentStudio.generateMeme(
        topic: _topicController.text.trim(),
        templateId: _selectedTemplate,
        style: ContentStyle.humorous,
        language: Language.english,
      );

      setState(() {
        _result = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate meme: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }
}

class _ChallengeGeneratorTab extends StatefulWidget {
  final ContentStudioService contentStudio;
  
  const _ChallengeGeneratorTab({required this.contentStudio});

  @override
  State<_ChallengeGeneratorTab> createState() => _ChallengeGeneratorTabState();
}

class _ChallengeGeneratorTabState extends State<_ChallengeGeneratorTab> {
  final _categoryController = TextEditingController();
  int _duration = 7;
  bool _isGenerating = false;
  ContentStudioResult? _result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Challenge Generator',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Challenge Category',
                        hintText: 'fitness, creativity, learning...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Duration: $_duration days'),
                        Expanded(
                          child: Slider(
                            value: _duration.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            onChanged: (value) {
                              setState(() {
                                _duration = value.toInt();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateChallenge,
                        child: _isGenerating
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Generating Challenge...'),
                                ],
                              )
                            : const Text('Generate Challenge'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_result != null) _buildChallengeResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generated Challenge',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_result!.challengeData != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.withOpacity(0.1), Colors.blue.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result!.challengeData!.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_result!.challengeData!.duration} Day Challenge',
                      style: TextStyle(
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(_result!.challengeData!.description),
                    const SizedBox(height: 16),
                    Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(_result!.challengeData!.instructions),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_result!.hashtags.isNotEmpty) ...[
              Text(
                'Challenge Hashtags',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _result!.hashtags.map((hashtag) {
                  return Chip(
                    label: Text('#$hashtag'),
                    backgroundColor: Colors.purple.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Copy challenge text
                    },
                    child: const Text('Copy Challenge'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Start challenge
                    },
                    child: const Text('Start Challenge'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateChallenge() async {
    if (_categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final result = await widget.contentStudio.generateChallenge(
        category: _categoryController.text.trim(),
        duration: _duration,
        style: ContentStyle.inspirational,
        language: Language.english,
      );

      setState(() {
        _result = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate challenge: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}

class _ContentRemixTab extends StatefulWidget {
  final ContentStudioService contentStudio;
  
  const _ContentRemixTab({required this.contentStudio});

  @override
  State<_ContentRemixTab> createState() => _ContentRemixTabState();
}

class _ContentRemixTabState extends State<_ContentRemixTab> {
  final _contentController = TextEditingController();
  final List<String> _selectedPlatforms = [];
  final List<Language> _selectedLanguages = [];
  bool _isProcessing = false;
  Map<String, String>? _platformRemixes;
  Map<Language, String>? _translations;

  final List<String> _platforms = ['Twitter', 'Instagram', 'LinkedIn', 'TikTok', 'Facebook', 'YouTube'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content Remix & Translation',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Original Content',
                        hintText: 'Paste your content to adapt...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Adapt for Platforms:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _platforms.map((platform) {
                        return FilterChip(
                          label: Text(platform),
                          selected: _selectedPlatforms.contains(platform),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPlatforms.add(platform);
                              } else {
                                _selectedPlatforms.remove(platform);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Translate to Languages:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: Language.values.where((lang) => lang != Language.english).map((language) {
                        return FilterChip(
                          label: Text(_getLanguageName(language)),
                          selected: _selectedLanguages.contains(language),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedLanguages.add(language);
                              } else {
                                _selectedLanguages.remove(language);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _processContent,
                        child: _isProcessing
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Processing...'),
                                ],
                              )
                            : const Text('Remix & Translate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_platformRemixes != null) _buildPlatformRemixes(),
            if (_translations != null) _buildTranslations(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformRemixes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Adaptations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...(_platformRemixes!.entries.map((entry) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getPlatformIcon(entry.key)),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            // Copy to clipboard
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(entry.value),
                  ],
                ),
              );
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Translations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...(_translations!.entries.map((entry) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getLanguageName(entry.key),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            // Copy to clipboard
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(entry.value),
                  ],
                ),
              );
            })),
          ],
        ),
      ),
    );
  }

  Future<void> _processContent() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter content to process')),
      );
      return;
    }

    if (_selectedPlatforms.isEmpty && _selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select platforms or languages')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final content = _contentController.text.trim();
      
      if (_selectedPlatforms.isNotEmpty) {
        _platformRemixes = await widget.contentStudio.remixForPlatforms(content, _selectedPlatforms);
      }

      if (_selectedLanguages.isNotEmpty) {
        _translations = await widget.contentStudio.translateContent(content, _selectedLanguages);
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process content: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter': return Icons.alternate_email;
      case 'instagram': return Icons.camera_alt;
      case 'linkedin': return Icons.business;
      case 'tiktok': return Icons.video_call;
      case 'facebook': return Icons.facebook;
      case 'youtube': return Icons.video_library;
      default: return Icons.share;
    }
  }

  String _getLanguageName(Language lang) {
    switch (lang) {
      case Language.english: return 'English';
      case Language.spanish: return 'Spanish';
      case Language.french: return 'French';
      case Language.german: return 'German';
      case Language.italian: return 'Italian';
      case Language.portuguese: return 'Portuguese';
      case Language.japanese: return 'Japanese';
      case Language.chinese: return 'Chinese';
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}