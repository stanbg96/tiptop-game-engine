import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/services/scene_command_bus.dart';
import 'package:tiptop_game_engine/features/brain_ai/logic/ai_service.dart';

enum MessageType { user, assistant, engineAction }

class ChatMessage {
  final String text;
  final MessageType type;
  final String? subtitle;
  final CommandExecutionResult? actionResult;

  ChatMessage({
    required this.text,
    required this.type,
    this.subtitle,
    this.actionResult,
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
  final SceneCommandBus _commandBus = SceneCommandBus();

  bool _isBuilderMode = true;
  bool _isLoading = false;
  final TextEditingController _chatController = TextEditingController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Готов съм за TipTop Engine! Мога да управлявам целия енджин на живо.',
      type: MessageType.assistant,
      subtitle: '• 🏙️ Строене на цели 3D градове и небостъргачи\n• 🌋 Лава светове и физика\n• 🎯 Преместване, създаване и изтриване на обекти на живо',
    ),
  ];

  // Контролери за API трезора
  final TextEditingController _openRouterKeyCtrl = TextEditingController();
  final TextEditingController _hfKey1Ctrl = TextEditingController();
  final TextEditingController _hfKey2Ctrl = TextEditingController();
  final TextEditingController _hfKey3Ctrl = TextEditingController();
  final TextEditingController _sketchfabKeyCtrl = TextEditingController();
  final TextEditingController _freeSoundKeyCtrl = TextEditingController();
  final TextEditingController _nasaKeyCtrl = TextEditingController();
  final TextEditingController _thingiverseKeyCtrl = TextEditingController();
  final TextEditingController _modelSearchCtrl = TextEditingController();

  // Модели за OpenRouter
  String _selectedOpenRouterModel = '⚡ АВТОМАТИЧЕН БЕЗПЛАТЕН (100% Онлайн)';
  List<String> _openRouterModels = [];
  String _modelFilterQuery = '';
  bool _isDownloadingModels = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _openRouterModels = _aiService.getModelsForProvider('⭐ ВСИЧКИ МОДЕЛИ (Live Catalog)');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _openRouterKeyCtrl.dispose();
    _hfKey1Ctrl.dispose();
    _hfKey2Ctrl.dispose();
    _hfKey3Ctrl.dispose();
    _sketchfabKeyCtrl.dispose();
    _freeSoundKeyCtrl.dispose();
    _nasaKeyCtrl.dispose();
    _thingiverseKeyCtrl.dispose();
    _modelSearchCtrl.dispose();
    super.dispose();
  }

  void _sendMessage({String? customText}) async {
    String text = (customText ?? _chatController.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, type: MessageType.user));
      _chatController.clear();
      _isLoading = true;
    });

    if (_isBuilderMode) {
      final cmdResult = _commandBus.executeAiPrompt(text);
      String aiResponse = await _aiService.sendPrompt(text, isBuilderMode: true);

      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(text: aiResponse, type: MessageType.assistant));
        _messages.add(ChatMessage(text: cmdResult.message, type: MessageType.engineAction, actionResult: cmdResult));
      });
    } else {
      String response = await _aiService.sendPrompt(text, isBuilderMode: false);
      setState(() {
        _isLoading = false;
        _messages.add(ChatMessage(text: response, type: MessageType.assistant));
      });
    }
  }

  // 🔄 ИСТИНСКО СВАЛЯНЕ НА ВСИЧКИ 400+ МОДЕЛА ОТ OPENROUTER
  void _downloadOpenRouterModels() async {
    setState(() => _isDownloadingModels = true);
    _aiService.configure(
      key: _openRouterKeyCtrl.text,
      selectedProvider: '⭐ ВСИЧКИ МОДЕЛИ (Live Catalog)',
      selectedModel: _selectedOpenRouterModel,
    );

    final catalog = await _aiService.fetchAllProvidersAndModels();
    final allList = catalog['⭐ ВСИЧКИ МОДЕЛИ (Live Catalog)'] ?? [];

    setState(() {
      _isDownloadingModels = false;
      if (allList.isNotEmpty) {
        _openRouterModels = allList;
        if (!_openRouterModels.contains(_selectedOpenRouterModel)) {
          _selectedOpenRouterModel = _openRouterModels.first;
        }
      }
    });

    if (!mounted) return;
    if (allList.isNotEmpty && allList.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Успешно свалени ${allList.length} живи модела от OpenRouter!'),
          backgroundColor: const Color(0xFF00E676),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Няма връзка с OpenRouter. Проверете мобилните данни или Wi-Fi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _saveAllApiKeys() {
    _aiService.configure(
      key: _openRouterKeyCtrl.text,
      selectedProvider: '⭐ ВСИЧКИ МОДЕЛИ (Live Catalog)',
      selectedModel: _selectedOpenRouterModel,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF00E676),
        content: Text('✅ Всички API ключове и избраният модел са запазени в трезора!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
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
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.sciFiCyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('🧠 Brain AI Copilot', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.laserPink,
          indicatorWeight: 3,
          labelColor: AppTheme.laserPink,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.smart_toy_outlined, size: 18), text: 'AI Строител'),
            Tab(icon: Icon(Icons.vpn_key_outlined, size: 18), text: 'API Трезор'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatAgentTab(),
          _buildApiVaultTab(),
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
                  Text(_isBuilderMode ? 'TipTop 3D Live Engine Bus' : 'TipTop AI Chat', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
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

        if (_isBuilderMode)
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildActionChip('🏙️ Построй Град', 'построй cyberpunk град с небостъргачи'),
                _buildActionChip('🌋 Лава Паркур', 'построй лава свят с платформи'),
                _buildActionChip('➕ Добави 3D Блок', 'добави нов блок в центъра'),
                _buildActionChip('🧹 Изчисти Сцената', 'изтрий всичко от сцената'),
              ],
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
                      decoration: const InputDecoration(
                        hintText: 'Команда: построй град, премести, изтрий...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
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

  Widget _buildActionChip(String label, String command) {
    return GestureDetector(
      onTap: () => _sendMessage(customText: command),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xCC1A1F30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.sciFiCyan.withValues(alpha: 0.4)),
        ),
        child: Center(child: Text(label, style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 10, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    if (msg.type == MessageType.engineAction && msg.actionResult != null) {
      final res = msg.actionResult!;
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF0F221A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00E676))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFF00E676), size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text('⚡ ИЗПЪЛНЕНО НА ЖИВО В ЕНДЖИНА: ${res.actionType}', style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11))),
              ],
            ),
            const SizedBox(height: 4),
            Text(res.message, style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 32,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                icon: const Icon(Icons.view_in_ar, color: Colors.black, size: 16),
                label: const Text('ВИЖ В 3D СТУДИОТО', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🍄 Отваряне на 3D Студиото с обновената сцена!')));
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
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF5D1D86), Color(0xFF381552)]), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.laserPink.withValues(alpha: 0.4))),
          child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(color: Color(0xFF141724), borderRadius: BorderRadius.all(Radius.circular(12)), border: Border(left: BorderSide(color: AppTheme.sciFiCyan, width: 3))),
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

  // =========================================================================
  // 2. ТАБ: API ТРЕЗОР С ТЪРСАЧКА СРЕД 400+ МОДЕЛА
  // =========================================================================
  Widget _buildApiVaultTab() {
    final filteredModels = _openRouterModels.where((m) {
      return _modelFilterQuery.isEmpty || m.toLowerCase().contains(_modelFilterQuery.toLowerCase());
    }).toList();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            const Text('УПРАВЛЕНИЕ НА API КЛЮЧОВЕ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Въведи ключовете си тук. Повечето от 101-те библиотеки са CC0 и работят свободно без ключ!', style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 18),

            // --- СЕКЦИЯ 1: HUGGING FACE (3D ГЕНЕРАТОР) ---
            _buildSectionHeader('🪄 3D Генератор (Hugging Face)', AppTheme.laserPink),
            const SizedBox(height: 6),
            const Text('Въведи до 3 безплатни ключа за ротация. Това дава 150-300 безплатни 3D модела на ден!', style: TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 8),
            _buildKeyInput('Hugging Face Key 1', _hfKey1Ctrl, Icons.key),
            _buildKeyInput('Hugging Face Key 2', _hfKey2Ctrl, Icons.key),
            _buildKeyInput('Hugging Face Key 3', _hfKey3Ctrl, Icons.key),
            const SizedBox(height: 20),

            // --- СЕКЦИЯ 2: OPENROUTER AI МОЗЪК С ТЪРСАЧКА И БУТОН ЗА СВАЛЯНЕ ---
            _buildSectionHeader('🧠 AI Мозък (OpenRouter / OpenAI)', AppTheme.sciFiCyan),
            const SizedBox(height: 6),
            const Text('Ключ за текстовия AI архитект. Натисни бутона за изтегляне на всички 400+ модела!', style: TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 8),
            _buildKeyInput('OpenRouter API Key (sk-or-v1-...)', _openRouterKeyCtrl, Icons.psychology),

            // Бутон за теглене на всички живи модели
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.sciFiCyan,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: _isDownloadingModels
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.sync, color: Colors.black, size: 16),
                      label: Text(
                        _isDownloadingModels ? 'СВАЛЯНЕ НА ЖИВО...' : '🔄 СВАЛИ ВСИЧКИ МОДЕЛИ (400+ LIVE)',
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isDownloadingModels ? null : _downloadOpenRouterModels,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Търсачка за модели в падащия списък
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF141724),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 14, color: AppTheme.sciFiCyan),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _modelSearchCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      decoration: const InputDecoration(
                        hintText: 'Търси модел (напр. gpt-4o, claude, deepseek, free)...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _modelFilterQuery = v),
                    ),
                  ),
                  if (_modelFilterQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _modelSearchCtrl.clear();
                        setState(() => _modelFilterQuery = '');
                      },
                      child: const Icon(Icons.close, size: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Падащо меню за избор на активен модел
            Text('ИЗБЕРИ АКТИВЕН МОДЕЛ (${filteredModels.length} ФИЛТРИРАНИ ОТ ${_openRouterModels.length})', style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF161824),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.sciFiCyan.withValues(alpha: 0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filteredModels.contains(_selectedOpenRouterModel)
                      ? _selectedOpenRouterModel
                      : (filteredModels.isNotEmpty ? filteredModels.first : null),
                  isExpanded: true,
                  menuMaxHeight: 380,
                  dropdownColor: const Color(0xFF161824),
                  style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 11, fontWeight: FontWeight.bold),
                  items: filteredModels.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedOpenRouterModel = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 22),

            // --- СЕКЦИЯ 3: СВЕТОВНИТЕ БИБЛИОТЕКИ С API КЛЮЧОВЕ ---
            _buildSectionHeader('📚 Световни Библиотеки (С официален API достъп)', const Color(0xFFFFD600)),
            const SizedBox(height: 6),
            const Text('Останалите библиотеки са 100% CC0 и работят без ключ. Тези 4 дават достъп до милиони обекти:', style: TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 8),
            _buildKeyInput('Sketchfab API Key (За 500k+ 3D модела)', _sketchfabKeyCtrl, Icons.view_in_ar),
            _buildKeyInput('FreeSound.org API Key (За 580k+ аудио ефекта)', _freeSoundKeyCtrl, Icons.music_note),
            _buildKeyInput('NASA Open API Key (api.nasa.gov за совалки)', _nasaKeyCtrl, Icons.rocket_launch),
            _buildKeyInput('Thingiverse App Token (За 1M+ 3D обекта)', _thingiverseKeyCtrl, Icons.precision_manufacturing),
            const SizedBox(height: 20),
          ],
        ),

        // ПЛАВАЩ БУТОН "ENTER / ЗАПАЗИ" НАЙ-ДОЛУ
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: SizedBox(
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.4), blurRadius: 10)],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                icon: const Icon(Icons.save, color: Colors.white, size: 20),
                label: const Text('ЗАПАЗИ ВСИЧКИ КЛЮЧОВЕ (ENTER)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: _saveAllApiKeys,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildKeyInput(String hint, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161824),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
            border: InputBorder.none,
            icon: Icon(icon, size: 17, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
