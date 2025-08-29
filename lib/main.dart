import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/local_repository.dart';
import 'services/storage_service.dart';
import 'pages/problem_detail.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrimeDev Mobile',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF00A45A), // Match your frontend green
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A45A),
          primary: const Color(0xFF00A45A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00A45A),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0xFF00A45A),
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF00A45A),
          unselectedItemColor: Colors.grey,
          selectedIconTheme: IconThemeData(color: Color(0xFF00A45A)),
          showUnselectedLabels: true,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade200,
          selectedColor: const Color(0x3300A45A),
          disabledColor: Colors.grey.shade300,
          secondarySelectedColor: const Color(0x3300A45A),
          labelStyle: const TextStyle(color: Colors.black87),
          secondaryLabelStyle: const TextStyle(color: Colors.black87),
          brightness: Brightness.light,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          shape: const StadiumBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A45A),
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00A45A),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00A45A),
            side: const BorderSide(color: Color(0xFF00A45A)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00A45A)),
          ),
          border: const OutlineInputBorder(),
          prefixIconColor: Colors.grey.shade700,
          focusColor: const Color(0xFF00A45A),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF00A45A),
          linearTrackColor: Color(0x3300A45A),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  String _connectionStatus = 'Checking connection...';

  @override
  void initState() {
    super.initState();
    _checkBackendConnection();
  }

  Future<void> _checkBackendConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Preparing offline mode...';
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));

    setState(() {
      _connectionStatus = '✅ Offline mode: using local data (detached from backend)';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PrimeDev Mobile'),
        backgroundColor: const Color(0xFF00A45A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkBackendConnection,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code),
            label: 'Problems',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label),
            label: 'Tags',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Rankings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const ProblemsTab();
      case 2:
        return const TagsTab();
      case 3:
        return const RankingsTab();
      case 4:
        return const ProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Backend Connection Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_connectionStatus),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to PrimeDev Mobile!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This app runs standalone in offline mode and provides a native mobile interface.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Text(
            'Available Features:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildFeatureItem('📱 Native Mobile UI', 'Built with Flutter widgets'),
          _buildFeatureItem('🗂 Local Data', 'Works fully offline with bundled data'),
          _buildFeatureItem('🚫 No Internet Required', 'Detached from original backend'),
          _buildFeatureItem('🎨 Material Design', 'Modern, responsive interface'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProblemsTab extends StatefulWidget {
  const ProblemsTab({super.key});

  @override
  State<ProblemsTab> createState() => _ProblemsTabState();
}

class _ProblemsTabState extends State<ProblemsTab> {
  List<Map<String, dynamic>> _problems = [];
  bool _isLoading = false;
  String _language = 'JavaScript';
  final LocalRepository _repo = const LocalRepository();
  final TextEditingController _searchController = TextEditingController();
  String _difficultyFilter = 'All';
  final Set<String> _selectedTags = <String>{};
  String _sort = 'Relevance';
  bool _onlyUnsolved = false;

  @override
  void initState() {
    super.initState();
    _loadProblems();
  }

  Future<void> _loadProblems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<Map<String, dynamic>> list = await _repo.loadProblems();
      setState(() {
        _problems = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _problems = [];
        _isLoading = false;
      });
    }
  }

  List<String> get _allTags {
    final Set<String> tags = <String>{};
    for (final Map<String, dynamic> p in _problems) {
      for (final dynamic t in (p['tags'] as List<dynamic>? ?? <dynamic>[])) {
        tags.add(t.toString());
      }
    }
    final List<String> list = tags.toList()..sort();
    return list;
  }

  List<Map<String, dynamic>> get _filteredProblems {
    final String query = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> list = _problems.where((Map<String, dynamic> p) {
      final String title = (p['title'] ?? '').toString().toLowerCase();
      final String difficulty = (p['difficulty'] ?? '').toString();
      final List<dynamic> tags = (p['tags'] as List<dynamic>? ?? <dynamic>[]);
      final bool matchesSearch = query.isEmpty || title.contains(query) || tags.any((t) => t.toString().toLowerCase().contains(query));
      final bool matchesDifficulty = _difficultyFilter == 'All' || difficulty == _difficultyFilter;
      final bool matchesTags = _selectedTags.isEmpty || tags.map((e) => e.toString()).toSet().intersection(_selectedTags).isNotEmpty;
      final bool matchesSolved = !_onlyUnsolved || !StorageService.isSolved(problemId: (p['id'] ?? '').toString(), language: _language);
      return matchesSearch && matchesDifficulty && matchesTags && matchesSolved;
    }).toList();

    int difficultyRank(String d) {
      switch (d) {
        case 'Easy':
          return 0;
        case 'Medium':
          return 1;
        case 'Hard':
          return 2;
        default:
          return 3;
      }
    }

    switch (_sort) {
      case 'Title A-Z':
        list.sort((a, b) => (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString()));
        break;
      case 'Difficulty':
        list.sort((a, b) => difficultyRank((a['difficulty'] ?? '').toString()).compareTo(difficultyRank((b['difficulty'] ?? '').toString())));
        break;
      case 'Relevance':
      default:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Problems',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'JavaScript', child: Text('JavaScript')),
                  DropdownMenuItem(value: 'Python', child: Text('Python (prototype)')),
                ],
                onChanged: (String? v) => setState(() => _language = v ?? 'JavaScript'),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadProblems,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search problems or tags...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _difficultyFilter,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                ],
                onChanged: (String? v) => setState(() => _difficultyFilter = v ?? 'All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Tags: '),
                ..._allTags.map((String tag) => Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        label: Text(tag),
                        selected: _selectedTags.contains(tag),
                        onSelected: (bool sel) => setState(() {
                          if (sel) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        }),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Sort: '),
              DropdownButton<String>(
                value: _sort,
                items: const [
                  DropdownMenuItem(value: 'Relevance', child: Text('Relevance')),
                  DropdownMenuItem(value: 'Title A-Z', child: Text('Title A-Z')),
                  DropdownMenuItem(value: 'Difficulty', child: Text('Difficulty')),
                ],
                onChanged: (String? v) => setState(() => _sort = v ?? 'Relevance'),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Only unsolved'),
                selected: _onlyUnsolved,
                onSelected: (bool v) => setState(() => _onlyUnsolved = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_isLoading)
            Text('Showing ${_filteredProblems.length} of ${_problems.length}')
          else
            const SizedBox.shrink(),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_problems.isEmpty)
            const Center(
              child: Text(
                'No problems found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filteredProblems.length,
                itemBuilder: (context, index) {
                  final problem = _filteredProblems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProblemDetailPage(problem: problem),
                          ),
                        );
                      },
                      title: Text(problem['title'] ?? 'Unknown Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Difficulty: ${problem['difficulty'] ?? 'Unknown'}'),
                          if (problem['tags'] != null)
                            Wrap(
                              spacing: 4,
                              children: (problem['tags'] as List)
                                  .map((tag) => Chip(
                                        label: Text(tag.toString()),
                                        backgroundColor: const Color(0xFF00A45A).withOpacity(0.2),
                                        labelStyle: const TextStyle(fontSize: 12),
                                      ))
                                  .toList(),
                          ),
                          if ((problem['id'] as String?) != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  if (StorageService.isSolved(problemId: problem['id'], language: _language))
                                    const Chip(label: Text('Solved'), backgroundColor: Colors.greenAccent),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class TagsTab extends StatefulWidget {
  const TagsTab({super.key});

  @override
  State<TagsTab> createState() => _TagsTabState();
}

class _TagsTabState extends State<TagsTab> {
  List<Map<String, dynamic>> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 200));

    final List<Map<String, dynamic>> mockTags = <Map<String, dynamic>>[
      {
        'name': 'Array',
        'description': 'Problems involving contiguous or indexed collections',
      },
      {
        'name': 'Hash Table',
        'description': 'Use hashing for constant time lookups',
      },
      {
        'name': 'Graph',
        'description': 'Traversal and pathfinding with nodes and edges',
      },
      {
        'name': 'DP',
        'description': 'Dynamic programming and optimal substructure',
      },
      {
        'name': 'Greedy',
        'description': 'Make locally optimal choices to find global optimum',
      },
    ];

    setState(() {
      _tags = mockTags;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadTags,
              ),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_tags.isEmpty)
            const Center(
              child: Text(
                'No tags found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _tags.length,
                itemBuilder: (context, index) {
                  final tag = _tags[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tag['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (tag['description'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              tag['description'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
}

class RankingsTab extends StatefulWidget {
  const RankingsTab({super.key});

  @override
  State<RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<RankingsTab> {
  List<Map<String, dynamic>> _rankings = [];
  bool _isLoading = false;
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    setState(() {
      _isLoading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Build local ranking consisting of just the current user for now
    final String userName = StorageService.getUserName();
    final List<Map<String, dynamic>> history = StorageService.getSolveHistory();
    int points = 0;
    for (final Map<String, dynamic> h in history) {
      // infer difficulty-based points is not stored per record; skip for now
      // We can’t read problem difficulty here without the problem list; keep total based on solved flags.
      points += 10; // baseline per solve; simplified
    }

    setState(() {
      _totalPoints = points;
      _rankings = <Map<String, dynamic>>[
        {'rank': 1, 'score': points, 'user': userName},
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
              const Text(
                'Local Rankings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadRankings,
              ),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_rankings.isEmpty)
            const Center(
              child: Text(
                'No rankings found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _rankings.length,
                itemBuilder: (context, index) {
                  final ranking = _rankings[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRankColor(index),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(ranking['user']?.toString() ?? 'You'),
                      subtitle: Text('Points: ${ranking['score'] ?? '0'}'),
                      trailing: const Icon(Icons.emoji_events),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey[400]!; // Silver
      case 2:
        return Colors.brown[300]!; // Bronze
      default:
        return const Color(0xFF00A45A);
    }
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: StorageService.getUserName());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF00A45A),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'User Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  'Username',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                  onSubmitted: (value) async { await StorageService.setUserName(value.trim()); },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async { await StorageService.setUserName(nameController.text.trim()); },
                child: const Text('Save'),
              )
            ],
          ),
          _buildProfileItem('Email', 'user@example.com'),
          _buildProfileItem('Status', 'Active'),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Standalone build running in offline mode. Inspired by the original project.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}
