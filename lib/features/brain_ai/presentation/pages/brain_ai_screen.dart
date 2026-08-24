import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/features/brain_ai/logic/ai_service.dart';

class BrainAiScreen extends StatefulWidget {
  const BrainAiScreen({Key? key}) : super(key: key);

  @override
  State<BrainAiScreen> createState() => _BrainAiScreenState();
}

class _BrainAiScreenState extends State<BrainAiScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AiService _aiService = AiService();

  bool _isBuilderMode = true;
  bool _isLoading = false;
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'AI Agent',
      'text': 'System Online. Real AI Service ready. Configure your API Key in the API tab.',
    },
  ];

  String _selectedProvider = 'OpenAI';
  String _selectedModel = 'gpt-4o';
  final TextEditingController _apiKeyController = TextEditingController();
  String _testStatus = '';

  final List<String> _providers = ['OpenAI', 'Groq (Fast)', 'OpenRouter (Free/All)'];
  List<String> _models = ['gpt-4o', 'gpt-4o-mini', 'llama-3.1-70b', 'mixtral-8x7b'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  // 1. Real Chat Send
  void _sendMessage() async {
    String text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'User', 'text': text});
      _chatController.clear();
      _isLoading = true;
    });

    String response = await _aiService.sendPrompt(text, isBuilderMode: _isBuilderMode);

    setState(() {
      _isLoading = false;
      _messages.add({'sender': 'AI Agent', 'text': response});
    });
  }

  // 2. Real Download All Models Action
  void _downloadModels() async {
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste your API key first!')),
      );
      return;
    }

    _aiService.configure(
      key: _apiKeyController.text,
      selectedProvider: _selectedProvider,
      selectedModel: _selectedModel,
    );

    setState(() => _isLoading = true);

    try {
      List<String> downloaded = await _aiService.fetchAvailableModels();
      setState(() {
        _models = downloaded;
        if (_models.isNotEmpty) {
          _selectedModel = _models.first;
        }
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded ${_models.length} real models from $_selectedProvider!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // 3. Real Test Key Action
  void _testKey() async {
    _aiService.configure(
      key: _apiKeyController.text,
      selectedProvider: _selectedProvider,
      selectedModel: _selectedModel,
    );

    setState(() {
      _isLoading = true;
      _testStatus = 'Testing connection...';
    });

    String result = await _aiService.testConnection();

    setState(() {
      _isLoading = false;
      _testStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '🧠 Future Brain AI',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.cyanAccent,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'AI Agent'),
            Tab(icon: Icon(Icons.key), text: 'API Manager'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatAgentTab(),
          _buildApiManagerTab(),
        ],
      ),
    );
  }

  Widget _buildChatAgentTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF141420),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isBuilderMode ? 'MODE: Game & Anim Builder' : 'MODE: Conversational Chat',
                style: TextStyle(
                  color: _isBuilderMode ? Colors.cyanAccent : Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Switch(
                value: _isBuilderMode,
                activeColor: Colors.cyanAccent,
                inactiveThumbColor: Colors.purpleAccent,
                onChanged: (val) => setState(() => _isBuilderMode = val),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const LinearProgressIndicator(color: Colors.cyanAccent, backgroundColor: Colors.black),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['sender'] == 'User';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.purpleAccent.withOpacity(0.3) : const Color(0xFF1A1A26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUser ? Colors.purpleAccent : Colors.cyanAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['sender']!,
                        style: TextStyle(
                          color: isUser ? Colors.purpleAccent : Colors.cyanAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg['text']!,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF101018),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _isBuilderMode ? 'Command AI to build 3D world...' : 'Ask AI anything...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E1E2C),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.cyanAccent),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApiManagerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AUTO-FREE FILTER: Free & Fast Models Sorted to Top',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Provider:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedProvider,
                      dropdownColor: const Color(0xFF1E1E2C),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF161622),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _providers.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (val) => setState(() => _selectedProvider = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Model:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _models.contains(_selectedModel) ? _selectedModel : (_models.isNotEmpty ? _models.first : null),
                      dropdownColor: const Color(0xFF1E1E2C),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF161622),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _models.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) => setState(() => _selectedModel = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.cyanAccent,
                side: const BorderSide(color: Colors.cyanAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download All Available Models'),
              onPressed: _downloadModels,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Enter API Key:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'sk-xxxxxxxxxxxxxxxxxxxx',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF161622),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    _aiService.configure(
                      key: _apiKeyController.text,
                      selectedProvider: _selectedProvider,
                      selectedModel: _selectedModel,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API Key and Configuration Saved!')),
                    );
                  },
                  child: const Text('ENTER (SAVE)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _testKey,
                  child: const Text('TEST KEY', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          if (_testStatus.isNotEmpty) ...[
            const SizedBox(height: 14),
            Center(
              child: Text(
                _testStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _testStatus.contains('Success') ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
