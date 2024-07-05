//lib/models/achievement.dart
import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 0)
class Achievement {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String category;

  Achievement(
      {required this.title, required this.description, required this.category});
}
