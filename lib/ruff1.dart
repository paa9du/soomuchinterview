
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firebase_options.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: FirestoreTestPage(),
//     );
//   }
// }
//
// class FirestoreTestPage extends StatelessWidget {
//   final CollectionReference users =
//   FirebaseFirestore.instance.collection('users');
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Firestore Test")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               child: Text("Add User"),
//               onPressed: () async {
//                 await users.add({
//                   'name': 'Pavan',
//                   'createdAt': FieldValue.serverTimestamp(),
//                 });
//               },
//             ),
//             ElevatedButton(
//               child: Text("Get Users"),
//               onPressed: () async {
//                 QuerySnapshot snapshot = await users.get();
//                 for (var doc in snapshot.docs) {
//                   print(doc.data());
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
