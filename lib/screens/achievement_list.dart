import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:achievement_app/models/achievement.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'achievement_chart.dart';

class AchievementList extends StatefulWidget {
  @override
  _AchievementListState createState() => _AchievementListState();
}

class _AchievementListState extends State<AchievementList> {
  Box<Achievement> achievementBox = Hive.box('achievements');
  ScrollController _scrollController = ScrollController();

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

  void _addAchievement(Achievement achievement) {
    achievementBox.add(achievement);
    _scrollToLatestAchievement();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pencapaian "${achievement.title}" berhasil ditambahkan'),
    ));
  }

  void _deleteAchievement(int index) {
    Achievement? achievement = achievementBox.getAt(index);
    if (achievement != null) {
      achievementBox.deleteAt(index);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pencapaian "${achievement.title}" berhasil dihapus'),
      ));
    }
  }

  void _updateAchievement(int index, Achievement achievement) {
    achievementBox.putAt(index, achievement);
    _scrollToAchievement(index);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Pencapaian "${achievement.title}" berhasil di-update'),
    ));
  }

  void _scrollToLatestAchievement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollToAchievement(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        double position = index * 100.0; // Adjust the offset as needed
        _scrollController.animateTo(
          position,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showAchievementDialog({int? index, Achievement? achievement}) {
    TextEditingController titleController =
        TextEditingController(text: achievement?.title ?? '');
    TextEditingController descriptionController =
        TextEditingController(text: achievement?.description ?? '');
    String selectedCategory = achievement?.category ?? categories[0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(index == null ? 'Tambah Pencapaian' : 'Update Pencapaian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Kategori'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.red, // Warna teks merah untuk tombol 'Batal'
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                index == null ? 'Tambah' : 'Update',
                style: TextStyle(
                  color: Colors
                      .blue, // Warna teks biru untuk tombol 'Tambah' atau 'Update'
                ),
              ),
              onPressed: () {
                if (index == null) {
                  _addAchievement(Achievement(
                    title: titleController.text,
                    description: descriptionController.text,
                    category: selectedCategory,
                  ));
                } else {
                  _updateAchievement(
                    index,
                    Achievement(
                      title: titleController.text,
                      description: descriptionController.text,
                      category: selectedCategory,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index, Achievement achievement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Penghapusan'),
          content: Text(
              'Apakah Anda yakin ingin menghapus pencapaian "${achievement.title}"?'),
          actions: [
            TextButton(
              child: Text(
                'Tidak',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Ya',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _deleteAchievement(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Go Growth'),
        backgroundColor:
            Colors.deepOrange[200], // Sesuaikan dengan warna kategori
        actions: [
          IconButton(
            icon: Icon(Icons.pie_chart),
            tooltip: 'Grafik Pencapaian',
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.vertical,
                      child: child,
                    );
                  },
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AchievementChart(),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: achievementBox.listenable(),
        builder: (context, Box<Achievement> box, _) {
          if (box.values.isEmpty) {
            return Center(
              child: Text('Tidak Ada Pencapaian.'),
            );
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: box.length,
            itemBuilder: (context, index) {
              Achievement? achievement = achievementBox.getAt(index);
              if (achievement == null) return SizedBox.shrink();

              Color itemColor = _getColorForCategory(achievement.category);

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {
                      _showAchievementDialog(
                          index: index, achievement: achievement);
                    },
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      shadowColor: itemColor.withOpacity(0.8),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: itemColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    achievement.title,
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    achievement.description,
                                    style: GoogleFonts.lato(fontSize: 14.0),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Kategori: ${achievement.category}',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Edit Pencapaian',
                                  onPressed: () {
                                    _showAchievementDialog(
                                        index: index, achievement: achievement);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Hapus Pencapaian',
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                        index, achievement);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Pencapaian',
        child: Icon(Icons.add),
        onPressed: () {
          _showAchievementDialog();
        },
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case "Pendidikan":
        return Colors.blue[200]!;
      case "Karier":
        return Colors.green[200]!;
      case "Kesehatan":
        return Colors.orange[200]!;
      case "Keuangan":
        return Colors.purple[200]!;
      case "Hubungan dan Keluarga":
        return Colors.pink[200]!;
      case "Kontribusi Sosial":
        return Colors.teal[200]!;
      case "Kreativitas":
        return Colors.yellow[200]!;
      case "Pengembangan Pribadi":
        return Colors.deepOrange[200]!;
      default:
        return Colors.grey[300]!;
    }
  }
}
