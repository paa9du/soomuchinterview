// // import 'dart:async';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:flutter_screen_recording/flutter_screen_recording.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// //
// // class ScreenRecorderScreen extends StatefulWidget {
// //   @override
// //   _ScreenRecorderScreenState createState() => _ScreenRecorderScreenState();
// // }
// //
// // class _ScreenRecorderScreenState extends State<ScreenRecorderScreen> {
// //   bool _isRecording = false;
// //   bool _isLoading = false;
// //   String? _currentRecordingPath;
// //   Timer? _recordingTimer;
// //   Duration _recordingDuration = Duration.zero;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _requestPermissions();
// //   }
// //
// //   /// Request permissions for Android/iOS
// //   Future<bool> _requestPermissions() async {
// //     Map<Permission, PermissionStatus> statuses = {};
// //
// //     if (Platform.isAndroid) {
// //       // Mic
// //       statuses[Permission.microphone] = await Permission.microphone.request();
// //
// //       // Storage permissions (Android 12 and below)
// //       statuses[Permission.storage] = await Permission.storage.request();
// //
// //       // Scoped storage (Android 13+)
// //       statuses[Permission.videos] = await Permission.videos.request();
// //       statuses[Permission.audio] = await Permission.audio.request();
// //       statuses[Permission.photos] = await Permission.photos.request();
// //     } else {
// //       // iOS
// //       statuses = await [
// //         Permission.microphone,
// //         Permission.photos,
// //       ].request();
// //     }
// //
// //     final allGranted = statuses.values.any((status) => status.isGranted);
// //
// //     if (!allGranted) {
// //       Fluttertoast.showToast(
// //         msg: 'Please grant all permissions to use screen recording',
// //         toastLength: Toast.LENGTH_LONG,
// //       );
// //     }
// //     return allGranted;
// //   }
// //
// //   Future<String> _getRecordingDirectory() async {
// //     if (Platform.isAndroid) {
// //       final appDir = await getExternalStorageDirectory();
// //       final moviesDir = Directory('${appDir?.path}/Movies/ScreenRecordings');
// //       if (!await moviesDir.exists()) {
// //         await moviesDir.create(recursive: true);
// //       }
// //       return moviesDir.path;
// //     } else {
// //       final docsDir = await getApplicationDocumentsDirectory();
// //       final recDir = Directory('${docsDir.path}/ScreenRecordings');
// //       if (!await recDir.exists()) {
// //         await recDir.create(recursive: true);
// //       }
// //       return recDir.path;
// //     }
// //   }
// //
// //   Future<void> _startRecording() async {
// //     if (_isLoading) return;
// //     setState(() => _isLoading = true);
// //
// //     if (!await _requestPermissions()) {
// //       setState(() => _isLoading = false);
// //       return;
// //     }
// //
// //     final dir = await _getRecordingDirectory();
// //     final fileName =
// //         'screen_recording_${DateTime.now().millisecondsSinceEpoch}.mp4';
// //     _currentRecordingPath = '$dir/$fileName';
// //
// //     final started =
// //     await FlutterScreenRecording.startRecordScreenAndAudio(fileName);
// //
// //     if (started == true) {
// //       setState(() {
// //         _isRecording = true;
// //         _isLoading = false;
// //         _recordingDuration = Duration.zero;
// //       });
// //       _startRecordingTimer();
// //       Fluttertoast.showToast(
// //         msg: 'Recording started',
// //         gravity: ToastGravity.TOP,
// //       );
// //     } else {
// //       setState(() => _isLoading = false);
// //       Fluttertoast.showToast(
// //         msg: 'Failed to start recording',
// //         toastLength: Toast.LENGTH_LONG,
// //       );
// //     }
// //   }
// //
// //   void _startRecordingTimer() {
// //     _recordingTimer = Timer.periodic(Duration(seconds: 1), (_) {
// //       setState(() => _recordingDuration += Duration(seconds: 1));
// //     });
// //   }
// //
// //   Future<void> _stopRecording() async {
// //     if (_isLoading) return;
// //     setState(() => _isLoading = true);
// //
// //     _recordingTimer?.cancel();
// //
// //     final path = await FlutterScreenRecording.stopRecordScreen;
// //     setState(() {
// //       _isRecording = false;
// //       _isLoading = false;
// //     });
// //
// //     if (path != null && path.isNotEmpty) {
// //       final file = File(path);
// //       final sizeMB = (await file.length()) / (1024 * 1024);
// //       Fluttertoast.showToast(
// //         msg: 'Recording saved!\n'
// //             'Duration: ${_formatDuration(_recordingDuration)}\n'
// //             'Size: ${sizeMB.toStringAsFixed(2)} MB\n'
// //             'Path: $path',
// //         toastLength: Toast.LENGTH_LONG,
// //         gravity: ToastGravity.CENTER,
// //       );
// //     } else {
// //       Fluttertoast.showToast(
// //         msg: 'Failed to stop recording or file not available',
// //         toastLength: Toast.LENGTH_LONG,
// //       );
// //     }
// //
// //     _currentRecordingPath = null;
// //     _recordingDuration = Duration.zero;
// //   }
// //
// //   String _formatDuration(Duration d) {
// //     String two(int n) => n.toString().padLeft(2, '0');
// //     final h = two(d.inHours);
// //     final m = two(d.inMinutes.remainder(60));
// //     final s = two(d.inSeconds.remainder(60));
// //     return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
// //   }
// //
// //   @override
// //   void dispose() {
// //     _recordingTimer?.cancel();
// //     if (_isRecording) FlutterScreenRecording.stopRecordScreen;
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Screen Recorder'),
// //         actions: [
// //           if (_isRecording)
// //             IconButton(
// //               icon: Icon(Icons.info),
// //               onPressed: () => Fluttertoast.showToast(
// //                 msg: 'Recording: ${_formatDuration(_recordingDuration)}',
// //                 toastLength: Toast.LENGTH_LONG,
// //               ),
// //             ),
// //         ],
// //       ),
// //       body: Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               if (_isRecording) _buildRecordingIndicator(),
// //               _buildControlButtons(),
// //               if (_isLoading) ...[
// //                 SizedBox(height: 20),
// //                 CircularProgressIndicator(),
// //                 SizedBox(height: 10),
// //                 Text('Processing...'),
// //               ],
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildRecordingIndicator() {
// //     return Column(
// //       children: [
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.circle, color: Colors.red, size: 20),
// //             SizedBox(width: 8),
// //             Text(
// //               'Recording',
// //               style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
// //             ),
// //           ],
// //         ),
// //         SizedBox(height: 6),
// //         Text(
// //           _formatDuration(_recordingDuration),
// //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildControlButtons() {
// //     return ElevatedButton.icon(
// //       onPressed:
// //       _isLoading ? null : _isRecording ? _stopRecording : _startRecording,
// //       icon: Icon(
// //         _isRecording ? Icons.stop : Icons.videocam,
// //         color: Colors.white,
// //       ),
// //       label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: _isRecording ? Colors.red : Colors.green,
// //         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
// //         minimumSize: Size(180, 50),
// //       ),
// //     );
// //   }
// // }
//
//------------------------------------------------------------------------------------


//
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_screen_recording/flutter_screen_recording.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:video_player/video_player.dart';
// import 'package:intl/intl.dart';
//
// class ScreenRecorderScreen extends StatefulWidget {
//   @override
//   _ScreenRecorderScreenState createState() => _ScreenRecorderScreenState();
// }
//
// class _ScreenRecorderScreenState extends State<ScreenRecorderScreen> {
//   bool _isRecording = false;
//   bool _isLoading = false;
//   String? _currentRecordingPath;
//   Timer? _recordingTimer;
//   Duration _recordingDuration = Duration.zero;
//   List<String> _recordings = [];
//   OverlayEntry? _overlayEntry;
//   VideoPlayerController? _videoController;
//   int? _selectedRecordingIndex;
//   final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadRecordings();
//     });
//   }
//
//   /// Request permissions for Android/iOS
//   Future<bool> _requestPermissions() async {
//     try {
//       Map<Permission, PermissionStatus> statuses = {};
//
//       if (Platform.isAndroid) {
//         // Microphone (needed if recording with audio)
//         statuses[Permission.microphone] = await Permission.microphone.request();
//
//         if (Platform.isAndroid) {
//           if (await Permission.videos.isDenied ||
//               await Permission.audio.isDenied ||
//               await Permission.photos.isDenied) {
//             statuses[Permission.videos] = await Permission.videos.request();
//             statuses[Permission.audio] = await Permission.audio.request();
//             statuses[Permission.photos] = await Permission.photos.request();
//           }
//         }
//
//         // For full storage access (if you want to save outside app folder)
//         if (await Permission.manageExternalStorage.isDenied) {
//           statuses[Permission.manageExternalStorage] = await Permission
//               .manageExternalStorage
//               .request();
//         }
//       } else if (Platform.isIOS) {
//         // iOS: only mic + photo library
//         statuses = await [Permission.microphone, Permission.photos].request();
//       }
//
//       final allGranted = statuses.values.every((status) => status.isGranted);
//
//       if (!allGranted) {
//         _showToast('Please grant all permissions to use screen recording');
//       }
//       return allGranted;
//     } catch (e) {
//       print("Permission error: $e");
//       _showToast('Error requesting permissions');
//       return false;
//     }
//   }
//
//   Future<String> _getRecordingDirectory() async {
//     try {
//       if (Platform.isAndroid) {
//         // Use the Downloads directory which is more accessible
//         final downloadsDir = await getDownloadsDirectory();
//         final recordingsDir = Directory(
//           '${downloadsDir?.path}/ScreenRecordings',
//         );
//         if (!await recordingsDir.exists()) {
//           await recordingsDir.create(recursive: true);
//         }
//         return recordingsDir.path;
//       } else {
//         final docsDir = await getApplicationDocumentsDirectory();
//         final recDir = Directory('${docsDir.path}/ScreenRecordings');
//         if (!await recDir.exists()) {
//           await recDir.create(recursive: true);
//         }
//         return recDir.path;
//       }
//     } catch (e) {
//       print("Error getting directory: $e");
//       // Fallback to temporary directory
//       final tempDir = await getTemporaryDirectory();
//       return tempDir.path;
//     }
//   }
//
//   Future<void> _loadRecordings() async {
//     try {
//       final dirPath = await _getRecordingDirectory();
//       final dir = Directory(dirPath);
//
//       if (await dir.exists()) {
//         final files = await dir.list().toList();
//         // Sort by modification time, newest first
//         files.sort((a, b) {
//           final aStat = a.statSync();
//           final bStat = b.statSync();
//           return bStat.modified.compareTo(aStat.modified);
//         });
//
//         setState(() {
//           _recordings = files
//               .where((file) => file.path.endsWith('.mp4'))
//               .map((file) => file.path)
//               .toList();
//         });
//       }
//     } catch (e) {
//       print("Error loading recordings: $e");
//       _showToast('Error loading recordings');
//     }
//   }
//
//   Future<void> _startRecording() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
//
//     try {
//       if (!await _requestPermissions()) {
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       final dir = await _getRecordingDirectory();
//       final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.mp4';
//       _currentRecordingPath = '$dir/$fileName';
//
//       final started = await FlutterScreenRecording.startRecordScreen(
//         fileName,
//         titleNotification: "Screen Recording",
//         messageNotification: "Recording in progress",
//       );
//
//       if (started) {
//         setState(() {
//           _isRecording = true;
//           _isLoading = false;
//           _recordingDuration = Duration.zero;
//         });
//         _startRecordingTimer();
//         _createOverlay();
//
//         _showToast('Recording started. Saving to: $dir');
//       } else {
//         setState(() => _isLoading = false);
//         _showToast('Failed to start recording. Check permissions.');
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       print("Recording error: $e");
//       _showToast('Error starting recording: $e');
//     }
//   }
//
//   void _createOverlay() {
//     try {
//       _overlayEntry = OverlayEntry(
//         builder: (context) => Positioned(
//           bottom: 20,
//           right: 20,
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () {
//                 // Bring app to foreground
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                     builder: (context) => ScreenRecorderScreen(),
//                   ),
//                       (Route<dynamic> route) => false,
//                 );
//               },
//               child: Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Icon(Icons.videocam, color: Colors.white),
//               ),
//             ),
//           ),
//         ),
//       );
//
//       Overlay.of(context).insert(_overlayEntry!);
//     } catch (e) {
//       print("Overlay error: $e");
//     }
//   }
//
//   void _removeOverlay() {
//     try {
//       if (_overlayEntry != null) {
//         _overlayEntry!.remove();
//         _overlayEntry = null;
//       }
//     } catch (e) {
//       print("Error removing overlay: $e");
//     }
//   }
//
//   void _startRecordingTimer() {
//     _recordingTimer = Timer.periodic(Duration(seconds: 1), (_) {
//       setState(() => _recordingDuration += Duration(seconds: 1));
//     });
//   }
//
//   Future<void> _stopRecording() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
//
//     try {
//       _recordingTimer?.cancel();
//       _removeOverlay();
//
//       final path = await FlutterScreenRecording.stopRecordScreen;
//
//       setState(() {
//         _isRecording = false;
//         _isLoading = false;
//       });
//
//       if (path != null && path.isNotEmpty) {
//         // Verify the file exists
//         final file = File(path);
//         if (await file.exists()) {
//           final sizeMB = (await file.length()) / (1024 * 1024);
//
//           _showToast(
//             'Recording saved!\n'
//                 'Duration: ${_formatDuration(_recordingDuration)}\n'
//                 'Size: ${sizeMB.toStringAsFixed(2)} MB\n'
//                 'Path: $path',
//           );
//
//           // Reload recordings
//           await _loadRecordings();
//         } else {
//           _showToast('Recording file not found');
//         }
//       } else {
//         _showToast('Failed to stop recording or file not available');
//       }
//     } catch (e) {
//       setState(() {
//         _isRecording = false;
//         _isLoading = false;
//       });
//       print("Stop recording error: $e");
//       _showToast('Error stopping recording: $e');
//     }
//
//     _currentRecordingPath = null;
//     _recordingDuration = Duration.zero;
//   }
//
//   String _formatDuration(Duration d) {
//     String two(int n) => n.toString().padLeft(2, '0');
//     final m = two(d.inMinutes.remainder(60));
//     final s = two(d.inSeconds.remainder(60));
//     return '$m:$s';
//   }
//
//   void _playRecording(String path) async {
//     try {
//       if (_videoController != null) {
//         await _videoController!.dispose();
//       }
//
//       setState(() {
//         _selectedRecordingIndex = _recordings.indexOf(path);
//         _videoController = VideoPlayerController.file(File(path))
//           ..initialize().then((_) {
//             setState(() {});
//             _videoController!.play();
//           })
//           ..addListener(() {
//             if (_videoController!.value.hasError) {
//               _showToast(
//                 'Error playing video: ${_videoController!.value.errorDescription}',
//               );
//             }
//           });
//       });
//     } catch (e) {
//       print("Play recording error: $e");
//       _showToast('Error playing recording: $e');
//     }
//   }
//
//   void _showToast(String message) {
//     try {
//       Fluttertoast.showToast(
//         msg: message,
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 2,
//         backgroundColor: Colors.black54,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//     } catch (e) {
//       print("Toast error: $e");
//     }
//   }
//
//   Future<void> _deleteRecording(int index) async {
//     try {
//       final path = _recordings[index];
//       final file = File(path);
//
//       if (await file.exists()) {
//         await file.delete();
//
//         // If we're currently playing this video, stop it
//         if (_selectedRecordingIndex == index) {
//           await _videoController?.dispose();
//           setState(() {
//             _videoController = null;
//             _selectedRecordingIndex = null;
//           });
//         }
//
//         // Remove from list with animation
//         final removedItem = _recordings.removeAt(index);
//         _listKey.currentState?.removeItem(
//           index,
//               (context, animation) =>
//               _buildRecordItem(removedItem, index, animation),
//           duration: Duration(milliseconds: 300),
//         );
//
//         _showToast('Recording deleted');
//       }
//     } catch (e) {
//       print("Delete error: $e");
//       _showToast('Error deleting recording');
//     }
//   }
//
//   Widget _buildRecordItem(String path, int index, Animation<double> animation) {
//     final file = File(path);
//     final fileName = path.split('/').last;
//     final isSelected = index == _selectedRecordingIndex;
//
//     return SizeTransition(
//       sizeFactor: animation,
//       child: Card(
//         color: isSelected ? Colors.blue[50] : null,
//         margin: EdgeInsets.symmetric(vertical: 5),
//         child: ListTile(
//           leading: Icon(Icons.video_library, color: Colors.red),
//           title: Text(fileName, overflow: TextOverflow.ellipsis),
//           subtitle: FutureBuilder<FileStat>(
//             future: file.stat(),
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 final sizeMB = snapshot.data!.size / (1024 * 1024);
//                 final date = snapshot.data!.modified;
//                 return Text(
//                   '${sizeMB.toStringAsFixed(2)} MB • ${DateFormat('MMM dd, yyyy - HH:mm').format(date)}',
//                   overflow: TextOverflow.ellipsis,
//                 );
//               }
//               return Text('Loading...', overflow: TextOverflow.ellipsis);
//             },
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.play_arrow),
//                 onPressed: () => _playRecording(path),
//                 tooltip: 'Play recording',
//               ),
//               IconButton(
//                 icon: Icon(Icons.delete, color: Colors.red),
//                 onPressed: () => _deleteRecording(index),
//                 tooltip: 'Delete recording',
//               ),
//             ],
//           ),
//           onTap: () => _playRecording(path),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _recordingTimer?.cancel();
//     _removeOverlay();
//     _videoController?.dispose();
//     if (_isRecording) {
//       // Try to stop recording if still active
//       FlutterScreenRecording.stopRecordScreen.then((_) {}).catchError((e) {});
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Screen Recorder'),
//         actions: [
//           if (_isRecording)
//             IconButton(
//               icon: Icon(Icons.info),
//               onPressed: () => _showToast(
//                 'Recording: ${_formatDuration(_recordingDuration)}',
//               ),
//               tooltip: 'Recording info',
//             ),
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _loadRecordings,
//             tooltip: 'Refresh recordings',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (_isRecording) _buildRecordingHeader(),
//           Expanded(
//             child: Column(
//               children: [
//                 if (!_isRecording) _buildControlSection(),
//                 if (_recordings.isNotEmpty)
//                   Expanded(child: _buildRecordingsList())
//                 else if (!_isLoading && !_isRecording)
//                   _buildEmptyState(),
//                 if (_isLoading) _buildLoadingState(),
//               ],
//             ),
//           ),
//           if (_videoController != null && _videoController!.value.isInitialized)
//             _buildVideoPlayer(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRecordingHeader() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       color: Colors.red.withOpacity(0.1),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.circle, color: Colors.red, size: 16),
//           SizedBox(width: 8),
//           Text(
//             'Recording - ${_formatDuration(_recordingDuration)}',
//             style: TextStyle(
//               color: Colors.red,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(width: 16),
//           ElevatedButton(
//             onPressed: _stopRecording,
//             child: Text('Stop'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildControlSection() {
//     return Padding(
//       padding: EdgeInsets.all(20),
//       child: Column(
//         children: [
//           ElevatedButton.icon(
//             onPressed: _startRecording,
//             icon: Icon(Icons.videocam, color: Colors.white),
//             label: Text('Start Recording', style: TextStyle(fontSize: 16)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               minimumSize: Size(200, 50),
//             ),
//           ),
//           SizedBox(height: 10),
//           Text(
//             'Recordings will be saved to your device',
//             style: TextStyle(color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRecordingsList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
//           child: Text(
//             'Your Recordings:',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//         Expanded(
//           child: AnimatedList(
//             key: _listKey,
//             initialItemCount: _recordings.length,
//             itemBuilder: (context, index, animation) {
//               return _buildRecordItem(_recordings[index], index, animation);
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Expanded(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.videocam_off, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               'No recordings yet',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Start a recording to see it here',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Expanded(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading...'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVideoPlayer() {
//     return Column(
//       children: [
//         Divider(height: 1),
//         Container(
//           color: Colors.black,
//           height: 200,
//           child: AspectRatio(
//             aspectRatio: _videoController!.value.aspectRatio,
//             child: VideoPlayer(_videoController!),
//           ),
//         ),
//         VideoProgressIndicator(
//           _videoController!,
//           allowScrubbing: true,
//           colors: VideoProgressColors(
//             playedColor: Colors.red,
//             bufferedColor: Colors.grey,
//             backgroundColor: Colors.grey[700]!,
//           ),
//         ),
//         ButtonBar(
//           alignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               icon: Icon(
//                 _videoController!.value.isPlaying
//                     ? Icons.pause
//                     : Icons.play_arrow,
//               ),
//               onPressed: () {
//                 setState(() {
//                   if (_videoController!.value.isPlaying) {
//                     _videoController!.pause();
//                   } else {
//                     _videoController!.play();
//                   }
//                 });
//               },
//             ),
//             IconButton(
//               icon: Icon(Icons.stop),
//               onPressed: () {
//                 setState(() {
//                   _videoController!.pause();
//                   _videoController!.seekTo(Duration.zero);
//                   _selectedRecordingIndex = null;
//                 });
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//-------------------------------------------------------------------------------------

// // // import 'dart:async';
// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:permission_handler/permission_handler.dart';
// // // import 'package:flutter_screen_recording/flutter_screen_recording.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:fluttertoast/fluttertoast.dart';
// // // import 'package:video_player/video_player.dart';
// // //
// // // class ScreenRecorderScreen extends StatefulWidget {
// // //   @override
// // //   _ScreenRecorderScreenState createState() => _ScreenRecorderScreenState();
// // // }
// // //
// // // class _ScreenRecorderScreenState extends State<ScreenRecorderScreen> {
// // //   bool _isRecording = false;
// // //   bool _isLoading = false;
// // //   String? _currentRecordingPath;
// // //   Timer? _recordingTimer;
// // //   Duration _recordingDuration = Duration.zero;
// // //   List<FileSystemEntity> _recordings = [];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _requestPermissions();
// // //     _loadRecordings();
// // //   }
// // //
// // //   /// Request permissions for Android/iOS
// // //   Future<bool> _requestPermissions() async {
// // //     Map<Permission, PermissionStatus> statuses = {};
// // //
// // //     if (Platform.isAndroid) {
// // //       statuses[Permission.microphone] = await Permission.microphone.request();
// // //       statuses[Permission.storage] = await Permission.storage.request();
// // //       statuses[Permission.videos] = await Permission.videos.request();
// // //       statuses[Permission.audio] = await Permission.audio.request();
// // //       statuses[Permission.photos] = await Permission.photos.request();
// // //     } else {
// // //       statuses = await [Permission.microphone, Permission.photos].request();
// // //     }
// // //
// // //     final allGranted = statuses.values.any((status) => status.isGranted);
// // //
// // //     if (!allGranted) {
// // //       Fluttertoast.showToast(
// // //         msg: 'Please grant all permissions to use screen recording',
// // //         toastLength: Toast.LENGTH_LONG,
// // //       );
// // //     }
// // //     return allGranted;
// // //   }
// // //
// // //   Future<String> _getRecordingDirectory() async {
// // //     if (Platform.isAndroid) {
// // //       final appDir = await getExternalStorageDirectory();
// // //       final moviesDir = Directory('${appDir?.path}/Movies/ScreenRecordings');
// // //       if (!await moviesDir.exists()) {
// // //         await moviesDir.create(recursive: true);
// // //       }
// // //       return moviesDir.path;
// // //     } else {
// // //       final docsDir = await getApplicationDocumentsDirectory();
// // //       final recDir = Directory('${docsDir.path}/ScreenRecordings');
// // //       if (!await recDir.exists()) {
// // //         await recDir.create(recursive: true);
// // //       }
// // //       return recDir.path;
// // //     }
// // //   }
// // //
// // //   Future<void> _loadRecordings() async {
// // //     final dirPath = await _getRecordingDirectory();
// // //     final dir = Directory(dirPath);
// // //     final files = dir.existsSync() ? dir.listSync() : [];
// // //     setState(
// // //       () => _recordings = files.reversed.toList().cast<FileSystemEntity>(),
// // //     );
// // //   }
// // //
// // //   Future<void> _startRecording() async {
// // //     if (_isLoading) return;
// // //     setState(() => _isLoading = true);
// // //
// // //     if (!await _requestPermissions()) {
// // //       setState(() => _isLoading = false);
// // //       return;
// // //     }
// // //
// // //     final dir = await _getRecordingDirectory();
// // //     final fileName =
// // //         'screen_recording_${DateTime.now().millisecondsSinceEpoch}.mp4';
// // //     _currentRecordingPath = '$dir/$fileName';
// // //
// // //     print("👉 Saving recording to: $_currentRecordingPath");
// // //
// // //     final started = await FlutterScreenRecording.startRecordScreenAndAudio(
// // //       fileName,
// // //     );
// // //
// // //     if (started == true) {
// // //       setState(() {
// // //         _isRecording = true;
// // //         _isLoading = false;
// // //         _recordingDuration = Duration.zero;
// // //       });
// // //       _startRecordingTimer();
// // //       Fluttertoast.showToast(
// // //         msg: 'Recording started',
// // //         gravity: ToastGravity.TOP,
// // //       );
// // //     } else {
// // //       setState(() => _isLoading = false);
// // //       Fluttertoast.showToast(
// // //         msg: 'Failed to start recording',
// // //         toastLength: Toast.LENGTH_LONG,
// // //       );
// // //     }
// // //   }
// // //
// // //   void _startRecordingTimer() {
// // //     _recordingTimer = Timer.periodic(Duration(seconds: 1), (_) {
// // //       setState(() => _recordingDuration += Duration(seconds: 1));
// // //     });
// // //   }
// // //
// // //   Future<void> _stopRecording() async {
// // //     if (_isLoading) return;
// // //     setState(() => _isLoading = true);
// // //
// // //     _recordingTimer?.cancel();
// // //
// // //     final path = await FlutterScreenRecording.stopRecordScreen;
// // //     setState(() {
// // //       _isRecording = false;
// // //       _isLoading = false;
// // //     });
// // //
// // //     if (path != null && path.isNotEmpty) {
// // //       final file = File(path);
// // //       if (await file.exists()) {
// // //         final sizeMB = (await file.length()) / (1024 * 1024);
// // //
// // //         // Save copy to public Movies folder
// // //         final moviesDir = Directory("/storage/emulated/0/Movies");
// // //         if (!moviesDir.existsSync()) {
// // //           moviesDir.createSync(recursive: true);
// // //         }
// // //
// // //         final fileName = path.split("/").last;
// // //         final newPath = "${moviesDir.path}/$fileName";
// // //         final newFile = await file.copy(newPath);
// // //
// // //         Fluttertoast.showToast(
// // //           msg:
// // //               'Recording saved!\n'
// // //               'Duration: ${_formatDuration(_recordingDuration)}\n'
// // //               'Size: ${sizeMB.toStringAsFixed(2)} MB\n'
// // //               'Path: $newPath',
// // //           toastLength: Toast.LENGTH_LONG,
// // //           gravity: ToastGravity.CENTER,
// // //         );
// // //
// // //         print("✅ Recording copied to: $newPath");
// // //
// // //         _loadRecordings();
// // //       }
// // //     } else {
// // //       Fluttertoast.showToast(
// // //         msg: 'Failed to stop recording or file not available',
// // //         toastLength: Toast.LENGTH_LONG,
// // //       );
// // //     }
// // //
// // //     _currentRecordingPath = null;
// // //     _recordingDuration = Duration.zero;
// // //   }
// // //
// // //   String _formatDuration(Duration d) {
// // //     String two(int n) => n.toString().padLeft(2, '0');
// // //     final h = two(d.inHours);
// // //     final m = two(d.inMinutes.remainder(60));
// // //     final s = two(d.inSeconds.remainder(60));
// // //     return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _recordingTimer?.cancel();
// // //     // ⚠️ Do NOT stop recording in dispose
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Screen Recorder')),
// // //       body: Stack(
// // //         children: [
// // //           _buildMainContent(),
// // //           // if (_isRecording) _buildFloatingHideButton(),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildMainContent() {
// // //     return Center(
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(20),
// // //         child: Column(
// // //           children: [
// // //             if (_isRecording) _buildRecordingIndicator(),
// // //             _buildControlButtons(),
// // //             if (_isLoading) ...[
// // //               SizedBox(height: 20),
// // //               CircularProgressIndicator(),
// // //               SizedBox(height: 10),
// // //               Text('Processing...'),
// // //             ],
// // //             Divider(height: 40, thickness: 2),
// // //             Expanded(
// // //               child: _recordings.isEmpty
// // //                   ? Center(child: Text("No recordings found"))
// // //                   : ListView.builder(
// // //                       itemCount: _recordings.length,
// // //                       itemBuilder: (context, index) {
// // //                         final file = _recordings[index];
// // //                         return ListTile(
// // //                           leading: Icon(Icons.video_file, color: Colors.blue),
// // //                           title: Text(file.path.split('/').last),
// // //                           subtitle: Text(file.path),
// // //                           onTap: () {
// // //                             Navigator.push(
// // //                               context,
// // //                               MaterialPageRoute(
// // //                                 builder: (_) => VideoPlayerScreen(
// // //                                   videoFile: File(file.path),
// // //                                 ),
// // //                               ),
// // //                             );
// // //                           },
// // //                         );
// // //                       },
// // //                     ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildRecordingIndicator() {
// // //     return Column(
// // //       children: [
// // //         Row(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             Icon(Icons.circle, color: Colors.red, size: 20),
// // //             SizedBox(width: 8),
// // //             Text(
// // //               'Recording',
// // //               style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
// // //             ),
// // //           ],
// // //         ),
// // //         SizedBox(height: 6),
// // //         Text(
// // //           _formatDuration(_recordingDuration),
// // //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _buildControlButtons() {
// // //     return ElevatedButton.icon(
// // //       onPressed: _isLoading
// // //           ? null
// // //           : _isRecording
// // //           ? _stopRecording
// // //           : _startRecording,
// // //       icon: Icon(
// // //         _isRecording ? Icons.stop : Icons.videocam,
// // //         color: Colors.white,
// // //       ),
// // //       label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
// // //       style: ElevatedButton.styleFrom(
// // //         backgroundColor: _isRecording ? Colors.red : Colors.green,
// // //         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
// // //         minimumSize: Size(180, 50),
// // //       ),
// // //     );
// // //   }
// // //
// // //   /// Floating "Hide" button
// // //   // Widget _buildFloatingHideButton() {
// // //   //   return Positioned(
// // //   //     right: 20,
// // //   //     bottom: 100,
// // //   //     child: Draggable(
// // //   //       feedback: FloatingActionButton(
// // //   //         onPressed: () {},
// // //   //         child: Icon(Icons.visibility),
// // //   //       ),
// // //   //       child: FloatingActionButton(
// // //   //         backgroundColor: Colors.blueAccent,
// // //   //         onPressed: () {
// // //   //           Fluttertoast.showToast(
// // //   //             msg: "Returning to app screen...",
// // //   //             gravity: ToastGravity.BOTTOM,
// // //   //           );
// // //   //         },
// // //   //         child: Icon(Icons.visibility),
// // //   //       ),
// // //   //     ),
// // //   //   );
// // //   // }
// // // }
// // //
// // // /// Simple video player screen
// // // class VideoPlayerScreen extends StatefulWidget {
// // //   final File videoFile;
// // //
// // //   VideoPlayerScreen({required this.videoFile});
// // //
// // //   @override
// // //   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// // // }
// // //
// // // class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
// // //   late VideoPlayerController _controller;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _controller = VideoPlayerController.file(widget.videoFile)
// // //       ..initialize().then((_) {
// // //         setState(() {});
// // //         _controller.play();
// // //       });
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _controller.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text("Recording Preview")),
// // //       body: Center(
// // //         child: _controller.value.isInitialized
// // //             ? AspectRatio(
// // //                 aspectRatio: _controller.value.aspectRatio,
// // //                 child: VideoPlayer(_controller),
// // //               )
// // //             : CircularProgressIndicator(),
// // //       ),
// // //       floatingActionButton: FloatingActionButton(
// // //         onPressed: () {
// // //           setState(() {
// // //             _controller.value.isPlaying
// // //                 ? _controller.pause()
// // //                 : _controller.play();
// // //           });
// // //         },
// // //         child: Icon(
// // //           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
//
//
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_screen_recording/flutter_screen_recording.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:video_player/video_player.dart';
// import 'package:intl/intl.dart';
//
// class ScreenRecorderScreen extends StatefulWidget {
//   @override
//   _ScreenRecorderScreenState createState() => _ScreenRecorderScreenState();
// }
//
// class _ScreenRecorderScreenState extends State<ScreenRecorderScreen> {
//   bool _isRecording = false;
//   bool _isLoading = false;
//   String? _currentRecordingPath;
//   Timer? _recordingTimer;
//   Duration _recordingDuration = Duration.zero;
//   List<FileSystemEntity> _recordings = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//     _loadRecordings();
//   }
//
//   /// Request permissions for Android/iOS
//   Future<bool> _requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses = {};
//
//     if (Platform.isAndroid) {
//       statuses[Permission.microphone] = await Permission.microphone.request();
//       statuses[Permission.storage] = await Permission.storage.request();
//       statuses[Permission.videos] = await Permission.videos.request();
//       statuses[Permission.audio] = await Permission.audio.request();
//       statuses[Permission.photos] = await Permission.photos.request();
//
//       // Request manage external storage for Android 11+
//       if (await Permission.manageExternalStorage.isDenied) {
//         statuses[Permission.manageExternalStorage] = await Permission
//             .manageExternalStorage
//             .request();
//       }
//     } else {
//       statuses = await [Permission.microphone, Permission.photos].request();
//     }
//
//     final allGranted = statuses.values.any((status) => status.isGranted);
//
//     if (!allGranted) {
//       Fluttertoast.showToast(
//         msg: 'Please grant all permissions to use screen recording',
//         toastLength: Toast.LENGTH_LONG,
//       );
//     }
//     return allGranted;
//   }
//
//   // Get the public Movies directory where videos are saved
//   Future<String> _getPublicMoviesDirectory() async {
//     if (Platform.isAndroid) {
//       // Use the standard Movies directory path
//       return "/storage/emulated/0/Movies";
//     } else {
//       final docsDir = await getApplicationDocumentsDirectory();
//       final recDir = Directory('${docsDir.path}/ScreenRecordings');
//       if (!await recDir.exists()) {
//         await recDir.create(recursive: true);
//       }
//       return recDir.path;
//     }
//   }
//
//   Future<void> _loadRecordings() async {
//     try {
//       final dirPath = await _getPublicMoviesDirectory();
//       final dir = Directory(dirPath);
//
//       if (await dir.exists()) {
//         final files = await dir.list().toList();
//         // Filter only video files and sort by modification time (newest first)
//         final videoFiles = files
//             .where(
//               (file) =>
//                   file.path.toLowerCase().endsWith('.mp4') ||
//                   file.path.toLowerCase().endsWith('.mov') ||
//                   file.path.toLowerCase().endsWith('.avi'),
//             )
//             .toList();
//
//         // Sort by modification time, newest first
//         videoFiles.sort((a, b) {
//           final aStat = a.statSync();
//           final bStat = b.statSync();
//           return bStat.modified.compareTo(aStat.modified);
//         });
//
//         setState(() => _recordings = videoFiles);
//
//         if (_recordings.isEmpty) {
//           print("No video files found in: $dirPath");
//         } else {
//           print("Found ${_recordings.length} recordings in: $dirPath");
//         }
//       } else {
//         print("Directory does not exist: $dirPath");
//         setState(() => _recordings = []);
//       }
//     } catch (e) {
//       print("Error loading recordings: $e");
//       Fluttertoast.showToast(
//         msg: 'Error loading recordings: $e',
//         toastLength: Toast.LENGTH_LONG,
//       );
//     }
//   }
//
//   Future<void> _startRecording() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
//
//     if (!await _requestPermissions()) {
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     // Create a temporary file path for recording
//     final tempDir = await getTemporaryDirectory();
//     final fileName =
//         'screen_recording_${DateTime.now().millisecondsSinceEpoch}.mp4';
//     _currentRecordingPath = '${tempDir.path}/$fileName';
//
//     print("👉 Temporary recording path: $_currentRecordingPath");
//
//     final started = await FlutterScreenRecording.startRecordScreenAndAudio(
//       fileName,
//     );
//
//     if (started == true) {
//       setState(() {
//         _isRecording = true;
//         _isLoading = false;
//         _recordingDuration = Duration.zero;
//       });
//       _startRecordingTimer();
//       Fluttertoast.showToast(
//         msg: 'Recording started',
//         gravity: ToastGravity.TOP,
//       );
//     } else {
//       setState(() => _isLoading = false);
//       Fluttertoast.showToast(
//         msg: 'Failed to start recording',
//         toastLength: Toast.LENGTH_LONG,
//       );
//     }
//   }
//
//   void _startRecordingTimer() {
//     _recordingTimer = Timer.periodic(Duration(seconds: 1), (_) {
//       setState(() => _recordingDuration += Duration(seconds: 1));
//     });
//   }
//
//   Future<void> _stopRecording() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
//
//     _recordingTimer?.cancel();
//
//     final path = await FlutterScreenRecording.stopRecordScreen;
//     setState(() {
//       _isRecording = false;
//       _isLoading = false;
//     });
//
//     if (path != null && path.isNotEmpty) {
//       try {
//         final file = File(path);
//         if (await file.exists()) {
//           final sizeMB = (await file.length()) / (1024 * 1024);
//
//           // Save to public Movies folder
//           final moviesDirPath = await _getPublicMoviesDirectory();
//           final moviesDir = Directory(moviesDirPath);
//           if (!moviesDir.existsSync()) {
//             moviesDir.createSync(recursive: true);
//           }
//
//           final fileName =
//               "screen_recording_${DateTime.now().millisecondsSinceEpoch}.mp4";
//           final newPath = "${moviesDir.path}/$fileName";
//
//           // Copy the file to public directory
//           await file.copy(newPath);
//
//           // Delete the temporary file
//           await file.delete();
//
//           Fluttertoast.showToast(
//             msg:
//                 'Recording saved to Movies folder!\n'
//                 'Duration: ${_formatDuration(_recordingDuration)}\n'
//                 'Size: ${sizeMB.toStringAsFixed(2)} MB',
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.CENTER,
//           );
//
//           print("✅ Recording saved to: $newPath");
//
//           // Reload the recordings list
//           _loadRecordings();
//         } else {
//           Fluttertoast.showToast(
//             msg: 'Recording file not found at temporary path',
//             toastLength: Toast.LENGTH_LONG,
//           );
//         }
//       } catch (e) {
//         print("Error saving recording: $e");
//         Fluttertoast.showToast(
//           msg: 'Error saving recording: $e',
//           toastLength: Toast.LENGTH_LONG,
//         );
//       }
//     } else {
//       Fluttertoast.showToast(
//         msg: 'Failed to stop recording or file not available',
//         toastLength: Toast.LENGTH_LONG,
//       );
//     }
//
//     _currentRecordingPath = null;
//     _recordingDuration = Duration.zero;
//   }
//
//   String _formatDuration(Duration d) {
//     String two(int n) => n.toString().padLeft(2, '0');
//     final h = two(d.inHours);
//     final m = two(d.inMinutes.remainder(60));
//     final s = two(d.inSeconds.remainder(60));
//     return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
//   }
//
//   // Get file size and date for display
//   String _getFileInfo(FileSystemEntity file) {
//     try {
//       final stat = file.statSync();
//       final sizeMB = stat.size / (1024 * 1024);
//       final date = stat.modified;
//
//       return '${sizeMB.toStringAsFixed(1)} MB • ${DateFormat('MMM dd, HH:mm').format(date)}';
//     } catch (e) {
//       return 'Unknown size • Unknown date';
//     }
//   }
//
//   @override
//   void dispose() {
//     _recordingTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Screen Recorder'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _loadRecordings,
//             tooltip: 'Refresh recordings',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           if (_isRecording)
//             Container(
//               padding: EdgeInsets.all(16),
//               color: Colors.red.withOpacity(0.1),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.circle, color: Colors.red, size: 16),
//                   SizedBox(width: 8),
//                   Text(
//                     'Recording - ${_formatDuration(_recordingDuration)}',
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 _buildControlButtons(),
//                 if (_isLoading) ...[
//                   SizedBox(height: 20),
//                   CircularProgressIndicator(),
//                   SizedBox(height: 10),
//                   Text('Processing...'),
//                 ],
//               ],
//             ),
//           ),
//
//           Divider(height: 1),
//
//           Padding(
//             padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Row(
//               children: [
//                 Text(
//                   'Your Recordings',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   '(${_recordings.length})',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//
//           Expanded(
//             child: _recordings.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.videocam_off,
//                           size: 64,
//                           color: Colors.grey[300],
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'No recordings yet',
//                           style: TextStyle(fontSize: 18, color: Colors.grey),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           'Start a recording to see it here',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: _recordings.length,
//                     itemBuilder: (context, index) {
//                       final file = _recordings[index];
//                       final fileName = file.path.split('/').last;
//
//                       return Card(
//                         margin: EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 4,
//                         ),
//                         child: ListTile(
//                           leading: Icon(Icons.video_library, color: Colors.red),
//                           title: Text(
//                             fileName,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                           subtitle: Text(_getFileInfo(file)),
//                           trailing: Icon(Icons.play_arrow, color: Colors.blue),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => VideoPlayerScreen(
//                                   videoFile: File(file.path),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildControlButtons() {
//     return ElevatedButton.icon(
//       onPressed: _isLoading
//           ? null
//           : _isRecording
//           ? _stopRecording
//           : _startRecording,
//       icon: Icon(
//         _isRecording ? Icons.stop : Icons.videocam,
//         color: Colors.white,
//         size: 24,
//       ),
//       label: Text(
//         _isRecording ? 'Stop Recording' : 'Start Recording',
//         style: TextStyle(fontSize: 16),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _isRecording ? Colors.red : Colors.green,
//         foregroundColor: Colors.white,
//         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         minimumSize: Size(200, 50),
//       ),
//     );
//   }
// }
//
// /// Simple video player screen
// class VideoPlayerScreen extends StatefulWidget {
//   final File videoFile;
//
//   VideoPlayerScreen({required this.videoFile});
//
//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }
//
// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;
//   bool _isPlaying = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(widget.videoFile)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Recording Preview")),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? Column(
//                 children: [
//                   AspectRatio(
//                     aspectRatio: _controller.value.aspectRatio,
//                     child: VideoPlayer(_controller),
//                   ),
//                   VideoProgressIndicator(
//                     _controller,
//                     allowScrubbing: true,
//                     colors: VideoProgressColors(
//                       playedColor: Colors.red,
//                       bufferedColor: Colors.grey[300]!,
//                       backgroundColor: Colors.grey[600]!,
//                     ),
//                   ),
//                 ],
//               )
//             : CircularProgressIndicator(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             if (_controller.value.isPlaying) {
//               _controller.pause();
//               _isPlaying = false;
//             } else {
//               _controller.play();
//               _isPlaying = true;
//             }
//           });
//         },
//         child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//       ),
//     );
//   }
// }
//
// //
// // import 'dart:async';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:flutter_screen_recording/flutter_screen_recording.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:video_player/video_player.dart';
// // import 'package:intl/intl.dart';
// //
// // class ScreenRecorderScreen extends StatefulWidget {
// //   @override
// //   _ScreenRecorderScreenState createState() => _ScreenRecorderScreenState();
// // }
// //
// // class _ScreenRecorderScreenState extends State<ScreenRecorderScreen> {
// //   bool _isRecording = false;
// //   bool _isLoading = false;
// //   String? _currentRecordingPath;
// //   Timer? _recordingTimer;
// //   Duration _recordingDuration = Duration.zero;
// //   List<FileSystemEntity> _recordings = [];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _requestPermissions();
// //     _loadRecordings();
// //   }
// //
// //   /// Request permissions for Android/iOS
// //   Future<bool> _requestPermissions() async {
// //     Map<Permission, PermissionStatus> statuses = {};
// //
// //     if (Platform.isAndroid) {
// //       statuses[Permission.microphone] = await Permission.microphone.request();
// //       statuses[Permission.storage] = await Permission.storage.request();
// //       statuses[Permission.videos] = await Permission.videos.request();
// //       statuses[Permission.audio] = await Permission.audio.request();
// //       statuses[Permission.photos] = await Permission.photos.request();
// //
// //       // Request manage external storage for Android 11+
// //       if (await Permission.manageExternalStorage.isDenied) {
// //         statuses[Permission.manageExternalStorage] = await Permission
// //             .manageExternalStorage
// //             .request();
// //       }
// //     } else {
// //       statuses = await [Permission.microphone, Permission.photos].request();
// //     }
// //
// //     final allGranted = statuses.values.any((status) => status.isGranted);
// //
// //     if (!allGranted) {
// //       Fluttertoast.showToast(
// //         msg: 'Please grant all permissions to use screen recording',
// //         toastLength: Toast.LENGTH_LONG,
// //       );
// //     }
// //     return allGranted;
// //   }
// //
// //   // Get the custom SoomuchInterview directory where videos are saved
// //   Future<String> _getSoomuchInterviewDirectory() async {
// //     if (Platform.isAndroid) {
// //       // Use the standard Documents directory and create SoomuchInterview folder
// //       final directory = await getExternalStorageDirectory();
// //       final soomuchDir = Directory('${directory?.path}/SoomuchInterview');
// //       if (!await soomuchDir.exists()) {
// //         await soomuchDir.create(recursive: true);
// //       }
// //       return soomuchDir.path;
// //     } else {
// //       // For iOS, use Documents directory with SoomuchInterview folder
// //       final docsDir = await getApplicationDocumentsDirectory();
// //       final soomuchDir = Directory('${docsDir.path}/SoomuchInterview');
// //       if (!await soomuchDir.exists()) {
// //         await soomuchDir.create(recursive: true);
// //       }
// //       return soomuchDir.path;
// //     }
// //   }
// //
// //   Future<void> _loadRecordings() async {
// //     try {
// //       final dirPath = await _getSoomuchInterviewDirectory();
// //       final dir = Directory(dirPath);
// //
// //       if (await dir.exists()) {
// //         final files = await dir.list().toList();
// //         // Filter only video files and sort by modification time (newest first)
// //         final videoFiles = files
// //             .where(
// //               (file) =>
// //                   file.path.toLowerCase().endsWith('.mp4') ||
// //                   file.path.toLowerCase().endsWith('.mov') ||
// //                   file.path.toLowerCase().endsWith('.avi'),
// //             )
// //             .toList();
// //
// //         // Sort by modification time, newest first
// //         videoFiles.sort((a, b) {
// //           final aStat = a.statSync();
// //           final bStat = b.statSync();
// //           return bStat.modified.compareTo(aStat.modified);
// //         });
// //
// //         setState(() => _recordings = videoFiles);
// //
// //         if (_recordings.isEmpty) {
// //           print("No video files found in: $dirPath");
// //         } else {
// //           print("Found ${_recordings.length} recordings in: $dirPath");
// //         }
// //       } else {
// //         print("Directory does not exist: $dirPath");
// //         setState(() => _recordings = []);
// //       }
// //     } catch (e) {
// //       print("Error loading recordings: $e");
// //       Fluttertoast.showToast(
// //         msg: 'Error loading recordings: $e',
// //         toastLength: Toast.LENGTH_LONG,
// //       );
// //     }
// //   }
// //
// //   Future<void> _startRecording() async {
// //     if (_isLoading) return;
// //     setState(() => _isLoading = true);
// //
// //     if (!await _requestPermissions()) {
// //       setState(() => _isLoading = false);
// //       return;
// //     }
// //
// //     // Create a temporary file path for recording
// //     final tempDir = await getTemporaryDirectory();
// //     final fileName =
// //         'soomuch_interview_${DateTime.now().millisecondsSinceEpoch}.mp4';
// //     _currentRecordingPath = '${tempDir.path}/$fileName';
// //
// //     print("👉 Temporary recording path: $_currentRecordingPath");
// //
// //     final started = await FlutterScreenRecording.startRecordScreenAndAudio(
// //       fileName,
// //     );
// //
// //     if (started == true) {
// //       setState(() {
// //         _isRecording = true;
// //         _isLoading = false;
// //         _recordingDuration = Duration.zero;
// //       });
// //       _startRecordingTimer();
// //       Fluttertoast.showToast(
// //         msg: 'Recording started',
// //         gravity: ToastGravity.TOP,
// //       );
// //     } else {
// //       setState(() => _isLoading = false);
// //       Fluttertoast.showToast(
// //         msg: 'Failed to start recording',
// //         toastLength: Toast.LENGTH_LONG,
// //       );
// //     }
// //   }
// //
// //   void _startRecordingTimer() {
// //     _recordingTimer = Timer.periodic(Duration(seconds: 1), (_) {
// //       setState(() => _recordingDuration += Duration(seconds: 1));
// //     });
// //   }
// //
// //   Future<void> _stopRecording() async {
// //     if (_isLoading) return;
// //     setState(() => _isLoading = true);
// //
// //     _recordingTimer?.cancel();
// //
// //     final path = await FlutterScreenRecording.stopRecordScreen;
// //     setState(() {
// //       _isRecording = false;
// //       _isLoading = false;
// //     });
// //
// //     if (path != null && path.isNotEmpty) {
// //       try {
// //         final file = File(path);
// //         if (await file.exists()) {
// //           final sizeMB = (await file.length()) / (1024 * 1024);
// //
// //           // Save to SoomuchInterview folder
// //           final soomuchDirPath = await _getSoomuchInterviewDirectory();
// //           final soomuchDir = Directory(soomuchDirPath);
// //           if (!soomuchDir.existsSync()) {
// //             soomuchDir.createSync(recursive: true);
// //           }
// //
// //           final fileName =
// //               "soomuch_interview_${DateTime.now().millisecondsSinceEpoch}.mp4";
// //           final newPath = "${soomuchDir.path}/$fileName";
// //
// //           // Copy the file to SoomuchInterview directory
// //           await file.copy(newPath);
// //
// //           // Delete the temporary file
// //           await file.delete();
// //
// //           Fluttertoast.showToast(
// //             msg:
// //                 'Recording saved to SoomuchInterview folder!\n'
// //                 'Duration: ${_formatDuration(_recordingDuration)}\n'
// //                 'Size: ${sizeMB.toStringAsFixed(2)} MB',
// //             toastLength: Toast.LENGTH_LONG,
// //             gravity: ToastGravity.CENTER,
// //           );
// //
// //           print("✅ Recording saved to: $newPath");
// //
// //           // Reload the recordings list
// //           _loadRecordings();
// //         } else {
// //           Fluttertoast.showToast(
// //             msg: 'Recording file not found at temporary path',
// //             toastLength: Toast.LENGTH_LONG,
// //           );
// //         }
// //       } catch (e) {
// //         print("Error saving recording: $e");
// //         Fluttertoast.showToast(
// //           msg: 'Error saving recording: $e',
// //           toastLength: Toast.LENGTH_LONG,
// //         );
// //       }
// //     } else {
// //       Fluttertoast.showToast(
// //         msg: 'Failed to stop recording or file not available',
// //         toastLength: Toast.LENGTH_LONG,
// //       );
// //     }
// //
// //     _currentRecordingPath = null;
// //     _recordingDuration = Duration.zero;
// //   }
// //
// //   String _formatDuration(Duration d) {
// //     String two(int n) => n.toString().padLeft(2, '0');
// //     final h = two(d.inHours);
// //     final m = two(d.inMinutes.remainder(60));
// //     final s = two(d.inSeconds.remainder(60));
// //     return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
// //   }
// //
// //   // Get file size and date for display
// //   String _getFileInfo(FileSystemEntity file) {
// //     try {
// //       final stat = file.statSync();
// //       final sizeMB = stat.size / (1024 * 1024);
// //       final date = stat.modified;
// //
// //       return '${sizeMB.toStringAsFixed(1)} MB • ${DateFormat('MMM dd, HH:mm').format(date)}';
// //     } catch (e) {
// //       return 'Unknown size • Unknown date';
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _recordingTimer?.cancel();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Soomuch Interview Recorder'),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.refresh),
// //             onPressed: _loadRecordings,
// //             tooltip: 'Refresh recordings',
// //           ),
// //         ],
// //       ),
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             if (_isRecording)
// //               Container(
// //                 padding: EdgeInsets.all(16),
// //                 color: Colors.red.withOpacity(0.1),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Icon(Icons.circle, color: Colors.red, size: 16),
// //                     SizedBox(width: 8),
// //                     Text(
// //                       'Recording - ${_formatDuration(_recordingDuration)}',
// //                       style: TextStyle(
// //                         color: Colors.red,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //
// //             Padding(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 children: [
// //                   _buildControlButtons(),
// //                   if (_isLoading) ...[
// //                     SizedBox(height: 20),
// //                     CircularProgressIndicator(),
// //                     SizedBox(height: 10),
// //                     Text('Processing...'),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //
// //             Divider(height: 1),
// //
// //             Padding(
// //               padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
// //               child: Row(
// //                 children: [
// //                   Text(
// //                     'Interview Recordings',
// //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                   ),
// //                   SizedBox(width: 8),
// //                   Text(
// //                     '(${_recordings.length})',
// //                     style: TextStyle(fontSize: 16, color: Colors.grey),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             Expanded(
// //               child: _recordings.isEmpty
// //                   ? Center(
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Icon(
// //                             Icons.videocam_off,
// //                             size: 64,
// //                             color: Colors.grey[300],
// //                           ),
// //                           SizedBox(height: 16),
// //                           Text(
// //                             'No interview recordings yet',
// //                             style: TextStyle(fontSize: 18, color: Colors.grey),
// //                           ),
// //                           SizedBox(height: 8),
// //                           Text(
// //                             'Start recording to capture your interview',
// //                             style: TextStyle(color: Colors.grey),
// //                           ),
// //                         ],
// //                       ),
// //                     )
// //                   : ListView.builder(
// //                       itemCount: _recordings.length,
// //                       itemBuilder: (context, index) {
// //                         final file = _recordings[index];
// //                         final fileName = file.path.split('/').last;
// //
// //                         return Card(
// //                           margin: EdgeInsets.symmetric(
// //                             horizontal: 16,
// //                             vertical: 4,
// //                           ),
// //                           child: ListTile(
// //                             leading: Icon(
// //                               Icons.video_library,
// //                               color: Colors.red,
// //                             ),
// //                             title: Text(
// //                               fileName,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: TextStyle(fontWeight: FontWeight.w500),
// //                             ),
// //                             subtitle: Text(_getFileInfo(file)),
// //                             trailing: Icon(
// //                               Icons.play_arrow,
// //                               color: Colors.blue,
// //                             ),
// //                             onTap: () {
// //                               Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                   builder: (_) => VideoPlayerScreen(
// //                                     videoFile: File(file.path),
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //                         );
// //                       },
// //                     ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildControlButtons() {
// //     return ElevatedButton.icon(
// //       onPressed: _isLoading
// //           ? null
// //           : _isRecording
// //           ? _stopRecording
// //           : _startRecording,
// //       icon: Icon(
// //         _isRecording ? Icons.stop : Icons.videocam,
// //         color: Colors.white,
// //         size: 24,
// //       ),
// //       label: Text(
// //         _isRecording ? 'Stop Recording' : 'Start Recording',
// //         style: TextStyle(fontSize: 16),
// //       ),
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: _isRecording ? Colors.red : Colors.green,
// //         foregroundColor: Colors.white,
// //         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
// //         minimumSize: Size(200, 50),
// //       ),
// //     );
// //   }
// // }
// //
// // /// Simple video player screen
// // class VideoPlayerScreen extends StatefulWidget {
// //   final File videoFile;
// //
// //   VideoPlayerScreen({required this.videoFile});
// //
// //   @override
// //   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// // }
// //
// // class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
// //   late VideoPlayerController _controller;
// //   bool _isPlaying = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = VideoPlayerController.file(widget.videoFile)
// //       ..initialize().then((_) {
// //         setState(() {});
// //         _controller.play();
// //       });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Interview Recording")),
// //       body: SafeArea(
// //         child: Center(
// //           child: _controller.value.isInitialized
// //               ? Column(
// //                   children: [
// //                     AspectRatio(
// //                       aspectRatio: _controller.value.aspectRatio,
// //                       child: VideoPlayer(_controller),
// //                     ),
// //                     VideoProgressIndicator(
// //                       _controller,
// //                       allowScrubbing: true,
// //                       colors: VideoProgressColors(
// //                         playedColor: Colors.red,
// //                         bufferedColor: Colors.grey[300]!,
// //                         backgroundColor: Colors.grey[600]!,
// //                       ),
// //                     ),
// //                   ],
// //                 )
// //               : CircularProgressIndicator(),
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () {
// //           setState(() {
// //             if (_controller.value.isPlaying) {
// //               _controller.pause();
// //               _isPlaying = false;
// //             } else {
// //               _controller.play();
// //               _isPlaying = true;
// //             }
// //           });
// //         },
// //         child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
// //       ),
// //     );
// //   }
// // }