import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Achievements extends StatefulWidget {
  @override
  _AchievementsState createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  // List of health benefits symbols and descriptions
  final List<Map<String, String>> healthBenefits = [
    {'symbol': '🍎', 'description': 'Eating fruits improves your health.'},
    {'symbol': '🏃‍♂️', 'description': 'Regular exercise keeps you fit.'},
    {'symbol': '💧', 'description': 'Staying hydrated is crucial for your body.'},
    {'symbol': '🛌', 'description': 'Getting enough sleep is important.'},
    {'symbol': '🌞', 'description': 'Sun exposure boosts Vitamin D.'},
    {'symbol': '🧘‍♀️', 'description': 'Meditation reduces stress.'},
    {'symbol': '🥦', 'description': 'Vegetables provide essential nutrients.'},
    {'symbol': '🏋️‍♀️', 'description': 'Strength training builds muscle.'},
    {'symbol': '😴', 'description': 'Quality sleep enhances recovery.'},
  ];

  List<dynamic> unlockedAchievements = [];

  @override
  void initState() {
    super.initState();
    _loadUnlockedAchievements();
  }

  Future<void> _loadUnlockedAchievements() async {
    final Box<dynamic> box = Hive.box('cigarette_tracker');
    setState(() {
      unlockedAchievements = box.get('unlockedAchievements', defaultValue: []) as List<dynamic>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Başarılar'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 columns
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: healthBenefits.length,
        itemBuilder: (context, index) {
          bool isUnlocked = index < unlockedAchievements.length;
          return GestureDetector(
            onTap: isUnlocked
                ? () {
              _showDescription(context, healthBenefits[index]['description']!);
            }
                : null,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.greenAccent : Colors.grey,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                healthBenefits[index]['symbol']!,
                style: TextStyle(
                  fontSize: 50.0,
                  color: isUnlocked ? Colors.black : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDescription(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  description,
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
