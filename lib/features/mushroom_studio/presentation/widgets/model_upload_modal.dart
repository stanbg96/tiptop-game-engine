import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/core/services/auto_rig_service.dart';

class ModelUploadModal extends StatefulWidget {
  final Function(Rigged3DModel model)? onModelRigged;

  const ModelUploadModal({
    Key? key,
    this.onModelRigged,
  }) : super(key: key);

  static void show(BuildContext context, {Function(Rigged3DModel model)? onModelRigged}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.sciFiCyan, width: 1.2),
      ),
      builder: (context) => ModelUploadModal(onModelRigged: onModelRigged),
    );
  }

  @override
  State<ModelUploadModal> createState() => _ModelUploadModalState();
}

class _ModelUploadModalState extends State<ModelUploadModal> {
  final TextEditingController _nameController = TextEditingController(text: 'Cyber_Knight_Mesh');
  String _selectedFormat = 'glb';
  double _estimatedHeight = 1.8;
  bool _isRigging = false;
  String _riggingStatus = '';
  Rigged3DModel? _resultModel;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startAutoRigging() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isRigging = true;
      _riggingStatus = '🔍 Сканиране на Bounding Box и симетрия...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _riggingStatus = '🦴 Изчисляване на 19-точков Humanoid Скелет...');

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _riggingStatus = '⚡ Linear Blend Skinning (Привързване на върховете)...');

    final rigged = await AutoRigService().autoRigImportedModel(
      fileName: '$name.$_selectedFormat',
      filePath: '/storage/models/$name.$_selectedFormat',
      estimatedHeight: _estimatedHeight,
    );

    setState(() {
      _isRigging = false;
      _resultModel = rigged;
      _riggingStatus = '✅ Успешно ригнат: 19 кости • ${rigged.vertexCount} полигона!';
    });

    widget.onModelRigged?.call(rigged);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 18,
          right: 18,
          top: 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.accessibility_new, color: AppTheme.sciFiCyan, size: 22),
                    SizedBox(width: 8),
                    Text('🦴 Качване & Auto-Rigging на 3D Модел', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(color: Colors.white12),

            if (_resultModel == null) ...[
              const Text('ИМЕ НА МОДЕЛА', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(hintText: 'Име на 3D файла...', border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 12),

              const Text('ФОРМАТ НА ФАЙЛА', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: ['glb', 'gltf', 'obj', 'fbx'].map((fmt) {
                  final isSel = fmt == _selectedFormat;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFormat = fmt),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.laserPink : const Color(0xFF181B28),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSel ? AppTheme.laserPink : Colors.white12),
                        ),
                        child: Center(
                          child: Text(fmt.toUpperCase(), style: TextStyle(color: isSel ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('РЪСТ НА ХЮМАНОИДА', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('${_estimatedHeight.toStringAsFixed(1)} m', style: const TextStyle(color: AppTheme.sciFiCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(activeTrackColor: AppTheme.sciFiCyan, thumbColor: AppTheme.laserPink, trackHeight: 3.0),
                child: Slider(
                  value: _estimatedHeight,
                  min: 1.2,
                  max: 2.5,
                  onChanged: (v) => setState(() => _estimatedHeight = v),
                ),
              ),
              const SizedBox(height: 10),

              if (_isRigging) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF141926), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.sciFiCyan.withValues(alpha: 0.5))),
                  child: Row(
                    children: [
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.sciFiCyan)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_riggingStatus, style: const TextStyle(color: AppTheme.sciFiCyan, fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                height: 42,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                    icon: const Icon(Icons.bolt, color: Colors.white, size: 18),
                    label: const Text('СТАРТИРАЙ AUTO-RIGGING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: _isRigging ? null : _startAutoRigging,
                  ),
                ),
              ),
            ] else ...[
              // Резултат
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF0D2418), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00E676))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 22),
                        const SizedBox(width: 8),
                        Text(_resultModel!.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('• 19 кости изчислени успешно\n• Формат: ${_resultModel!.format.toUpperCase()} (${_resultModel!.vertexCount} полигона)\n• Готов за 2000+ анимации от библиотеката!', style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.play_arrow, color: Colors.black, size: 18),
                  label: const Text('ТЕСТВАЙ В АНИМАЦИОННИЯ ПЛЕЙЪР', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('▶ Зареден ригнат модел "${_resultModel!.name}" в Аниматора!')),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
