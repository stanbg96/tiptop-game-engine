import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/features/brain_ai/logic/ai_service.dart';

enum MessageType {
  user,
  assistant,
  modelSwitch,
  apiKeyConnected,
  systemAlert,
  engineAction,
  attachment,
}

class ChatMessage {
  final String text;
  final MessageType type;
  final String? subtitle;

  ChatMessage({
    required this.text,
    required this.type,
    this.subtitle,
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
      text: 'Моля, кажи ми какво искаш да построим или коригираме в TipTop Engine!',
      type: MessageType.assistant,
      subtitle: 'Като асистент за TipTop Game Engine мога да ти помагам с:\n• 🎮 Дизайн на механики и геймплей\n• 🗺️ 2D & 3D нива и сцени в Google Filament\n• ⚙️ Настройки на анимации и асети\n• 🧠 Изграждане на логика без код',
    ),
  ];

  String _selectedProvider = '🌐 OpenRouter (Всички)';
  String _selectedModel = '🎁 meta-llama/llama-3.3-70b-instruct:free';
  final TextEditingController _apiKeyController = TextEditingController();
  String _statusMessage = '';
  bool _isSuccess = false;

  final List<String> _providers = [
    '🌐 OpenRouter (Всички)',
    '⚡ Groq (Ултра бърз / Free)',
    '🤖 DeepSeek',
    '🟢 OpenAI',
  ];

  List<String> _models = [
    '🎁 meta-llama/llama-3.3-70b-instruct:free',
    '🎁 deepseek/deepseek-r1:free',
    '🎁 qwen/qwen-2.5-72b-instruct:free',
    '🎁 google/gemini-2.0-flash-exp:free',
    '🎁 mistralai/mistral-7b-instruct:free',
    'openai/gpt-4o',
    'anthropic/claude-3.5-sonnet',
  ];

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

  void _sendMessage() async {
    String text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, type: MessageType.user));
      _chatController.clear();
      _isLoading = true;
    });

    String response = await _aiService.sendPrompt(text, isBuilderMode: _isBuilderMode);

    setState(() {
      _isLoading = false;
      _messages.add(ChatMessage(text: response, type: MessageType.assistant));
      if (_isBuilderMode) {
        _messages.add(ChatMessage(
          text: '⚙️ TipTop C++ Filament Engine изпълни успешно командата!',
          type: MessageType.engineAction,
        ));
      }
    });
  }

  void _syncModels() async {
    setState(() => _isLoading = true);

    _aiService.configure(
      key: _apiKeyController.text,
      selectedProvider: _selectedProvider,
      selectedModel: _selectedModel,
    );

    List<String> downloaded = await _aiService.fetchAvailableModels();

    setState(() {
      _models = downloaded;
      if (_models.isNotEmpty) {
        _selectedModel = _models.first;
      }
      _isLoading = false;
      _messages.add(ChatMessage(
        text: 'Чатагентът превключи на модел: $_selectedModel',
        type: MessageType.modelSwitch,
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Синхронизирани ${_models.length} модела от $_selectedProvider!')),
    );
  }

  void _testKey() async {
    _aiService.configure(
      key: _apiKeyController.text,
      selectedProvider: _selectedProvider,
      selectedModel: _selectedModel,
    );

    setState(() {
      _isLoading = true;
      _statusMessage = 'Тестване на връзката в реално време...';
      _isSuccess = false;
    });

    String result = await _aiService.testConnection();

    setState(() {
      _isLoading = false;
      _statusMessage = result;
      _isSuccess = result.contains('Успешна');
      if (_isSuccess) {
        _messages.add(ChatMessage(
          text: '🔑 API ключът е свързан успешно! Говори свободно чрез $_selectedModel.',
          type: MessageType.apiKeyConnected,
        ));
      }
    });
  }

  void _saveConfiguration() {
    _aiService.configure(
      key: _apiKeyController.text,
      selectedProvider: _selectedProvider,
      selectedModel: _selectedModel,
    );
    setState(() {
      _statusMessage = '🟢 Конфигурацията е запазена успешно!';
      _isSuccess = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Конфигурацията е запазена успешно!')),
    );
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.cyanAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🧠 ', style: TextStyle(fontSize: 20)),
            Text(
              'Future Brain AI',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purpleAccent,
          indicatorWeight: 3,
          labelColor: Colors.purpleAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline, size: 20), text: 'AI Agent'),
            Tab(icon: Icon(Icons.vpn_key_outlined, size: 20), text: 'API Manager'),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF141622),
            border: Border(bottom: BorderSide(color: Color(0xFF222638), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Асистент',
                style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _isBuilderMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: !_isBuilderMode ? Colors.purpleAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'ЧАТ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: !_isBuilderMode ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isBuilderMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _isBuilderMode ? Colors.cyanAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'АГЕНТ',
                          style: TextStyle(
                            color: _isBuilderMode ? Colors.black : Colors.white70,
                            fontSize: 11,
                            fontWeight: _isBuilderMode ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const LinearProgressIndicator(color: Colors.cyanAccent, backgroundColor: Colors.black, minHeight: 2),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _buildMessageItem(_messages[index]),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _messages.add(ChatMessage(text: '📸 Screenshot_Asset.png', type: MessageType.attachment))),
                        child: const Icon(Icons.camera_alt, color: Colors.cyanAccent, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.attach_file, color: Colors.purpleAccent, size: 20),
                      const SizedBox(width: 14),
                      const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 14),
                      const Icon(Icons.sentiment_satisfied_alt, color: Colors.yellowAccent, size: 20),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161824),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: _isBuilderMode ? 'Напиши команда за 3D строене...' : 'Напиши съобщение...',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.cyanAccent]),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _sendMessage,
                          child: const Text('Изпрати', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    switch (msg.type) {
      case MessageType.modelSwitch:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF181028),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              const Text('⚡ ', style: TextStyle(fontSize: 13)),
              Expanded(child: Text(msg.text, style: const TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        );
      case MessageType.apiKeyConnected:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF141926),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              const Text('🔑 ', style: TextStyle(fontSize: 13)),
              Expanded(child: Text(msg.text, style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        );
      case MessageType.systemAlert:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF221A14),
            borderRadius: BorderRadius.circular(10),
            border: const Border(left: BorderSide(color: Colors.amberAccent, width: 3)),
          ),
          child: Text(msg.text, style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w600)),
        );
      case MessageType.engineAction:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10221C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6)),
          ),
          child: Text(msg.text, style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
        );
      case MessageType.attachment:
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3048),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent),
            ),
            child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        );
      case MessageType.user:
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF5D1D86), Color(0xFF381552)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
            ),
            child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        );
      case MessageType.assistant:
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF141724),
              borderRadius: BorderRadius.circular(14),
              border: const Border(left: BorderSide(color: Colors.cyanAccent, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
                if (msg.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(msg.subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                ],
              ],
            ),
          ),
        );
    }
  }

  Widget _buildApiManagerTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF12141F),
            border: Border(bottom: BorderSide(color: Color(0xFF222638), width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ДОСТАВЧИК', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D2C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedProvider,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1A1D2C),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                          items: _providers.map((p) => DropdownMenuItem(value: p, child: Text(p, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedProvider = val!;
                              _models = _aiService.getDefaultModelsFor(_selectedProvider);
                              _selectedModel = _models.first;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('МОДЕЛ', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D2C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _models.contains(_selectedModel) ? _selectedModel : (_models.isNotEmpty ? _models.first : null),
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1A1D2C),
                          style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          items: _models.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) => setState(() => _selectedModel = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF222638),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5)),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.cyanAccent, size: 20),
                    tooltip: 'Свали всички актуални модели',
                    onPressed: _syncModels,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.25),
                          blurRadius: 35,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: Colors.purpleAccent.withValues(alpha: 0.25),
                          blurRadius: 45,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🧠', style: TextStyle(fontSize: 65)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141724),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _selectedModel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (_statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSuccess ? const Color(0xFF0D2418) : const Color(0xFF281014),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isSuccess ? Colors.greenAccent : Colors.redAccent.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                            color: _isSuccess ? Colors.greenAccent : Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                color: _isSuccess ? Colors.greenAccent : const Color(0xFFFF6B7A),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141724),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: '••••••••••••••••••••••••',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.cyanAccent, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: _testKey,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🧪 ', style: TextStyle(fontSize: 12)),
                          Text(
                            'ТЕСТВАЙ',
                            style: TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 42,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2979FF), Color(0xFFAA00FF)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: _saveConfiguration,
                        child: const Text(
                          'СВЪРЖИ',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
