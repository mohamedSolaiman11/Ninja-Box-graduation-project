import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../utils/app_color.dart'; // تأكد من تحديث المسار بشكل صحيح

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  final databaseReference = FirebaseDatabase.instance.ref().child('permissions');

  late Map<String, bool> permissions = {
    "Show Battery": false,
    "Log Access": false,
    "Detect People": false,
    "Open Box": false,
    "Receive Notification": false,
  };

  @override
  void initState() {
    super.initState();

    // استمع للتغييرات في Firebase Realtime Database
    databaseReference.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          permissions = Map<String, bool>.from(data as Map);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primaryColorGreen,
        title: Text(
          "Permissions",
          style: TextStyle(fontSize: 26, color: AppColor.textSecondaryColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: permissions.length,
          itemBuilder: (context, index) {
            final String permission = permissions.keys.elementAt(index);
            final bool isChecked = permissions[permission] ?? false;
            return _buildPermissionTile(permission, isChecked);
          },
        ),
      ),
    );
  }

  Widget _buildPermissionTile(String permission, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              permission,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Checkbox(
              value: isChecked,
              onChanged: (newValue) {
                _updatePermission(permission, newValue ?? false);
              },
              activeColor: AppColor.primaryColorGreen,
            ),
          ],
        ),
      ),
    );
  }

  void _updatePermission(String permission, bool newValue) {
    setState(() {
      permissions[permission] = newValue;
    });

    // قم بتحديث القيمة في Firebase Realtime Database
    databaseReference.child(permission).set(newValue).catchError((error) {
      // التعامل مع الأخطاء هنا، مثل عرض رسالة SnackBar للمستخدم
      print("خطأ في تحديث قاعدة بيانات Firebase: $error");
    });
  }
}
