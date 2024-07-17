import 'package:animated_battery_gauge/animated_battery_gauge.dart';
import 'package:animated_battery_gauge/battery_gauge.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project2024/presentation/view/alert.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/app_color.dart';
import '../../utils/app_images_path.dart';
import '../widgets/build_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {


  String _doorStatus = "";
  final DatabaseReference doorStatusReference = FirebaseDatabase.instance.ref().child('zena_status').child('status');
  final databaseReference = FirebaseDatabase.instance.ref().child('zena_status');

  void _listenToDoorStatusChanges() {
    doorStatusReference.onValue.listen((DatabaseEvent event) {
      setState(() {
        _doorStatus = event.snapshot.value.toString();
      });
    }).onError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: error));
    });
  }
  @override
  void initState() {
    super.initState();
    _listenToDoorStatusChanges();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return _doorStatusWidget(_doorStatus,HomePage(scaffoldKey, widthSize: size.width*.05 , heightSize: size.height*.03),Alert());
  }

  Scaffold HomePage(GlobalKey<ScaffoldState> scaffoldKey,{required double widthSize,required double heightSize}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      drawer: BulidDrawer(
        closeMyDrawer: () {
          scaffoldKey.currentState!.closeDrawer();
        },
      ),
      appBar: AppBar(
        elevation: 10,
        toolbarHeight: 70,
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primaryColorGreen,
        title: const Text(
          "NINJA BOX",
          style: TextStyle(color: Colors.white, fontSize: 34),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            scaffoldKey.currentState!.openDrawer();
          },
          child: Container(
            margin: const EdgeInsets.only(left: 20),
            child: Image.asset(
              AppImagesPath.icon_list,
              color: Colors.white,
            ),
          ),
        ),
        leadingWidth: 55,
      ),
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: databaseReference.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return Center(child: FacebookStyleShimmer());
            }

            final data = snapshot.data!.snapshot.value;

            if (data is! Map) {
              return const Center(child: Text('Invalid data format'));
            }

            try {
              final boxStatus = BoxStatus.fromMap(data);
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: widthSize*12,
                      height: heightSize*12,
                      padding: EdgeInsets.only(top: widthSize*1.4,),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: Image.asset(
                          AppImagesPath.box_image_path,
                        ),
                      ),
                    ),
                    Text(
                      "SMART SAFE BOX",
                      style: TextStyle(
                        letterSpacing: 3,
                        fontSize: widthSize,
                        color: AppColor.btnGreenColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusCard(boxStatus,widthSize: widthSize , heightSize: heightSize),
                    Center(child: Text("Made By Ninja Team 🎶🥷 ",
                      style: TextStyle(color: Colors.grey.shade700,fontSize: 17),),)
                  ],
                ),
              );
            } catch (e) {
              print("---------------Error parsing : $e");
              return Center(child: Text('Error parsing data: $e'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(BoxStatus status,{required double widthSize,required double heightSize}) {
    return Container(
      margin:  EdgeInsets.symmetric(horizontal: widthSize , vertical: heightSize),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withOpacity(.5),
              blurRadius: .1,
              offset: Offset.fromDirection(2, 4)),
          BoxShadow(
              color: Colors.black.withOpacity(.6),
              offset: Offset.fromDirection(2.5, -4)),
        ],
        color: AppColor.textSecondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: heightSize*1.2,
          ),
          Text(
            "NINJA Box Status",
            style: TextStyle(
                fontSize: 25,
                color: AppColor.textPrimaryColor,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: heightSize,
          ),
          _buildStatusItem('Battery', "Battery", _buildBatteryGauge(status.battery),
            status.battery < 15 ? const Icon(Icons.warning, color: Colors.red) : const Icon(Icons.check_circle, color: Colors.green),
            status.battery < 15 ? Colors.red : Colors.green,
          ),
          _buildStatusItem('Door', status.door, _getIcon(status.door),
            status.door.toLowerCase() == 'open' ? const Icon(Icons.warning, color: Colors.red) : const Icon(Icons.check_circle, color: Colors.green),
            status.door.toLowerCase() == "open" ? Colors.red : Colors.green,
          ),
          _buildStatusItem('Protected', status.protected, _getIcon(status.protected),
            status.protected.toLowerCase() == 'not protected' ? const Icon(Icons.warning, color: Colors.red) : const Icon(Icons.check_circle, color: Colors.green),
            status.protected.toLowerCase() == "not protected" ? Colors.red : Colors.green,
          ),
          _buildStatusItem('People', status.people, _getIcon(status.people),
            status.people.toLowerCase() == 'no people' ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.warning, color: Colors.red),
            status.people.toLowerCase() == "no people" ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryGauge(int batteryLevel) {
    return AnimatedBatteryGauge(
      duration: const Duration(seconds: 1),
      value: batteryLevel.toDouble(),
      size: const Size(60, 25),
      borderColor: AppColor.textPrimaryColor,
      valueColor: batteryLevel > 15 ? AppColor.primaryColorGreen : Colors.red,
      mode: BatteryGaugePaintMode.gauge,
      hasText: true,
    );
  }

  Widget _getIcon(String status) {
    if (status.toLowerCase() == 'open') {
      return Image.asset("assets/icons/opened-door-aperture.png", width: 40, height: 40, color: Colors.red,);
    }
    if (status.toLowerCase() == 'close') {
      return Image.asset("assets/icons/closed_door.png", width: 40, height: 40);
    }
    if (status.toLowerCase() == 'no people') {
      return Image.asset("assets/icons/man.png", width: 40, height: 40);
    }
    if (status.toLowerCase().trim() == 'not protected') {
      return Image.asset("assets/icons/security.png", width: 40, height: 40, color: Colors.red,);
    }
    if (status.toLowerCase().trim() == 'protected') {
      return Image.asset("assets/icons/security.png", width: 40, height: 40, color: Colors.green,);
    } else {
      return Image.asset("assets/icons/man.png", width: 40, height: 40, color: Colors.red,);
    }
  }

  Widget _buildStatusItem(
      String title, String value, Widget icon1, Widget icon2, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 10),
            Expanded(flex: 1, child: icon1),
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    text: "",
                    style: const TextStyle(fontSize: 19, color: Colors.black),
                    children: [
                      TextSpan(
                          text: value,
                          style: TextStyle(
                              color: color, fontSize: 20)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(flex: 1, child: icon2),
          ],
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}

Widget FacebookStyleShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    enabled: true,
    child: ListView.builder(
      itemCount: 10, // Number of shimmer items
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[400],
            radius: 30,
          ),
          title: Row(
            children: <Widget>[
              Container(
                width: 120.0,
                height: 16.0,
                color: Colors.white,
              ),
            ],
          ),
          subtitle: Container(
            margin: EdgeInsets.only(top: 8.0),
            width: double.infinity,
            height: 16.0,
            color: Colors.white,
          ),
        );
      },
    ),
  );
}

Widget _doorStatusWidget(String doorStatus,Widget widget1,Widget widget2) {
  if (doorStatus.toUpperCase().trim()== "PROTECTED") {
    return widget1;
  }
  else if (doorStatus.toUpperCase().trim() == "NOT PROTECTED") {
    return widget2;
  }
  else {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator(backgroundColor: AppColor.yellow,)),
    );
  }
}

class BoxStatus {
  final int battery;
  final String door;
  final String protected;
  final String people;

  BoxStatus({
    required this.battery,
    required this.door,
    required this.protected,
    required this.people,
  });

  factory BoxStatus.fromMap(Map<dynamic, dynamic> map) {
    return BoxStatus(
      battery: _parseBatteryLevel(map['battery']),
      door: map['door'] ?? "Unknown",
      protected: map['status'] ?? "Unknown",
      people: map['people'] ?? "Unknown",
    );
  }

  static int _parseBatteryLevel(dynamic battery) {
    if (battery is String) {
      double? parsedValue = double.tryParse(battery);
      if (parsedValue != null) {
        return parsedValue.toInt();
      }
    } else if (battery is double) {
      return battery.toInt();
    } else if (battery is int) {
      return battery;
    }
    return 0; // Default value if parsing fails
  }




}

