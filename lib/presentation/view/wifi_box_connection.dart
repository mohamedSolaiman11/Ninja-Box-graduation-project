import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../widgets/custom_email_text_field.dart';

class WifiBoxConnection extends StatefulWidget {
  const WifiBoxConnection({Key? key}) : super(key: key);

  @override
  _WifiBoxConnectionState createState() => _WifiBoxConnectionState();
}

class _WifiBoxConnectionState extends State<WifiBoxConnection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController wifiOneNameController = TextEditingController();
  final TextEditingController wifiOnePassController = TextEditingController();
  final TextEditingController wifiTwoNameController = TextEditingController();
  final TextEditingController wifiTwoPassController = TextEditingController();

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('wifi-info');

  @override
  void initState() {
    super.initState();
    _fetchWifiCredentials(); // Fetch credentials on widget initialization
  }

  Future<void> _fetchWifiCredentials() async {
    try {
      DataSnapshot snapshot = await _databaseReference.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> wifiData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          wifiOneNameController.text = wifiData['ssid1']['ssid'];
          wifiOnePassController.text = wifiData['ssid1']['password'];
          wifiTwoNameController.text = wifiData['ssid2']['ssid'];
          wifiTwoPassController.text = wifiData['ssid2']['password'];
        });
      }
    } catch (e) {
      // Handle errors here (e.g., show a SnackBar or log the error)
      print('Error fetching WiFi credentials: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primaryColorGreen,
        title: const Text(
          "Wifi Box Connection",
          style: TextStyle(fontSize: 26, color: AppColor.textSecondaryColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("SSID1"),
              _buildWifiBlocContainer(
                controller1: wifiOneNameController,
                controller2: wifiOnePassController,
                onUpdate: () => _updateWifiCredentials("ssid1"),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("SSID2"),
              _buildWifiBlocContainer(
                controller1: wifiTwoNameController,
                controller2: wifiTwoPassController,
                onUpdate: () => _updateWifiCredentials("ssid2"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container _buildWifiBlocContainer({
    required TextEditingController controller1,
    required TextEditingController controller2,
    required VoidCallback onUpdate,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "WiFi SSID",
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          CustomEmailTextField(
            controller: controller1,
            label: 'WiFi Name',
            textInputType: TextInputType.text,
            textWillAppearInNotVaildate: 'Invalid Name',
          ),
          const SizedBox(height: 10),
          const Text(
            "WiFi Password",
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          CustomEmailTextField(
            controller: controller2,
            label: 'WiFi Password',
            textInputType: TextInputType.visiblePassword,
            textWillAppearInNotVaildate: 'Invalid Password',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onUpdate,
            child: const Text(
              "Update",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              backgroundColor: AppColor.primaryColorGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateWifiCredentials(String ssid) async {
    if (_formKey.currentState!.validate()) {
      try {
        final wifiName = ssid == "ssid1" ? wifiOneNameController.text : wifiTwoNameController.text;
        final wifiPassword = ssid == "ssid1" ? wifiOnePassController.text : wifiTwoPassController.text;
        await _databaseReference.child(ssid).set({
          'ssid': wifiName,
          'password': wifiPassword,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WiFi credentials updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating WiFi credentials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
