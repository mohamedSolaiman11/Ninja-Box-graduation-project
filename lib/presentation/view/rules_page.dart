import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../utils/app_color.dart'; // Ensure correct import path

class RulesPage extends StatefulWidget {
  const RulesPage({Key? key}) : super(key: key);

  @override
  _RulesPageState createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  final databaseReference = FirebaseDatabase.instance.ref().child('rules');

  Map<String, bool> rules = {
    'Active Keyboard': false,
    'Alarm Sound': false,
    'Vibrations': false,
    'Location Sensor': false,
    'Night Protection': false,
    'Active Remote': false,
  };

  @override
  void initState() {
    super.initState();
    // Listen for changes in Firebase Realtime Database
    databaseReference.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        setState(() {
          rules = Map<String, bool>.from(data as Map);
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
          'Rules',
          style: TextStyle(fontSize: 26, color: AppColor.textSecondaryColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: rules.length,
          itemBuilder: (context, index) {
            final ruleKey = rules.keys.elementAt(index);
            final isChecked = rules[ruleKey]!;
            return _buildRuleTile(ruleKey, isChecked);
          },
        ),
      ),
    );
  }

  Widget _buildRuleTile(String rule, bool isChecked) {
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
              rule,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Checkbox(
              value: isChecked,
              onChanged: (newValue) => _updateRule(rule, newValue!),
              activeColor: AppColor.primaryColorGreen,
            ),
          ],
        ),
      ),
    );
  }

  void _updateRule(String rule, bool newValue) {
    if (rule == 'Night Protection') {
      _updateNightProtectionRules(newValue);
    } else {
      setState(() {
        rules[rule] = newValue;
      });
      databaseReference.child(rule).set(newValue);
    }
  }

  void _updateNightProtectionRules(bool newValue) {
    setState(() {
      rules['Night Protection'] = newValue;
      rules['Active Remote'] = newValue;
      rules['Location Sensor'] = newValue;
      rules['Alarm Sound'] = newValue;
      rules['Active Keyboard'] = !newValue;
      rules['Vibrations'] = newValue;
    });
    databaseReference.update(rules);
  }
}
