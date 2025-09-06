import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:soomuch/videoPlayerScreen.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

class ScreenRecorderScreen extends StatefulWidget {
  @override
  _ScreenRecorderScreenState createState() => _ScreenRecorderScreenState();
}

class _ScreenRecorderScreenState extends State<ScreenRecorderScreen> {
  bool _isRecording = false;
  bool _isLoading = false;
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  List<FileSystemEntity> _recordings = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadRecordings();
  }

  /// Request permissions for Android/iOS
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};

    if (Platform.isAndroid) {
      statuses[Permission.microphone] = await Permission.microphone.request();
      statuses[Permission.storage] = await Permission.storage.request();
      statuses[Permission.videos] = await Permission.videos.request();
      statuses[Permission.audio] = await Permission.audio.request();
      statuses[Permission.photos] = await Permission.photos.request();

      // Request manage external storage for Android 11+
      if (await Permission.manageExternalStorage.isDenied) {
        statuses[Permission.manageExternalStorage] = await Permission
            .manageExternalStorage
            .request();
      }
    } else {
      statuses = await [Permission.microphone, Permission.photos].request();
    }

    final allGranted = statuses.values.any((status) => status.isGranted);

    if (!allGranted) {
      Fluttertoast.showToast(
        msg: 'Please grant all permissions to use screen recording',
        toastLength: Toast.LENGTH_LONG,
      );
    }
    return allGranted;
  }

  // Get the main SoomuchInterview directory at root level
  Future<String> _getSoomuchInterviewDirectory() async {
    if (Platform.isAndroid) {
      // Create SoomuchInterview folder at root level
      final soomuchDir = Directory('/storage/emulated/0/SoomuchInterview');
      if (!await soomuchDir.exists()) {
        await soomuchDir.create(recursive: true);
      }
      return soomuchDir.path;
    } else {
      // For iOS, use Documents directory with SoomuchInterview folder
      final docsDir = await getApplicationDocumentsDirectory();
      final soomuchDir = Directory('${docsDir.path}/SoomuchInterview');
      if (!await soomuchDir.exists()) {
        await soomuchDir.create(recursive: true);
      }
      return soomuchDir.path;
    }
  }

  Future<void> _loadRecordings() async {
    try {
      final dirPath = await _getSoomuchInterviewDirectory();
      final dir = Directory(dirPath);

      if (await dir.exists()) {
        final files = await dir.list().toList();
        // Filter only video files and sort by modification time (newest first)
        final videoFiles = files
            .where(
              (file) =>
                  file.path.toLowerCase().endsWith('.mp4') ||
                  file.path.toLowerCase().endsWith('.mov') ||
                  file.path.toLowerCase().endsWith('.avi'),
            )
            .toList();

        // Sort by modification time, newest first
        videoFiles.sort((a, b) {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return bStat.modified.compareTo(aStat.modified);
        });

        setState(() => _recordings = videoFiles);

        if (_recordings.isEmpty) {
          print("No video files found in: $dirPath");
        } else {
          print("Found ${_recordings.length} recordings in: $dirPath");
        }
      } else {
        print("Directory does not exist: $dirPath");
        setState(() => _recordings = []);
      }
    } catch (e) {
      print("Error loading recordings: $e");
      Fluttertoast.showToast(
        msg: 'Error loading recordings: $e',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> _startRecording() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (!await _requestPermissions()) {
      setState(() => _isLoading = false);
      return;
    }

    // Create a temporary file path for recording
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'soomuch_interview_${DateTime.now().millisecondsSinceEpoch}.mp4';
    _currentRecordingPath = '${tempDir.path}/$fileName';

    print("👉 Temporary recording path: $_currentRecordingPath");

    final started = await FlutterScreenRecording.startRecordScreenAndAudio(
      fileName,
    );

    if (started == true) {
      setState(() {
        _isRecording = true;
        _isLoading = false;
        _recordingDuration = Duration.zero;
      });
      _startRecordingTimer();
      Fluttertoast.showToast(
        msg: 'Recording started',
        gravity: ToastGravity.TOP,
      );
    } else {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: 'Failed to start recording',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => _recordingDuration += Duration(seconds: 1));
    });
  }

  Future<void> _stopRecording() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    _recordingTimer?.cancel();

    final path = await FlutterScreenRecording.stopRecordScreen;
    setState(() {
      _isRecording = false;
      _isLoading = false;
    });

    if (path != null && path.isNotEmpty) {
      try {
        final file = File(path);
        if (await file.exists()) {
          final sizeMB = (await file.length()) / (1024 * 1024);

          // Save to main SoomuchInterview folder
          final soomuchDirPath = await _getSoomuchInterviewDirectory();
          final soomuchDir = Directory(soomuchDirPath);
          if (!soomuchDir.existsSync()) {
            soomuchDir.createSync(recursive: true);
          }

          final fileName =
              "soomuch_interview_${DateTime.now().millisecondsSinceEpoch}.mp4";
          final newPath = "${soomuchDir.path}/$fileName";

          // Copy the file to SoomuchInterview directory
          await file.copy(newPath);

          // Delete the temporary file
          await file.delete();

          Fluttertoast.showToast(
            msg:
                'Recording saved to SoomuchInterview folder!\n'
                'Duration: ${_formatDuration(_recordingDuration)}\n'
                'Size: ${sizeMB.toStringAsFixed(2)} MB',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
          );

          print("✅ Recording saved to: $newPath");

          // Reload the recordings list
          _loadRecordings();
        } else {
          Fluttertoast.showToast(
            msg: 'Recording file not found at temporary path',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } catch (e) {
        print("Error saving recording: $e");
        Fluttertoast.showToast(
          msg: 'Error saving recording: $e',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to stop recording or file not available',
        toastLength: Toast.LENGTH_LONG,
      );
    }

    _currentRecordingPath = null;
    _recordingDuration = Duration.zero;
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }

  // Get file size and date for display
  String _getFileInfo(FileSystemEntity file) {
    try {
      final stat = file.statSync();
      final sizeMB = stat.size / (1024 * 1024);
      final date = stat.modified;

      return '${sizeMB.toStringAsFixed(1)} MB • ${DateFormat('MMM dd, HH:mm').format(date)}';
    } catch (e) {
      return 'Unknown size • Unknown date';
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soomuch Interview Recorder'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRecordings,
            tooltip: 'Refresh recordings',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isRecording)
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Recording - ${_formatDuration(_recordingDuration)}',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildControlButtons(),
                  if (_isLoading) ...[
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Processing...'),
                  ],
                ],
              ),
            ),

            Divider(height: 1),

            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Interview Recordings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '(${_recordings.length})',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _recordings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No interview recordings yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start recording to capture your interview',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recordings.length,
                      itemBuilder: (context, index) {
                        final file = _recordings[index];
                        final fileName = file.path.split('/').last;

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.video_library,
                              color: Colors.red,
                            ),
                            title: Text(
                              fileName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(_getFileInfo(file)),
                            trailing: Icon(
                              Icons.play_arrow,
                              color: Colors.blue,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoPlayerScreen(
                                    videoFile: File(file.path),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return ElevatedButton.icon(
      onPressed: _isLoading
          ? null
          : _isRecording
          ? _stopRecording
          : _startRecording,
      icon: Icon(
        _isRecording ? Icons.stop : Icons.videocam,
        color: Colors.white,
        size: 24,
      ),
      label: Text(
        _isRecording ? 'Stop Recording' : 'Start Recording',
        style: TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isRecording ? Colors.red : Colors.green,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: Size(200, 50),
      ),
    );
  }
}
