import 'package:flutter/material.dart';
import 'package:flutter_study_app/components/MyAppBar.dart';

import '../config.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('设置', AppHeight),
      body: Center(
        child: Text('this is about screen'),
      ),
    );
  }
}
