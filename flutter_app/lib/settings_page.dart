import 'package:flutter/material.dart';
import 'package:flutter_app/home_page.dart';
import 'package:flutter_app/log_in_page.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SettingsPage extends StatefulWidget {
  final String profileImagePath;

  const SettingsPage({super.key, required this.profileImagePath});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int currentLanguageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    widget.profileImagePath,
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 20),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'First Last',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('emailuser@gmail.com'),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.delete,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogInPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text('Add Account',
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: const Color.fromARGB(255, 221, 221, 221),
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Divider(
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                const Icon(Icons.translate_rounded),
                ToggleSwitch(
                  minWidth: 120,
                  activeBgColor: const [Colors.blue],
                  inactiveBgColor: Colors.grey[300],
                  inactiveFgColor: Colors.black,
                  initialLabelIndex: currentLanguageIndex,
                  labels: const ['English', 'French'],
                  onToggle: (index) {
                    setState(() {
                      currentLanguageIndex = index!;
                    });
                    debugPrint(currentLanguageIndex.toString());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
