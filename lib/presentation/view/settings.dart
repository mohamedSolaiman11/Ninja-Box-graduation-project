import 'package:flutter/material.dart';
import 'package:graduation_project2024/presentation/view/wifi_box_connection.dart';
import 'package:graduation_project2024/presentation/widgets/go_to_page_only.dart';
import '../../utils/app_color.dart';
import 'add_guard.dart';
import 'change_account_password.dart';
import 'change_box_password.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primaryColorGreen,
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 26, color: AppColor.textSecondaryColor,fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: settingText.length,
          itemBuilder: (context, index) {
            return customerSettingsList(
              permission: settingText[index],
              onTap: () {
                if (settingText[index] == "Change Account Password") {
                  goToPageOnly(context, ChangeAccountPassword());
                } else if (settingText[index] == "Change Box Password") {
                  goToPageOnly(context, ChangeBoxPassword());
                } else if (settingText[index] == "Add Guard") {
                  goToPageOnly(context, AddGuard());
                } else {
                  goToPageOnly(context, WifiBoxConnection());
                }
              }, size: size.width*.03,
            );
          },
        ),
      ),
    );
  }

  InkWell customerSettingsList({required String permission, required void Function()? onTap,required double size}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: size ,right: size,top: size),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              _getIcon(permission),
              color: AppColor.primaryColorGreen,
            ),
            SizedBox(width: 15),
            Text(
              permission,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String permission) {
    switch (permission) {
      case "Change Account Password":
        return Icons.lock_outline;
      case "Change Box Password":
        return Icons.vpn_key_outlined;
      case "Add Guard":
        return Icons.person_add_outlined;
      case "Change WIFI Box Connection":
        return Icons.wifi_outlined;
      default:
        return Icons.settings;
    }
  }

  List settingText = [
    "Change Account Password",
    "Change Box Password",
    "Add Guard",
    "Change WIFI Box Connection"
  ];
}
