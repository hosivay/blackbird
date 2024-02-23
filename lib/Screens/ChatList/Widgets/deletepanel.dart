



import 'package:blackbird/SettingsFiles/database.dart';
import 'package:blackbird/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class deleteSlide extends StatefulWidget {
  const deleteSlide({super.key, required this.child, required this.indexMap});
  final Widget child;
  final int indexMap;
  @override
  State<deleteSlide> createState() => _deleteSlideState();
}

class _deleteSlideState extends State<deleteSlide> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (context) async {
              MyStorage().deletechat(widget.indexMap);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: CupertinoIcons.delete,
            label: "Delete",
            autoClose: true,
          ),
        ],
      ),
      child: widget.child,
    );
  }
}
