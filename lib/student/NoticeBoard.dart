import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'dart:typed_data'; // For Uint8List

class Noticeboard extends StatefulWidget {
  const Noticeboard({super.key});

  @override
  State<Noticeboard> createState() => _NoticeboardState();
}

class _NoticeboardState extends State<Noticeboard> {
  List<Notice> notices = [];
  List<Notice> filteredNotices = [];
  bool isLoading = true;
  bool showInstruction = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNotices();
    _searchController.addListener(_filterNotices);
  }

  Future<void> fetchNotices() async {
    setState(() {
      isLoading = true;
      showInstruction = false; // Hide instruction message after loading begins
    });

    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/NoticeBoardDisplay');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "grpCode": "BeesDev",
        "colCode": "0001",
        "CollegeId": 1,
        "Id": 0,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> noticeList = jsonDecode(response.body);
      setState(() {
        notices = noticeList.map((json) => Notice.fromJson(json)).toList();
        filteredNotices =
            List.from(notices); // Initialize filteredNotices with all notices
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterNotices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredNotices =
            List.from(notices); // Reset to show all notices if search is empty
      } else {
        filteredNotices = notices
            .where((notice) => notice.noticeTitle.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (showInstruction)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Swipe down to refresh the notice list.',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title...',
                hintStyle: GoogleFonts.roboto(
                  textStyle: const TextStyle(color: Colors.grey),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    color: Colors.white, backgroundColor: Colors.blue,
                    onRefresh: fetchNotices, // Swipe down to refresh
                    child: filteredNotices.isEmpty
                        ? const Center(
                            child: Text(
                              "No Notices Found",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredNotices.length,
                            itemBuilder: (context, index) {
                              final notice = filteredNotices[index];
                              return NoticeCard(notice: notice);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class Notice {
  final String noticeTitle;
  final String employeeName;
  final String description;
  final String eventDate;
  final String startTime;
  final String endTime;
  final String uploadPhoto;
  final String location;
  final String headerDescription;
  final String requestDate;

  Notice({
    required this.noticeTitle,
    required this.employeeName,
    required this.description,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.uploadPhoto,
    required this.location,
    required this.headerDescription,
    required this.requestDate,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      noticeTitle: json['noticeTitle'],
      employeeName: json['employeeName'],
      description: json['description'],
      eventDate: json['eventDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      uploadPhoto: json['uploadPhoto'],
      location: json['location'],
      headerDescription: json['headerDescription'],
      requestDate: json['requestDate'],
    );
  }
}

class NoticeCard extends StatelessWidget {
  final Notice notice;

  const NoticeCard({Key? key, required this.notice}) : super(key: key);

  bool isLive() {
    final eventDate =
        DateFormat('MM/dd/yyyy hh:mm:ss a').parse(notice.eventDate);
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  bool isUpcoming() {
    final eventDate =
        DateFormat('MM/dd/yyyy hh:mm:ss a').parse(notice.eventDate);
    final now = DateTime.now();
    return eventDate.isAfter(now);
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageData;

    // Check if the `uploadPhoto` is not null or empty and is valid base64
    if (notice.uploadPhoto != null && notice.uploadPhoto.isNotEmpty) {
      try {
        imageData = base64Decode(notice.uploadPhoto);
      } catch (e) {
        // Handle invalid base64 string
        imageData = null;
      }
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLive() || isUpcoming())
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: isLive() ? Colors.redAccent : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isLive() ? 'LIVE' : 'UPCOMING EVENT',
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              notice.employeeName,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              notice.requestDate,
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              notice.noticeTitle,
              style: GoogleFonts.bebasNeue(
                textStyle: const TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              notice.headerDescription,
              style: GoogleFonts.indieFlower(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (imageData != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageData,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            if (imageData != null) const SizedBox(height: 8),
            Text(
              notice.description,
              style: GoogleFonts.nunito(
                textStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(
                  notice.location,
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.timelapse, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${notice.startTime} - ${notice.endTime}',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
