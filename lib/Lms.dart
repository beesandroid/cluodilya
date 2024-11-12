import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';
// Uncomment the following line if you plan to use Rive animations
// import 'package:rive/rive.dart';

void main() {
  runApp(const PremiumLmsApp());
}

class PremiumLmsApp extends StatelessWidget {
  const PremiumLmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Colors.blue.shade700,
        scaffoldBackgroundColor: Colors.white,

        // Define the default font family.
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),

        // Define the AppBar theme with white text and icons
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),

        // Define the default icon theme.
        iconTheme: const IconThemeData(
          color: Colors.white, // Changed to white for consistency
        ),
      ),
      home: const Lms(),
    );
  }
}

class Lms extends StatefulWidget {
  const Lms({super.key});

  @override
  State<Lms> createState() => _LmsState();
}

class _LmsState extends State<Lms> with TickerProviderStateMixin {
  // Predefined subjects for each semester
  final List<List<String>> semesterSubjects = [
    // Year 1, Semester 1
    [
      'Introduction to Programming',
      'Mathematics I',
      'Computer Organization',
      'Discrete Mathematics',
      'Physics'
    ],
    // Year 1, Semester 2
    [
      'Data Structures',
      'Mathematics II',
      'Digital Logic',
      'Object-Oriented Programming',
      'Elective I'
    ],
    // Year 2, Semester 1
    [
      'Algorithms',
      'Operating Systems',
      'Database Systems',
      'Computer Networks',
      'Elective II'
    ],
    // Year 2, Semester 2
    [
      'Software Engineering',
      'Theory of Computation',
      'Web Technologies',
      'Artificial Intelligence',
      'Elective III'
    ],
    // Year 3, Semester 1
    [
      'Machine Learning',
      'Mobile Application Development',
      'Cloud Computing',
      'Cyber Security',
      'Elective IV'
    ],
    // Year 3, Semester 2
    [
      'Data Mining',
      'Internet of Things',
      'Big Data Analytics',
      'Distributed Systems',
      'Elective V'
    ],
    // Year 4, Semester 1
    [
      'Advanced Algorithms',
      'Compiler Design',
      'Human-Computer Interaction',
      'Blockchain Technology',
      'Elective VI'
    ],
    // Year 4, Semester 2
    [
      'Natural Language Processing',
      'Quantum Computing',
      'Virtual Reality',
      'Robotics',
      'Elective VII'
    ],
  ];

  // Sample data for years, semesters, and materials
  late final List<YearModel> years;

  @override
  void initState() {
    super.initState();
    years = List.generate(4, (yearIndex) {
      return YearModel(
        name: 'Year ${yearIndex + 1}',
        semesters: List.generate(2, (semIndex) {
          // Calculate the global semester index
          int globalSemIndex = yearIndex * 2 + semIndex;
          return Semester(
            name: 'Semester ${semIndex + 1}',
            materials: semesterSubjects[globalSemIndex].expand((subject) {
              // Assign type based on index: even index -> PDF, odd -> Video
              int subjectIndex =
              semesterSubjects[globalSemIndex].indexOf(subject);
              return [
                MaterialItem(
                  title: '$subject - PDF',
                  type: MaterialType.pdf,
                  url:
                  'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
                ),
                MaterialItem(
                  title: '$subject - Video',
                  type: MaterialType.video,
                  url:
                  'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
                ),
              ];
            }).toList(),
          );
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Animated gradient background
      body: AnimatedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Learning',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 1000),
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: ExpansionTile(
                          leading: AnimatedIconWidget(
                            icon: Icons.calendar_month,
                            color: Colors.blue,
                          ),
                          title: Text(
                            year.name,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.expand_more,
                            color: Colors.black54,
                          ),
                          children: year.semesters.map((semester) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 1000),
                                child: SlideAnimation(
                                  child: FadeInAnimation(
                                    child: ExpansionTile(
                                      leading: AnimatedIconWidget(
                                        icon: Icons.school_rounded,
                                        color: Colors.green,
                                      ),
                                      title: Text(
                                        semester.name,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.expand_more,
                                        color: Colors.black54,
                                      ),
                                      children: [
                                        // PDFs ExpansionTile
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(left: 16.0),
                                          child: AnimationConfiguration.staggeredList(
                                            position: index,
                                            duration: const Duration(milliseconds: 1000),
                                            child: SlideAnimation(
                                              horizontalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: ExpansionTile(
                                                  leading: FaIcon(
                                                    FontAwesomeIcons.filePdf,
                                                    color: Colors.redAccent,
                                                  ),
                                                  title: Text(
                                                    'PDFs',
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  children: semester.materials
                                                      .where((m) => m.type == MaterialType.pdf)
                                                      .map((pdf) {
                                                    return Padding(
                                                      padding:
                                                      const EdgeInsets.only(left: 16.0),
                                                      child: ListTile(
                                                        leading: FaIcon(
                                                          FontAwesomeIcons.filePdf,
                                                          color: Colors.redAccent,
                                                          size: 24,
                                                        ),
                                                        title: Text(
                                                          pdf.title,
                                                          style: GoogleFonts.montserrat(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                        trailing: IconButton(
                                                          icon: const Icon(
                                                            Icons.download_rounded,
                                                            color: Colors.blueAccent,
                                                          ),
                                                          onPressed: () =>
                                                              _downloadFile(context, pdf),
                                                          tooltip: 'Download PDF',
                                                        ),
                                                        onTap: () =>
                                                            _openMaterial(context, pdf),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Videos ExpansionTile
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(left: 16.0),
                                          child: AnimationConfiguration.staggeredList(
                                            position: index,
                                            duration: const Duration(milliseconds: 1000),
                                            child: SlideAnimation(
                                              horizontalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: ExpansionTile(
                                                  leading: FaIcon(
                                                    FontAwesomeIcons.youtube,
                                                    color: Colors.blueAccent,
                                                  ),
                                                  title: Text(
                                                    'Videos',
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  children: semester.materials
                                                      .where((m) => m.type == MaterialType.video)
                                                      .map((video) {
                                                    return Padding(
                                                      padding:
                                                      const EdgeInsets.only(left: 16.0),
                                                      child: ListTile(
                                                        leading: FaIcon(
                                                          FontAwesomeIcons.youtube,
                                                          color: Colors.blueAccent,
                                                          size: 24,
                                                        ),
                                                        title: Text(
                                                          video.title,
                                                          style: GoogleFonts.montserrat(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                        trailing: IconButton(
                                                          icon: const Icon(
                                                            Icons.play_circle,
                                                            color: Colors.blueAccent,
                                                          ),
                                                          onPressed: () =>
                                                              _openMaterial(context, video),
                                                          tooltip: 'Play Video',
                                                        ),
                                                        onTap: () =>
                                                            _openMaterial(context, video),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        ),
      ),
    );
  }

  // Function to handle file downloads
  Future<void> _downloadFile(BuildContext context, MaterialItem material) async {
    // Check and request storage permissions
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required.')),
          );
          return;
        }
      }
    }

    // Show a snackbar while downloading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${material.title}...')),
    );

    try {
      // Get the download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/Download";
        directory = Directory(newPath);
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Download the file
      String fileName = material.url.split('/').last;
      String savePath = '${directory.path}/$fileName';

      await Dio().download(material.url, savePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${material.title} downloaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download ${material.title}.')),
      );
    }
  }

  // Function to handle opening materials
  void _openMaterial(BuildContext context, MaterialItem material) {
    if (material.type == MaterialType.video) {
      // Handle video playback
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(url: material.url),
        ),
      );
    } else if (material.type == MaterialType.pdf) {
      // Handle PDF viewing
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(url: material.url),
        ),
      );
    }
  }
}

// Animated Background Widget
class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: Colors.white,
      end: Colors.white,
    ).animate(_controller);

    _colorAnimation2 = ColorTween(
      begin: Colors.white,
      end: Colors.white,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorAnimation1.value ?? Colors.blue.shade900,
                _colorAnimation2.value ?? Colors.blue.shade400,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Animated Icon Widget using a simple rotation for demonstration
class AnimatedIconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;

  const AnimatedIconWidget({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder for Rive animation
    // To implement Rive, replace this with RiveAnimation.asset
    // Ensure you have the .riv file in your assets and declared in pubspec.yaml
    return RotationTransition(
      turns: const AlwaysStoppedAnimation(0.1),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}

// Screen to Play Videos
class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // Implement video playback functionality here using a package like video_player
  // Example implementation using video_player package:

  /*
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Video Playback Not Implemented',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

// Screen to View PDFs
class PdfViewerScreen extends StatelessWidget {
  final String url;

  const PdfViewerScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement PDF viewing functionality here using a package like flutter_pdfview
    // Example implementation using flutter_pdfview package:

    /*
    String localPath = '';

    Future<void> _downloadAndSavePdf() async {
      try {
        var dio = Dio();
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = '${tempDir.path}/temp.pdf';
        await dio.download(url, tempPath);
        localPath = tempPath;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: $e')),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return FutureBuilder(
        future: _downloadAndSavePdf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (localPath.isNotEmpty) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('PDF Viewer'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                body: PDFView(
                  filePath: localPath,
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('PDF Viewer'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                body: const Center(
                  child: Text(
                    'Failed to load PDF',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              );
            }
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text('PDF Viewer'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      );
    }
    */

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'PDF Viewer Not Implemented',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}

// Data Models
class YearModel {
  final String name;
  final List<Semester> semesters;

  YearModel({required this.name, required this.semesters});
}

class Semester {
  final String name;
  final List<MaterialItem> materials;

  Semester({required this.name, required this.materials});
}

enum MaterialType { pdf, video }

class MaterialItem {
  final String title;
  final MaterialType type;
  final String url;

  MaterialItem({
    required this.title,
    required this.type,
    required this.url,
  });
}
