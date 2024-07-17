import 'package:flutter/material.dart';
import 'package:graduation_project2024/presentation/view/admin_page.dart';
import 'package:graduation_project2024/presentation/view/guard_page.dart';
import 'package:graduation_project2024/utils/app_color.dart';
import 'package:graduation_project2024/utils/app_images_path.dart';

import '../widgets/custom_button.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width,
              height: size.height * .42,
              child: Image.asset(AppImagesPath.box_image_path),
            ),
            CustomButton(
              context,
              text: "Admin",
              backColor: AppColor.yellow,
              widget: AdminPage(),
            ),
            CustomButton(
              context,
              text: "Guard",
              backColor: AppColor.btnBlackColor,
              widget: GuardPage(),
            ),
          ],
        ),
      ),
    );
  }


}
