import 'package:flutter/material.dart';
import 'package:mercy_tv_app/API/api_integration.dart';
import 'package:mercy_tv_app/API/dataModel.dart';

class SuggestedVideoCard extends StatefulWidget {
  final void Function(ProgramDetails) onVideoTap;

  const SuggestedVideoCard({super.key, required this.onVideoTap});

  @override
  _SuggestedVideoCardState createState() => _SuggestedVideoCardState();
}

class _SuggestedVideoCardState extends State<SuggestedVideoCard> {
  late Future<List<dynamic>> _videoDataFuture;

  @override
  void initState() {
    super.initState();
    _videoDataFuture = fetchSortedVideoData();
  }

  Future<List<dynamic>> fetchSortedVideoData() async {
    List<dynamic> data = await ApiIntegration().getVideoData();

    // Sort data by `video_id` in descending order
    data.sort(
        (a, b) => int.parse(b['video_id']).compareTo(int.parse(a['video_id'])));

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _videoDataFuture,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data.isEmpty) {
          return const Center(child: Text('No videos available'));
        } else {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
              childAspectRatio: 1.3,
            ),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              var video = snapshot.data[index];
              var program = video['program'] ?? {};

              ProgramDetails programDetails = ProgramDetails(
                imageUrl: program['image'],
                date: program['date'],
                time: program['time'],
                title: program['program'] ?? 'Unknown Program',
                videoUrl: video['url'],
              );

              return VideoThumbnailCard(
                programDetails: programDetails,
                onTap: widget.onVideoTap,
              );
            },
          );
        }
      },
    );
  }
}

class VideoThumbnailCard extends StatelessWidget {
  final ProgramDetails programDetails;
  final void Function(ProgramDetails) onTap;

  const VideoThumbnailCard({
    super.key,
    required this.programDetails,
    required this.onTap,
  });

  String formatDateTime(String? date, String? time) {
    if (date == null || time == null) return "Unknown Date";
    DateTime parsedDate = DateTime.parse(date);
    String formattedDate =
        "${parsedDate.day} ${_getMonth(parsedDate.month)} ${parsedDate.year}";
    TimeOfDay parsedTime = TimeOfDay(
      hour: int.parse(time.split(":")[0]),
      minute: int.parse(time.split(":")[1]),
    );
    String formattedTime = _formatTime(parsedTime);
    return "$formattedDate | $formattedTime";
  }

  String _formatTime(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String period = time.period == DayPeriod.am ? "AM" : "PM";
    final String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  static String _getMonth(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap(programDetails);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  programDetails.imageUrl ?? '',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/video_thumb_1.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      programDetails.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.history, color: Colors.red, size: 18),
                        const SizedBox(width: 5),
                        Text(
                          formatDateTime(
                              programDetails.date, programDetails.time),
                          style:
                              const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
