import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text('A', style: TextStyle(color: Colors.white)),
          ),
          CircleAvatar(
            backgroundColor: Colors.green,
            child: Text('B', style: TextStyle(color: Colors.white)),
          ),
          CircleAvatar(
            backgroundColor: Colors.orange,
            child: Text('C', style: TextStyle(color: Colors.white)),
          ),
          CircleAvatar(
            backgroundColor: Colors.purple,
            child: Text('D', style: TextStyle(color: Colors.white)),
          ),
          CircleAvatar(
            backgroundColor: Colors.red,
            child: Text('E', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
