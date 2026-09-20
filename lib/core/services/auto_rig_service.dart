import 'package:flutter/material.dart';

class ModelJoint {
  final String name;
  final double x;
  final double y;
  final double z;
  final String? parent;

  ModelJoint({
    required this.name,
    required this.x,
    required this.y,
    required this.z,
    this.parent,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'x': x,
    'y': y,
    'z': z,
    'parent': parent,
  };
}

class Rigged3DModel {
  final String id;
  final String name;
  final String filePath;
  final String format; // 'glb', 'gltf', 'obj', 'fbx'
  final int vertexCount;
  final bool isAutoRigged;
  final List<ModelJoint> skeletonJoints;
  final Color baseColor;

  Rigged3DModel({
    required this.id,
    required this.name,
    required this.filePath,
    required this.format,
    required this.vertexCount,
    required this.isAutoRigged,
    required this.skeletonJoints,
    this.baseColor = Colors.cyanAccent,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'filePath': filePath,
    'format': format,
    'vertexCount': vertexCount,
    'isAutoRigged': isAutoRigged,
    'skeletonJoints': skeletonJoints.map((j) => j.toMap()).toList(),
    'baseColor': baseColor.toARGB32(),
  };
}

class AutoRigService {
  static final AutoRigService _instance = AutoRigService._internal();
  factory AutoRigService() => _instance;
  AutoRigService._internal();

  final List<Rigged3DModel> _userCustomModels = [
    Rigged3DModel(
      id: 'custom_cyber_samurai',
      name: 'Cyber Samurai (Uploaded)',
      filePath: '/storage/models/cyber_samurai.glb',
      format: 'glb',
      vertexCount: 4250,
      isAutoRigged: true,
      skeletonJoints: _generateHumanoidSkeleton(height: 1.8),
      baseColor: const Color(0xFFD500F9),
    ),
  ];

  List<Rigged3DModel> get customModels => List.unmodifiable(_userCustomModels);

  // 1. АВТОМАТИЧЕН РИГВАНЕ АЛГОРИТЪМ
  Future<Rigged3DModel> autoRigImportedModel({
    required String fileName,
    required String filePath,
    double estimatedHeight = 1.8,
  }) async {
    // Симулация на сканиране на мрежата
    await Future.delayed(const Duration(milliseconds: 600));

    String format = fileName.split('.').last.toLowerCase();
    int vertexCount = 2800 + (fileName.length * 150);

    // Генериране на 19-точков стандартен скелет
    List<ModelJoint> generatedJoints = _generateHumanoidSkeleton(height: estimatedHeight);

    final riggedModel = Rigged3DModel(
      id: 'rigged_${DateTime.now().millisecondsSinceEpoch}',
      name: fileName.replaceAll('.$format', ''),
      filePath: filePath,
      format: format,
      vertexCount: vertexCount,
      isAutoRigged: true,
      skeletonJoints: generatedJoints,
      baseColor: const Color(0xFF00E5FF),
    );

    _userCustomModels.add(riggedModel);
    return riggedModel;
  }

  // 2. ГЕНЕРАТОР НА СТАНДАРТЕН СУБ-ХЮМАНОИД СЕМАНТИЧЕН СКЕЛЕТ
  static List<ModelJoint> _generateHumanoidSkeleton({required double height}) {
    double scale = height / 1.8;

    return [
      // Корен и Гръбнак
      ModelJoint(name: 'Hips', x: 0.0, y: 0.95 * scale, z: 0.0),
      ModelJoint(name: 'Spine', x: 0.0, y: 1.15 * scale, z: 0.0, parent: 'Hips'),
      ModelJoint(name: 'Chest', x: 0.0, y: 1.35 * scale, z: 0.0, parent: 'Spine'),
      ModelJoint(name: 'Neck', x: 0.0, y: 1.50 * scale, z: 0.0, parent: 'Chest'),
      ModelJoint(name: 'Head', x: 0.0, y: 1.70 * scale, z: 0.0, parent: 'Neck'),

      // Лява Ръка
      ModelJoint(name: 'LeftShoulder', x: -0.18 * scale, y: 1.45 * scale, z: 0.0, parent: 'Chest'),
      ModelJoint(name: 'LeftArm', x: -0.38 * scale, y: 1.40 * scale, z: 0.0, parent: 'LeftShoulder'),
      ModelJoint(name: 'LeftForeArm', x: -0.62 * scale, y: 1.40 * scale, z: 0.0, parent: 'LeftArm'),
      ModelJoint(name: 'LeftHand', x: -0.82 * scale, y: 1.40 * scale, z: 0.0, parent: 'LeftForeArm'),

      // Дясна Ръка
      ModelJoint(name: 'RightShoulder', x: 0.18 * scale, y: 1.45 * scale, z: 0.0, parent: 'Chest'),
      ModelJoint(name: 'RightArm', x: 0.38 * scale, y: 1.40 * scale, z: 0.0, parent: 'RightShoulder'),
      ModelJoint(name: 'RightForeArm', x: 0.62 * scale, y: 1.40 * scale, z: 0.0, parent: 'RightArm'),
      ModelJoint(name: 'RightHand', x: 0.82 * scale, y: 1.40 * scale, z: 0.0, parent: 'RightForeArm'),

      // Ляв Крак
      ModelJoint(name: 'LeftUpLeg', x: -0.15 * scale, y: 0.90 * scale, z: 0.0, parent: 'Hips'),
      ModelJoint(name: 'LeftLeg', x: -0.16 * scale, y: 0.50 * scale, z: 0.0, parent: 'LeftUpLeg'),
      ModelJoint(name: 'LeftFoot', x: -0.16 * scale, y: 0.08 * scale, z: 0.08 * scale, parent: 'LeftLeg'),

      // Десен Крак
      ModelJoint(name: 'RightUpLeg', x: 0.15 * scale, y: 0.90 * scale, z: 0.0, parent: 'Hips'),
      ModelJoint(name: 'RightLeg', x: 0.16 * scale, y: 0.50 * scale, z: 0.0, parent: 'RightUpLeg'),
      ModelJoint(name: 'RightFoot', x: 0.16 * scale, y: 0.08 * scale, z: 0.08 * scale, parent: 'RightLeg'),
    ];
  }
}
