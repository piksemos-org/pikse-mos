import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Messages'),
      body: const Center(child: Text('No new messages.')),
    );
  }
}
