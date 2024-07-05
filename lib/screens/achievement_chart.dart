import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:achievement_app/models/achievement.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class AchievementChart extends StatefulWidget {
  @override
  _AchievementChartState createState() => _AchievementChartState();
}

class _AchievementChartState extends State<AchievementChart> {
  List<PieChartSectionData> _sections = [];
  Map<String, double> _totalAchievements = {};
  int? touchedIndex;

  bool _isLoading =
      true; // State untuk menentukan apakah sedang loading atau tidak

  @override
  void initState() {
    super.initState();
    _loadData(); // Panggil fungsi untuk memuat data
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration(
        seconds: 2)); // Contoh penundaan untuk simulasi pengambilan data

    _sections = _buildSections();
    _totalAchievements = _calculateTotalAchievements();

    setState(() {
      _isLoading = false; // Setelah selesai memuat data, nonaktifkan loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grafik Pencapaian',
          style: GoogleFonts.roboto(
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.deepOrange[200],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Shimmer(
        duration: Duration(seconds: 2), // Durasi animasi shimmer
        color: Colors.grey[300]!,
        enabled: true, // Aktifkan shimmer
        child:
            CircularProgressIndicator(), // Atur widget loading yang ingin ditampilkan
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          _buildTotalAchievementsText(),
          SizedBox(height: 20),
          _buildAnimatedPieChart(),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCategoryLegend(),
          ),
          SizedBox(height: 20),
          _buildAchievementsList(),
        ],
      ),
    );
  }

  Widget _buildTotalAchievementsText() {
    return Center(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: Shimmer(
          duration: Duration(seconds: 2),
          color: Colors.deepOrange[200]!,
          enabled: true,
          direction: ShimmerDirection.fromLTRB(),
          child: Text(
            'Total Pencapaian: ${_getTotalAchievements()}',
            style: GoogleFonts.roboto(
              fontSize: 24,
              color: Colors.deepOrange,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPieChart() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Shimmer(
            duration: Duration(seconds: 2),
            color: Colors.grey[300]!,
            enabled: true,
            direction: ShimmerDirection.fromLTRB(),
            child: AnimatedPieChart(
              sections: _sections,
              touchedIndex: touchedIndex,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryLegend() {
    List<String> categories = [
      "Pendidikan",
      "Karier",
      "Kesehatan",
      "Keuangan",
      "Hubungan dan Keluarga",
      "Kontribusi Sosial",
      "Kreativitas",
      "Pengembangan Pribadi"
    ];

    List<Color> colors = [
      Colors.blue[200]!,
      Colors.green[200]!,
      Colors.orange[200]!,
      Colors.purple[200]!,
      Colors.pink[200]!,
      Colors.teal[200]!,
      Colors.yellow[200]!,
      Colors.deepOrange[200]!,
    ];

    return Column(
      children: List.generate(categories.length, (index) {
        String category = categories[index];
        Color color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: FadeTransition(
                  opacity: AlwaysStoppedAnimation(1),
                  child: Shimmer(
                    duration: Duration(seconds: 2),
                    color: Colors.grey[300]!,
                    enabled: true,
                    direction: ShimmerDirection.fromLTRB(),
                    child: Text(
                      category,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Shimmer(
                duration: Duration(seconds: 2),
                color: Colors.grey[300]!,
                enabled: true,
                direction: ShimmerDirection.fromLTRB(),
                child: Text(
                  '${_totalAchievements[category] ?? 0}',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAchievementsList() {
    Box<Achievement> achievementBox = Hive.box<Achievement>('achievements');

    return Column(
      children: List.generate(achievementBox.length, (index) {
        Achievement achievement = achievementBox.getAt(index)!;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.deepOrange),
              title: Text(
                achievement.title,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                achievement.description,
                style: GoogleFonts.lato(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  List<PieChartSectionData> _buildSections() {
    List<String> categories = [
      "Pendidikan",
      "Karier",
      "Kesehatan",
      "Keuangan",
      "Hubungan dan Keluarga",
      "Kontribusi Sosial",
      "Kreativitas",
      "Pengembangan Pribadi"
    ];

    List<Color> colors = [
      Colors.blue[200]!,
      Colors.green[200]!,
      Colors.orange[200]!,
      Colors.purple[200]!,
      Colors.pink[200]!,
      Colors.teal[200]!,
      Colors.yellow[200]!,
      Colors.deepOrange[200]!,
    ];

    List<PieChartSectionData> sections = [];

    _totalAchievements = _calculateTotalAchievements();

    for (int i = 0; i < categories.length; i++) {
      String category = categories[i];
      double value = _totalAchievements.containsKey(category)
          ? _totalAchievements[category]!
          : 0.0;
      Color color = colors[i % colors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
          title: '${value.toInt()}',
          radius: 100,
          titleStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Map<String, double> _calculateTotalAchievements() {
    Box<Achievement> achievementBox = Hive.box<Achievement>('achievements');
    Map<String, double> totalAchievements = {};

    for (int i = 0; i < achievementBox.length; i++) {
      Achievement achievement = achievementBox.getAt(i)!;
      if (totalAchievements.containsKey(achievement.category)) {
        totalAchievements[achievement.category] =
            totalAchievements[achievement.category]! + 1;
      } else {
        totalAchievements[achievement.category] = 1;
      }
    }

    return totalAchievements;
  }

  int _getTotalAchievements() {
    int total = _totalAchievements.values
        .reduce((value, element) => value + element)
        .toInt();
    return total;
  }
}

class AnimatedPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final int? touchedIndex;

  AnimatedPieChart({required this.sections, this.touchedIndex});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        pieTouchData: PieTouchData(
          touchCallback:
              (FlTouchEvent touchEvent, PieTouchResponse? touchResponse) {},
        ),
      ),
    );
  }
}
