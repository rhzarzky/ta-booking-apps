import 'package:flutter/material.dart';

class TabBarComp extends StatelessWidget {
  const TabBarComp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TabBar(
          tabs: [
            Tab(text: 'Approved'),
            Tab(text: 'Pending'),
            Tab(text: 'Rejected'),
          ],
        ),
        Expanded(
          child: const TabBarView(
            children: [
              Center(child: Text('Approved Content')),
              Center(child: Text('Pending Content')),
              Center(child: Text('Rejected Content')),
            ],
          ),
        ),
      ],
    );
  }
}
