import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/models/level_model.dart';
import 'package:tiptop_game_engine/features/brain_ai/logic/ai_service.dart';

enum MessageType { user, assistant, levelGenerated }

class ChatMessage {
  final String text;
  final MessageType type;
  final String? subtitle;
  final LevelModel? generatedLevel;

  ChatMessage({
    required this.text,
    required this.type,
    this.subtitle,
    this.generatedLevel,
  });
}

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

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Готов съм за TipTop Engine! Кажи какво да построим в 2D или 3D.',
      type: MessageType.assistant,
      subtitle: '• 🏙️ Cyberpunk мегаполиси и градове\n• 🌋 3D Filament лава паркури\n• 🏰 2D Godot замъци и нинджи',
    ),
  ];

  String _selectedProvider = '⚡ АВТОМАТИЧЕН (Free Auto-Router)';
  String _selectedModel = '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)';
  final TextEditingController _apiKeyController = TextEditingController();
  String _statusMessage = '🟢 Автоматичен режим: 6 резервни модела са онлайн.';
  bool _isSuccess = true;

  List<String> _providers = [
    '⚡ АВТОМАТИЧЕН (Free Auto-Router)',
    '🌐 OpenRouter (Всички 250+ Модела)',
    '⚡ Groq (Ултра Бърз / Free)',
    '🔮 Google Gemini',
    '🤖 DeepSeek',
    '🟢 OpenAI',
    '🧠 Anthropic Claude',
    '🦙 Meta LLaMA',
    '🌪️ Mistral AI',
    '🐉 Qwen & Alibaba',
  ];

  late List<String> _models;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _models = _aiService.getModelsForProvider(_selectedProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    String text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, type: MessageType.user));
      _chatController.clear();
      _isLoading = true;
    });

    String response = await _aiService.sendPrompt(text, isBuilderMode: _isBuilderMode);
    LevelModel? generatedLevel;
    if (_isBuilderMode) {
      generatedLevel = _aiService.generateLevelFromPrompt(text);
    }

    setState(() {
      _isLoading = false;
      _messages.add(ChatMessage(text: response, type: MessageType.assistant));
      if (generatedLevel != null) {
        _messages.add(ChatMessage(
          text: 'Сцената е генерирана успешно!',
          type: MessageType.levelGenerated,
          generatedLevel: generatedLevel,
        ));
      }
    });
  }

  // 🔄 СВАЛЯНЕ НА ВСИЧКИ ДОСТАВЧИЦИ И ВСИЧКИ МОДЕЛИ
  void _syncAllProvidersAndModels() async {
    setState(() => _isLoading = true);
    _aiService.configure(key: _apiKeyController.text, selectedProvider: _selectedProvider, selectedModel: _selectedModel);

    final fullCatalog = await _aiService.fetchAllProvidersAndModels();

    setState(() {
      _providers = fullCatalog.keys.toList();
      if (!_providers.contains(_selectedProvider)) {
        _selectedProvider = _providers.first;
      }
      _models = _aiService.getModelsForProvider(_selectedProvider);
      if (_models.isNotEmpty && !_models.contains(_selectedModel)) {
        _selectedModel = _models.first;
      }
      _isLoading = false;
    });

    int totalModels = fullCatalog.values.fold(0, (sum, list) => sum + list.length);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Успешно свалени $totalModels модела от ${_providers.length} доставчика!'),
      ),
    );
  }

  void _testKey() async {
    _aiService.configure(key: _apiKeyController.text, selectedProvider: _selectedProvider, selectedModel: _selectedModel);
    setState(() {
      _isLoading = true;
      _statusMessage = 'Тестване на връзката...';
    });

    String result = await _aiService.testConnection();
    setState(() {
      _isLoading = false;
      _statusMessage = result;
      _isSuccess = result.contains('Успешна') || result.contains('🟢');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF10121A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.sciFiCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('🧠 Brain AI Гейм Архитект', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.laserPink,
          indicatorWeight: 3,
          labelColor: AppTheme.laserPink,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.smart_toy_outlined, size: 18), text: 'AI Строител'),
            Tab(icon: Icon(Icons.vpn_key_outlined, size: 18), text: 'API Мениджър'),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: const Color(0xFF141622),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(_isBuilderMode ? 'TipTop 2D/3D Builder' : 'TipTop AI Chat', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.4))),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isBuilderMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: !_isBuilderMode ? AppTheme.laserPink : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                        child: Text('ЧАТ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: !_isBuilderMode ? FontWeight.bold : FontWeight.normal)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isBuilderMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: _isBuilderMode ? AppTheme.sciFiCyan : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                        child: Text('СТРОИТЕЛ', style: TextStyle(color: _isBuilderMode ? Colors.black : Colors.white70, fontSize: 10, fontWeight: _isBuilderMode ? FontWeight.bold : FontWeight.normal)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (_isLoading) const LinearProgressIndicator(color: AppTheme.sciFiCyan, backgroundColor: Colors.black, minHeight: 2),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _buildMessageItem(_messages[index]),
          ),
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF161824), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: _isBuilderMode ? 'Построй Cyberpunk град, 3D лава или 2D замък...' : 'Напиши съобщение...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppTheme.laserPink),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    if (msg.type == MessageType.levelGenerated && msg.generatedLevel != null) {
      final lvl = msg.generatedLevel!;
      final bool is3D = lvl.dimension == LevelDimension.threeD;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF121A28),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: is3D ? AppTheme.laserPink : const Color(0xFF00E676)),
          boxShadow: [
            BoxShadow(
              color: (is3D ? AppTheme.laserPink : const Color(0xFF00E676)).withValues(alpha: 0.15),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(is3D ? Icons.view_in_ar : Icons.grid_view, color: is3D ? AppTheme.laserPink : const Color(0xFF00E676), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lvl.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${lvl.dimension == LevelDimension.threeD ? "3D Filament" : "2D Godot"} • ${lvl.nodes.length} генерирани обекта', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: is3D ? AppTheme.laserPink : const Color(0xFF00E676),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.play_arrow, color: Colors.black, size: 18),
                label: const Text('ОТВОРИ И ИГРАЙ В СТУДИОТО', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('🍄 Зареждане на "${lvl.title}" в Студиото...')),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    if (msg.type == MessageType.user) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5D1D86), Color(0xFF381552)]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.4)),
          ),
          child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF141724),
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border(left: BorderSide(color: AppTheme.sciFiCyan, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
            if (msg.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(msg.subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApiManagerTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ДОСТАВЧИЦИ & МОДЕЛИ (250+ LIVE)', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.sciFiCyan, size: 20),
              tooltip: 'Свали всички доставчици и модели на живо',
              onPressed: _syncAllProvidersAndModels,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _providers.contains(_selectedProvider) ? _selectedProvider : _providers.first,
              isExpanded: true,
              dropdownColor: const Color(0xFF181B28),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              items: _providers.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedProvider = val!;
                  _models = _aiService.getModelsForProvider(_selectedProvider);
                  if (_models.isNotEmpty) _selectedModel = _models.first;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        Text('ИЗБЕРИ МОДЕЛ (${_models.length} НАЛИЧНИ)', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.sciFiCyan.withValues(alpha: 0.4))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _models.contains(_selectedModel) ? _selectedModel : (_models.isNotEmpty ? _models.first : null),
              isExpanded: true,
              menuMaxHeight: 380,
              dropdownColor: const Color(0xFF181B28),
              style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 12, fontWeight: FontWeight.bold),
              items: _models.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) => setState(() => _selectedModel = val!),
            ),
          ),
        ),
        const SizedBox(height: 14),

        const Text('API КЛЮЧ (По избор за платени модели)', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
          child: TextField(
            controller: _apiKeyController,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(hintText: 'sk-or-v1-••••••••••••••••', hintStyle: TextStyle(color: Colors.grey, fontSize: 12), border: InputBorder.none),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.sciFiCyan), padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: _testKey,
                child: const Text('ТЕСТВАЙ ВРЪЗКА', style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.laserPink, padding: const EdgeInsets.symmetric(vertical: 12)),
                icon: const Icon(Icons.sync, color: Colors.white, size: 16),
                label: const Text('СВАЛИ ВСИЧКИ', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: _syncAllProvidersAndModels,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _isSuccess ? const Color(0xFF0D2418) : const Color(0xFF281014), borderRadius: BorderRadius.circular(10)),
          child: Text(_statusMessage, style: TextStyle(color: _isSuccess ? const Color(0xFF00E676) : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
