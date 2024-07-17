import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../utils/app_color.dart';

class PicturesFromCamera extends StatefulWidget {
  const PicturesFromCamera({super.key});
  @override
  _PicturesFromCameraState createState() => _PicturesFromCameraState();
}

class _PicturesFromCameraState extends State<PicturesFromCamera> {
  final storage = FirebaseStorage.instance;
  List<String> imageUrls = [];
  SharedPreferences? prefs;
  String currentTimeZone = 'Africa/Cairo'; // Use 'Africa/Cairo' for Egypt timezone

  @override
  void initState() {
    super.initState();
    loadImages();
    SharedPreferences.getInstance().then((value) => prefs = value);
    FlutterTimezone.getLocalTimezone().then((value) => setState(() => currentTimeZone = value));
    initializeDateFormatting().then((_) => setState(() {}));
    tz.initializeTimeZones();
  }

  Future<void> loadImages() async {
    ListResult result = await storage.ref('camera').listAll();
    for (var ref in result.items) {
      String downloadURL = await ref.getDownloadURL();
      FullMetadata metadata = await ref.getMetadata();
      setState(() {
        imageUrls.add(downloadURL);
        prefs?.setStringList('imageUrls', imageUrls);
      });
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      Reference ref = storage.refFromURL(url);
      await ref.delete();
      setState(() {
        imageUrls.remove(url);
        prefs?.remove(url);
      });
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  String _formatTimestamp(int timestamp) {
    final utcDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
    final cairoTimeZone = tz.getLocation('Africa/Cairo');
    final localDateTime = tz.TZDateTime.from(utcDateTime, cairoTimeZone);
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(localDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primaryColorGreen,
        title: Text(
          "Pics Camera",
          style: TextStyle(fontSize: 26, color: AppColor.textSecondaryColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: imageUrls.isEmpty
          ? Center(
          child: Text("There is no images yet",
              style: TextStyle(color: Colors.black, fontSize: 30)))
          : ListView.builder(
        scrollDirection: Axis.vertical,
        itemBuilder: (_, index) {
          return FutureBuilder<FullMetadata>(
            future: storage.refFromURL(imageUrls[index]).getMetadata(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final metadata = snapshot.data!;
                final timestamp = _formatTimestamp(metadata.timeCreated?.millisecondsSinceEpoch ?? 0);
                return Dismissible(
                  key: Key(imageUrls[index]),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => deleteImage(imageUrls[index]),
                  confirmDismiss: (_) async => await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Delete Image"),
                      content: Text("Are you sure you want to delete this image?"),
                      actions: [
                        TextButton(
                            child: Text("No"),
                            onPressed: () => Navigator.pop(context, false)),
                        TextButton(
                            child: Text("Yes"),
                            onPressed: () => Navigator.pop(context, true)),
                      ],
                    ),
                  ),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 60),
                    margin: EdgeInsets.only(
                        top: 60, right: 20, bottom: 60, left: 150),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20)),
                    child: Icon(Icons.delete, color: Colors.white, size: 40),
                  ),
                  child: Stack(children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            image: NetworkImage(imageUrls[index]),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 30,
                      child: GestureDetector(
                        onTap: () => ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                            content:
                            Text("Date and Time: $timestamp"))),
                        child: Icon(Icons.info_outline,
                            color: Colors.green, size: 30),
                      ),
                    ),
                  ]),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          );
        },
        itemCount: imageUrls.length,
      ),
    );
  }
}
